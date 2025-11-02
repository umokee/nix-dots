#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/umokee/nix-dots.git"
CONFIG_DIR="/tmp/nixos-config"
SELECTED_HOST=""

echo "================================"
echo "   NixOS Auto-Installer"
echo "================================"
echo

cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf "$CONFIG_DIR"
}
trap cleanup EXIT

if [[ ! -f /etc/NIXOS ]]; then
  echo "❌ Error: This must be run from NixOS live ISO"
  exit 1
fi

echo "🌐 Checking internet connection..."
if ! ping -c 1 1.1.1.1 &>/dev/null; then
  echo "❌ No internet connection!"
  exit 1
fi
echo "✓ Internet connection OK"
echo

echo "📥 Downloading configuration from GitHub..."
if [[ -d "$CONFIG_DIR" ]]; then
  rm -rf "$CONFIG_DIR"
fi

if ! git clone "$REPO_URL" "$CONFIG_DIR"; then
  echo "❌ Failed to clone repository"
  exit 1
fi
cd "$CONFIG_DIR"
echo "✓ Configuration downloaded"
echo

echo "🔍 Detecting available hosts..."
if [[ ! -f "flake.nix" ]]; then
  echo "❌ Error: flake.nix not found"
  exit 1
fi

mapfile -t HOSTS < <(grep -A 3 'hostsWithHm = \[' flake.nix | \
  grep -oP '"\\K[^"]+' | head -2; \
  grep -A 1 'hosts = hostsWithHm' flake.nix | \
  grep -oP '"\\K[^"]+' | tail -1)

if [[ ${#HOSTS[@]} -eq 0 ]]; then
  echo "Extracting hosts from hosts/ directory..."
  mapfile -t HOSTS < <(find hosts -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)
fi

if [[ ${#HOSTS[@]} -eq 0 ]]; then
  echo "❌ No hosts found in configuration"
  exit 1
fi

echo "Available hosts:"
for i in "${!HOSTS[@]}"; do
  HOST="${HOSTS[$i]}"
  
  MACHINE_TYPE="unknown"
  if grep -q "\"$HOST\"" shared/config.nix 2>/dev/null; then
    MACHINE_TYPE="$HOST"
  fi
  
  echo "  [$((i+1))] $HOST ($MACHINE_TYPE)"
  
  if [[ -f "hosts/$HOST/disko.nix" ]]; then
    echo "      ✓ disko configuration"
  else
    echo "      ✗ NO disko configuration"
  fi
  
  if [[ -f "hosts/$HOST/configuration.nix" ]]; then
    echo "      ✓ NixOS configuration"
  fi
  
  if [[ -f "hosts/$HOST/home.nix" ]]; then
    echo "      ✓ home-manager configuration"
  fi
done
echo

read -p "Select host number: " HOST_NUM
if ! [[ "$HOST_NUM" =~ ^[0-9]+$ ]] || [[ "$HOST_NUM" -lt 1 ]] || [[ "$HOST_NUM" -gt ${#HOSTS[@]} ]]; then
  echo "❌ Invalid selection"
  exit 1
fi

SELECTED_HOST="${HOSTS[$((HOST_NUM-1))]}"
echo "✓ Selected host: $SELECTED_HOST"
echo

if [[ ! -f "hosts/$SELECTED_HOST/disko.nix" ]]; then
  echo "❌ Error: disko.nix not found for host '$SELECTED_HOST'"
  exit 1
fi

echo "💾 Current disk layout:"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
echo

echo "⚠️  WARNING: This will COMPLETELY ERASE the disk specified in disko.nix!"
echo "   Host: $SELECTED_HOST"
echo "   Config: hosts/$SELECTED_HOST/disko.nix"
echo
echo "   Check disko.nix to see which disk will be formatted:"
grep "device = " "hosts/$SELECTED_HOST/disko.nix" | head -3
echo
read -p "Type 'YES' to continue: " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then
  echo "Installation cancelled"
  exit 1
fi
echo

echo "🔧 Partitioning disk with disko..."
echo "This will destroy all data on the target disk!"
sleep 2

if ! sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko "hosts/$SELECTED_HOST/disko.nix"; then
  echo "❌ Disko partitioning failed!"
  exit 1
fi
echo "✓ Disk partitioned successfully"
echo

echo "🖥️  Generating hardware configuration..."
sudo nixos-generate-config --no-filesystems --root /mnt --show-hardware-config > "hosts/$SELECTED_HOST/hardware-configuration.nix"
echo "✓ Hardware configuration generated"
echo

echo "📋 Copying configuration to /mnt/etc/nixos..."
sudo mkdir -p /mnt/etc/nixos
sudo cp -r "$CONFIG_DIR"/* /mnt/etc/nixos/
cd /mnt/etc/nixos
echo "✓ Configuration copied"
echo

echo "🚀 Installing NixOS..."
echo "This will take a while (10-30 minutes depending on internet speed)..."
echo

if ! sudo nixos-install --flake "/mnt/etc/nixos#$SELECTED_HOST" --no-root-password; then
  echo "❌ Installation failed!"
  exit 1
fi

echo
echo "✓ NixOS installation completed!"
echo

USERNAME=$(grep 'username = ' shared/config.nix | head -1 | sed 's/.*username = "\\(.*\\)".*/\\1/' || echo "user")

echo "================================"
echo "   Installation Summary"
echo "================================"
echo "Host: $SELECTED_HOST"
echo "Username: $USERNAME"
echo
echo "Setting password for $USERNAME..."
if ! sudo nixos-enter --root /mnt -c "passwd $USERNAME"; then
  echo "❌ Failed to set password for $USERNAME"
  echo "You can set it manually after reboot with: passwd"
fi
echo

echo "Setting password for root..."
if ! sudo nixos-enter --root /mnt -c "passwd root"; then
  echo "❌ Failed to set password for root"
  echo "You can set it manually after reboot"
fi
echo

echo "================================"
echo "After first boot:"
echo "  - Your dotfiles are at: ~/nixos"
echo "  - Rebuild system: sudo nixos-rebuild switch --flake ~/nixos#$SELECTED_HOST"
echo "  - Update home-manager: home-manager switch --flake ~/nixos#$SELECTED_HOST"
echo "================================"
echo

read -p "Reboot now? (y/N): " REBOOT_NOW
if [[ "$REBOOT_NOW" =~ ^[Yy]$ ]]; then
  echo "Rebooting in 3 seconds..."
  sleep 3
  sudo reboot
else
  echo "Remember to reboot manually: sudo reboot"
fi
