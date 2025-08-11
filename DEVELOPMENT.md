# Development Environment Setup

This project uses Nix flakes for reproducible development environments. To get the best experience, we recommend installing Nix and direnv.

## Installing Nix

<details>
<summary><strong>Linux/macOS</strong></summary>

```bash
# Install Nix (multi-user installation)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (add to ~/.config/nix/nix.conf or /etc/nix/nix.conf)
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

</details>

<details>
<summary><strong>Windows (WSL2)</strong></summary>

```bash
# Install Nix in WSL2
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

</details>

## Installing direnv

<details>
<summary><strong>Linux</strong></summary>

```bash
# Ubuntu/Debian
sudo apt install direnv

# Arch Linux
sudo pacman -S direnv

# Or install via Nix
nix profile install nixpkgs#direnv
```

</details>

<details>
<summary><strong>macOS</strong></summary>

```bash
# Using Homebrew
brew install direnv

# Or using Nix
nix profile install nixpkgs#direnv
```

</details>

<details>
<summary><strong>Windows (WSL2)</strong></summary>

```bash
# Install via package manager in WSL2
sudo apt install direnv

# Or install via Nix
nix profile install nixpkgs#direnv
```

</details>

## Setting up direnv

Add the following line to your shell configuration file (`.bashrc`, `.zshrc`, etc.):

```bash
eval "$(direnv hook bash)"  # For bash
eval "$(direnv hook zsh)"   # For zsh
```

Then restart your shell or run `source ~/.bashrc` (or your shell config file).

## Using the Development Environment

1. **Navigate to the project directory**:
   ```bash
   cd poe-accountant
   ```

2. **Allow direnv** (first time only):
   ```bash
   direnv allow
   ```

## Project Setup

To install dependencies:

```sh
task install
```

To start the project:

```sh
task start
```
