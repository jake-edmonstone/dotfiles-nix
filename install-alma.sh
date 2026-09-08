#!/usr/bin/env bash
set -euo pipefail

msg() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
err() { printf "\033[1;31mERROR:\033[0m %s\n" "$*" >&2; }

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
HOME_ATTR="jedmonstone@jedmonstone-dev"
EXPECTED_USER="jedmonstone"
EXPECTED_HOME="/home/STRIKETECH/$EXPECTED_USER"
EXPECTED_HOST="jedmonstone-dev.striketechnologies.com"
EXPECTED_DOTFILES="$EXPECTED_HOME/nix-config"
SYSTEM_CA_BUNDLE="/etc/pki/tls/certs/ca-bundle.crt"
NIX_CUSTOM_CONF="/etc/nix/nix.custom.conf"

if [[ "$(id -u)" -eq 0 ]]; then
  err "Run this script as $EXPECTED_USER, not as root; it will use sudo when needed"
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  err "Cannot identify the operating system"
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "almalinux" || "${VERSION_ID%%.*}" != "9" ]]; then
  err "This configuration requires AlmaLinux 9"
  err "Detected: ${PRETTY_NAME:-unknown}"
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  err "This configuration requires x86_64 Linux"
  exit 1
fi

if [[ "$(id -un)" != "$EXPECTED_USER" || "$HOME" != "$EXPECTED_HOME" ]]; then
  err "This configuration requires $EXPECTED_USER with home $EXPECTED_HOME"
  exit 1
fi

actual_host="$(hostname -f 2>/dev/null || hostname)"
if [[ "$actual_host" != "$EXPECTED_HOST" ]]; then
  err "This configuration requires host $EXPECTED_HOST"
  err "Detected: $actual_host"
  exit 1
fi

if [[ "$DOTFILES" != "$EXPECTED_DOTFILES" ]]; then
  err "This configuration must be cloned to $EXPECTED_DOTFILES"
  err "Current checkout: $DOTFILES"
  exit 1
fi

for command in curl git grep sed sudo systemctl tee; do
  if ! command -v "$command" >/dev/null 2>&1; then
    err "Required bootstrap command is missing: $command"
    exit 1
  fi
done

if [[ ! -r "$SYSTEM_CA_BUNDLE" ]]; then
  err "AlmaLinux CA bundle is missing or unreadable: $SYSTEM_CA_BUNDLE"
  exit 1
fi

if ! sudo -n true; then
  err "Passwordless sudo is required for the multi-user Nix installation"
  exit 1
fi

if command -v nix >/dev/null 2>&1; then
  NIX_BIN="$(command -v nix)"
elif [[ -x /nix/var/nix/profiles/default/bin/nix ]]; then
  NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
else
  msg "Installing Determinate Nix"
  curl --proto '=https' --tlsv1.2 -sSfL \
    https://install.determinate.systems/nix | sh -s -- install --no-confirm \
    --ssl-cert-file "$SYSTEM_CA_BUNDLE"
  NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
fi

if [[ ! -x "$NIX_BIN" ]]; then
  err "Determinate Nix was installed, but nix is not available at $NIX_BIN"
  exit 1
fi

if [[ "$($NIX_BIN --version 2>/dev/null || true)" != *"Determinate Nix"* ]]; then
  err "This configuration requires Determinate Nix"
  err "Detected: $($NIX_BIN --version 2>/dev/null || echo unknown)"
  exit 1
fi

# Nix uses its own CA bundle unless both the daemon and client are directed to
# AlmaLinux's trust store. This is required on GTS because HTTPS is intercepted
# by a corporate CA. Determinate includes nix.custom.conf from nix.conf.
if ! sudo grep -qFx "ssl-cert-file = $SYSTEM_CA_BUNDLE" "$NIX_CUSTOM_CONF" 2>/dev/null; then
  msg "Configuring Nix to use the AlmaLinux CA bundle"
  if sudo grep -qE '^[[:space:]]*ssl-cert-file[[:space:]]*=' "$NIX_CUSTOM_CONF" 2>/dev/null; then
    sudo sed -i -E \
      "s|^[[:space:]]*ssl-cert-file[[:space:]]*=.*$|ssl-cert-file = $SYSTEM_CA_BUNDLE|" \
      "$NIX_CUSTOM_CONF"
  else
    printf '\nssl-cert-file = %s\n' "$SYSTEM_CA_BUNDLE" | \
      sudo tee -a "$NIX_CUSTOM_CONF" >/dev/null
  fi
  sudo systemctl restart nix-daemon.service
fi
export NIX_SSL_CERT_FILE="$SYSTEM_CA_BUNDLE"

msg "Activating Home Manager configuration $HOME_ATTR"
home_manager=(
  "$NIX_BIN" run "$DOTFILES#home-manager" --
)

if [[ ! -e "$HOME/.local/state/home-manager/gcroots/current-home" ]]; then
  for file in .bash_profile .bashrc; do
    if [[ -e "$HOME/$file.before-home-manager" ]]; then
      err "$HOME/$file.before-home-manager already exists"
      err "Move that backup elsewhere before running the first activation"
      exit 1
    fi
  done
  home_manager+=(-b before-home-manager)
fi

home_manager+=(switch --flake "$DOTFILES#$HOME_ATTR")

"${home_manager[@]}"

msg "Done. Open a new SSH session; interactive sessions will start Fish."
msg "Future updates can be applied with: nh home switch"
