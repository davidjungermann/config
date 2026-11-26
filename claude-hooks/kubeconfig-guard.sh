#!/bin/bash
# Claude Code PreToolUse hook: keep production Kubernetes contexts out of every
# kubeconfig except ~/.kube/production, and route production access through
# the `kubeconfig` script. Exit 2 blocks the tool call and shows stderr to Claude.

input="$(cat)"
tool="$(jq -r '.tool_name // empty' <<<"$input")"

block() {
    cat >&2 <<EOF
BLOCKED by kubeconfig-guard: $1

Production Kubernetes contexts live only in ~/.kube/production and must never be
added to, renamed in, or written into any other kubeconfig (~/.kube/dev, ~/.kube/config).
Do not run \`gcloud container clusters get-credentials\` or \`kubectl config set-*\` for
production clusters, and do not edit files under ~/.kube.

Use the kubeconfig script instead:
  kubeconfig dev -- kubectl get pods -n <ns>
  kubeconfig production -- kubectl get pods -n <ns>
  kubeconfig check            # verify dev has no production clusters

If a production cluster is missing from ~/.kube/production, ask the user to add it
(they reclassify contexts with kubeconfig-split).
EOF
    exit 2
}

prod_re='prod|storied-precept-238507|crng'

case "$tool" in
    Edit|Write|MultiEdit|NotebookEdit)
        path="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")"
        [[ "$path" == */.kube/* ]] && block "direct edits to $path"
        ;;
    Bash)
        cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
        lc="$(tr '[:upper:]' '[:lower:]' <<<"$cmd")"
        if grep -Eq 'get-credentials' <<<"$lc" && grep -Eq "$prod_re" <<<"$lc"; then
            block "fetching production cluster credentials"
        fi
        if grep -Eq 'kubectl[^|;&]*config[[:space:]]+(set-context|set-cluster|set-credentials|rename-context|use-context|set)([[:space:]]|$)' <<<"$lc" \
            && grep -Eq "$prod_re" <<<"$lc"; then
            block "modifying a kubeconfig with a production context"
        fi
        if grep -Eq '(~|\$home|\$\{home\}|/users/[^/]+)/\.kube/production' <<<"$lc"; then
            block "using ~/.kube/production directly"
        fi
        ;;
esac
exit 0
