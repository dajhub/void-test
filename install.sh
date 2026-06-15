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
  sddm \
  seatd \
  dbus \
  elogind \
  polkit \
  Alacritty \
  libX11-devel \
  libXft-devel \
  libXinerama-devel

# 3. Configure runit services
echo "--> Enabling core system services..."
# Enable dbus (Required for elogind and SDDM)
if [ ! -L /var/service/dbus ]; then
  sudo ln -s /etc/sv/dbus /var/service/
fi

# Enable elogind (Required for clean session management)
if [ ! -L /var/service/elogind ]; then
  sudo ln -s /etc/sv/elogind /var/service/
fi

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

# 4. Create configuration directories for your dotfiles
echo "--> Preparing config directories..."
mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/.config/polybar"

echo "========================================================="
echo " Installation complete!"
echo "========================================================="
echo " Next steps:"
echo " 1. Move your 'config' file into ~/.config/i3/"
echo " 2. Move your Polybar configs into ~/.config/polybar/"
echo " 3. Ensure your Polybar is configured to launch via i3"
echo "    (e.g., 'exec_always --no-startup-id ~/.config/polybar/launch.sh')"
echo " 4. REBOOT your system."
echo "========================================================="
echo " Note: On reboot, SDDM will start automatically."
echo " Select 'i3' from the session dropdown menu before logging in!"
echo "========================================================="
