#!/bin/sh
# Sets up Dia: DiaTweaks, the local tweaks in patches/ and the saved settings. Re-runnable.
# Afterwards DiaTweaks keeps itself and Dia up to date (Settings > Home > Software Update) and
# recompiles the local tweaks against each new version, so updates need nothing from this repo.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
support="$HOME/Library/Application Support/DiaPatches"
PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:${CARGO_HOME:-$HOME/.cargo}/bin"

[ -d /Applications/Dia.app ] || brew install --cask thebrowsercompany-dia
# Apple's compiler builds DiaTweaks the first time and the local tweaks on every update.
xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "Rerun once Apple's developer tools are installed." >&2; exit 1; }

# The first install has to be built from source. Build it unmodified: the local patches go in the
# local tweaks folder instead, which DiaTweaks keeps and recompiles across updates.
if [ ! -x "$support/bin/diatweaks" ]; then
    command -v cargo >/dev/null 2>&1 || brew install rust
    src=$(mktemp -d)
    git clone --depth 1 https://github.com/JaceThings/DiaTweaks.git "$src/DiaTweaks"
    "$src/DiaTweaks/install.sh" --yes
    rm -rf "$src"
fi

# Settings live in defaults; write them while Dia is closed so it doesn't overwrite them on quit.
if pgrep -xq Dia; then
    # The patched Dia answers the quit event with "User canceled" even as it quits, so wait for it instead.
    osascript -e 'quit app "Dia"' >/dev/null 2>&1 || true
    i=0
    while pgrep -xq Dia; do
        i=$((i + 1))
        [ "$i" -le 30 ] || { echo "Dia didn't quit. Quit it and rerun." >&2; exit 1; }
        sleep 1
    done
fi
"$here/dia-defaults.sh"
defaults import com.diapatches "$here/diatweaks.plist"   # tweak options, e.g. profile emojis

mkdir -p "$support/local"
for dir in "$here"/patches/*/; do
    rm -rf "$support/local/$(basename "$dir")"
    cp -R "${dir%/}" "$support/local/"
done
diatweaks local build

# Moves a source build onto the release channel once a newer release is out; from then on
# DiaTweaks updates itself. Until then this just reports that the source build is current.
diatweaks update -y || echo "diatweaks update failed; DiaTweaks will offer it again in Settings > Home." >&2

tweaks=$(grep -vE '^[[:space:]]*(#|$)' "$here/tweaks.txt")
# shellcheck disable=SC2086
diatweaks enable $tweaks -y
pgrep -xq Dia || open -a Dia

cat <<'EOF'

Dia is patched. Quit and reopen Dia once so Turn Off AI cuts off the AI servers.
Updates: Dia > Settings > Home > Software Update. DiaTweaks installs new Dia and DiaTweaks
versions when Dia quits and rebuilds the local tweaks. `diatweaks update` and
`diatweaks update-dia` do it now.
By hand, once per machine:
  - Settings > Advanced > Address Bar: Prefer Search Engine
  - Right-click the sidebar > new Live Tab Group > GitHub (pull requests)
  - System Settings > Privacy & Security > Screen & System Audio Recording: allow Dia
  - Passwords: diatweaks enable onePassword / passkeys / icloudPasswords if needed
EOF
