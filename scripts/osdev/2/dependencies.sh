#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.
set -u  # Treat unset variables as errors.

# Detect operating system and package manager
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    PKG_MGR="brew"
    GRUB="grub2"
elif command -v apt-get &> /dev/null; then
    OS="Linux (Debian-based)"
    PKG_MGR="apt-get"
    INSTALL_CMD="sudo apt-get install -y"
    GRUB="grub2"
elif command -v pacman &> /dev/null; then
    OS="Linux (Arch-based)"
    PKG_MGR="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    GRUB="grub"
elif command -v zypper &> /dev/null; then
    OS="Linux (SUSE-based)"
    PKG_MGR="zypper"
    INSTALL_CMD="sudo zypper install -y"
    GRUB="grub2"
else
    echo "Unsupported system. Please install the following dependencies manually:"
    echo "- nasm, xorriso, grub2, gcc, make, Homebrew and x86_64-elf-gcc"
    exit 1
fi

echo "Detected system: $OS"

# macOS-specific installation
if [[ $PKG_MGR == "brew" ]]; then
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Updating Homebrew..."
        brew update --force --quiet
    fi

    echo "Installing dependencies via Homebrew..."
    brew install nasm xorriso grub x86_64-elf-gcc make
    echo "Dependencies installed successfully on macOS."
    exit 0
fi

# Linux: Update package lists and install dependencies
echo "installing dependencies..."
$INSTALL_CMD nasm xorriso $GRUB curl

# Additional dependencies for specific distros
if [[ $PKG_MGR == "zypper" ]]; then
    echo "Installing additional tools for SUSE-based systems..."
    $INSTALL_CMD gcc make
elif [[ $PKG_MGR == "apt-get" ]]; then
    echo "Installing build-essential on Debian-based systems..."
    $INSTALL_CMD build-essential
fi

# Install Homebrew on Linux if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    echo "Homebrew already installed, updating..."
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew update --force --quiet
fi

# Fix permissions for Homebrew
echo "Fixing Homebrew permissions..."
chmod -R go-w "$(brew --prefix)/share/zsh"

# Install x86_64-elf-gcc if not already installed
if ! brew list x86_64-elf-gcc &> /dev/null; then
    echo "Installing x86_64-elf-gcc via Homebrew..."
    brew install x86_64-elf-gcc
else
    echo "x86_64-elf-gcc already installed."
fi

# Confirm installations
echo "Confirming installations..."
nasm --version
xorriso --version
grub-mkrescue --version
x86_64-elf-gcc --version

echo "Setup complete!"
