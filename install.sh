#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Starting Void Linux i3 + Polybar + SDDM Installation ==="

# 1. Update the package database
echo "--> Updating XBPS database..."
sudo xbps-install -S

# 2. Install base X11, i3, Polybar, SDDM, and essential utilities
# Note: Since we are using SDDM, xinit/startx are no longer required.
echo "--> Installing core packages..."
sudo xbps-install -y \
  xorg-minimal \
  i3-gaps \
  polybar \
  picom \
  autotiling \
  betterlockscreen \
  rofi \
  dunst \
  feh \
  sddm \
  seatd \
  dbus \
  elogind \
  polkit \
  alacritty \
  libX11-devel \
  libXft-devel \
  libXinerama-devel

# 2a. Terminal & Editors
echo "--> Installing terminal and editors"
sudo xbps-install -y \
  kitty \
  zsh \
  micro \
  neovim

# 2b. Utilities
echo "--> Utilities"
sudo xbps-install -y \
  curl \
  unzip \
  base-devel \
  xrandr \
  xset \
  htop \
  bzmenu \
  rsync \
  xclip \
  maim

# 2c. File manager
echo "--> File Manager"
sudo xbps-install -y \
  yazi \
  ffmpeg \
  7zip \
  jq \
  poppler \
  fd \
  ripgrep \
  fzf \
  zoxide \
  resvg \
  ImageMagick \
  unzip

# 2d. Browser
echo "--> Browser"
sudo xbps-install -y firefox

# Configure Shell
echo "--> Configuring Shell"
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
chsh -s /usr/bin/zsh

# Configure runit services
echo "--> Enabling core system services..."
# Enable dbus (Required for elogind and SDDM)
if [ ! -L /var/service/dbus ]; then
  sudo ln -s /etc/sv/dbus /var/service/
fi

# Enable elogind (Required for clean session management)
#if [ ! -L /var/service/elogind ]; then
#  sudo ln -s /etc/sv/elogind /var/service/
#fi

# Enable seatd (Handles graphics/input permissions)
if [ ! -L /var/service/seatd ]; then
  sudo ln -s /etc/sv/seatd /var/service/
fi

# Enable SDDM (This will bring up the graphical login screen on boot)
if [ ! -L /var/service/sddm ]; then
  sudo ln -s /etc/sv/sddm /var/service/
fi

# Add current user to required groups
echo "--> Adding user $USER to video, audio, and seat groups..."
sudo umask 026
sudo gpasswd -a "$USER" video
sudo gpasswd -a "$USER" audio
sudo gpasswd -a "$USER" _seatd

# 4. Configuring directories for dotfiles
echo "--> Preparing config directories..."

CONFIG_DIR="$HOME/.config"
DOTFILES_SRC="$HOME/i3"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOTS_DIR"
mkdir -p "$WALLPAPERS_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$SCREENSHOTS_DIR"

if [ -d "$DOTFILES_SRC" ]; then
  msg "Syncing dotfiles from $DOTFILES_SRC..."
  if [ -f "$DOTFILES_SRC/folders.sh" ]; then
    chmod +x "$DOTFILES_SRC/folders.sh"
    (cd "$DOTFILES_SRC" && ./folders.sh)
    msg "Folder sync complete."
  else
    warn "folders.sh not found in $DOTFILES_SRC."
  fi
else
  warn "Source directory $DOTFILES_SRC not found! Skipping dotfiles."
fi

echo "========================================================="
echo " Installation complete!"
echo "========================================================="
echo "Next step:"
echo "REBOOT system."
echo "========================================================="
echo " Note: On reboot, SDDM will start automatically."
echo " Select 'i3' from the session dropdown menu before logging in!"
echo "========================================================="
