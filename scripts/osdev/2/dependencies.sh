#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.
set -u  # Treat unset variables as errors.

# Detect operating system and package manager
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    PKG_MGR="brew"
elif command -v apt-get &> /dev/null; then
    OS="Linux (Debian-based)"
    PKG_MGR="apt-get"
    UPDATE_CMD="sudo apt-get update -y"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v pacman &> /dev/null; then
    OS="Linux (Arch-based)"
    PKG_MGR="pacman"
    UPDATE_CMD="sudo pacman -Syu --noconfirm"
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
elif command -v zypper &> /dev/null; then
    OS="Linux (SUSE-based)"
    PKG_MGR="zypper"
    UPDATE_CMD="sudo zypper refresh"
    INSTALL_CMD="sudo zypper install -y"
else
    echo "Unsupported system. Please install the following dependencies manually:"
    echo "- nasm, xorriso, grub2, gcc, and make (for Linux)"
    echo "- Homebrew and x86_64-elf-gcc (for macOS)"
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
    brew install nasm xorriso grub x86_64-elf-gcc
    echo "Dependencies installed successfully on macOS."
    exit 0
fi

# Linux: Update package lists and install dependencies
echo "Updating package lists and installing dependencies..."
$UPDATE_CMD
$INSTALL_CMD nasm xorriso grub2 curl

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
