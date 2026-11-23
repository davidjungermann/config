#!/bin/sh
# Sets up Dia: DiaTweaks + the local Switch to Open Tabs patch + saved tweaks.
# Re-runnable. Installs Dia with Homebrew (cask thebrowsercompany-dia) if missing.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
repo="${DIATWEAKS_DIR:-$HOME/DiaTweaks}"

[ -d /Applications/Dia.app ] || brew install --cask thebrowsercompany-dia
xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "Rerun once Apple's developer tools are installed." >&2; exit 1; }
command -v cargo >/dev/null 2>&1 || brew install rust

if [ -d "$repo/.git" ]; then git -C "$repo" pull --ff-only
else git clone https://github.com/JaceThings/DiaTweaks.git "$repo"
fi

# Local patches live in this repo; copy them into the DiaTweaks tree before building.
for dir in "$here"/patches/*/; do
    name=$(basename "$dir")
    mkdir -p "$repo/src/dylib/Patches/$name"
    cp "$dir"*.m "$repo/src/dylib/Patches/$name/"
done

# Settings live in defaults; write them while Dia is closed so it doesn't overwrite them on quit.
if pgrep -xq Dia; then osascript -e 'quit app "Dia"' && sleep 3; fi
"$here/dia-defaults.sh"
defaults import com.diapatches "$here/diatweaks.plist"   # tweak options, e.g. profile emojis

"$repo/install.sh" --yes

PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin"
tweaks=$(grep -vE '^[[:space:]]*(#|$)' "$here/tweaks.txt")
# shellcheck disable=SC2086
diatweaks enable $tweaks -y

cat <<'EOF'

Dia is patched. Quit and reopen Dia once so Turn Off AI cuts off the AI servers.
By hand, once per machine:
  - Settings > Advanced > Address Bar: Prefer Search Engine
  - Right-click the sidebar > new Live Tab Group > GitHub (pull requests)
  - System Settings > Privacy & Security > Screen & System Audio Recording: allow Dia
  - Passwords: diatweaks enable onePassword / passkeys / icloudPasswords if needed
Don't run `diatweaks update`: it installs the stock release without the local patch. Rerun this script instead.
EOF
