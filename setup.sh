#!/bin/bash

# Colors for output
green="\033[0;32m"
red="\033[0;31m"
no_color="\033[0m"

# Helper function to check for errors
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "${red}Error: $1 failed.${no_color}"
        exit 1
    fi
}

# Update the system
echo -e "${green}Updating the system...${no_color}"
sudo pacman -Syu --noconfirm
check_success "System update"

# Install required packages
echo -e "${green}Installing required packages...${no_color}"
sudo pacman -S --noconfirm --needed hyprland mako midori waybar micro git kitty
check_success "Package installation"

# Install AUR helper (yay) if not already installed
if ! command -v yay &> /dev/null; then
    echo -e "${green}Installing yay (AUR helper)...${no_color}"
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf ~/yay
    check_success "yay installation"
fi

# Clone dotfiles repository
echo -e "${green}Cloning dotfiles repository...${no_color}"
git clone https://github.com/your-username/your-dotfiles-repo.git ~/dotfiles
check_success "Cloning dotfiles"

# Symlink configuration files
echo -e "${green}Setting up configuration files...${no_color}"
DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config

mkdir -p $CONFIG_DIR
ln -sf $DOTFILES_DIR/hyprland $CONFIG_DIR/hyprland
ln -sf $DOTFILES_DIR/mako $CONFIG_DIR/mako
ln -sf $DOTFILES_DIR/waybar $CONFIG_DIR/waybar
ln -sf $DOTFILES_DIR/kitty $CONFIG_DIR/kitty

# Additional custom configuration if needed
if [ -f "$DOTFILES_DIR/custom.sh" ]; then
    echo -e "${green}Running custom configuration script...${no_color}"
    bash $DOTFILES_DIR/custom.sh
    check_success "Custom configuration"
fi

# Enable services
echo -e "${green}Enabling required services...${no_color}"
# Wayland does not require a traditional display manager; assume Hyprland will be started manually or through a login manager.
systemctl --user enable mako.service

# Wrap-up
echo -e "${green}Setup complete!${no_color}"
echo -e "${green}Please restart your session or start Hyprland manually.${no_color}"
