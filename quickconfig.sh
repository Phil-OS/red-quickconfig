#!/usr/bin/env bash
set -euo pipefail

main() {
	pacman=$(get_pacman)
	if [[  "$pacman" == "none"  ]]; then
		echo "package manager not found."
		exit 1
	fi

	echo "using $pacman"
	install_misc "$pacman"
	install_nix
	install_direnv "$pacman"
	add_hook
	
}

get_pacman(){
	if command -v apt-get &>/dev/null; then
		echo "apt"
	elif command -v dnf &>/dev/null; then
		echo "dnf"
	elif command -v yum &>/dev/null; then
		echo "yum"
	else
		echo "none"
	fi
}

install_misc(){
	local pm=$1
	case "pm" in
		apt)
			sudo apt-get update -y
			sudo apt-get install -y curl git ca-certificates build-essential
			;;
		dnf) sudo dnf install -y curl git ca-certificates gcc make ;;
		yum) sudo yum install -y curl git ca-certificates gcc make ;;
	esac
}
install_nix(){
	if ! command -v nix &>/dev/null; then
		sh <(curl -L https://nixos.org/nix/install) --daemon
	else
		echo "nix already installed"
	fi
}
install_direnv(){
	if ! command -v direnv &>/dev/null; then
		local pm =$1
		case "$pm" in 
			apt) sudo apt-get install -y direnv ;;
			dnf) sudo dnf install -y direnv ;;
			yum) sudo yum install -y direnv ;;
		esac
	else
		echo "direnv already installed"
	fi
}
# Didnt know how to do this, this one is all AI. be sus.
add_hook(){
	local shell_name rc_file hook_line 
	shell_name=$(basename "$SHELL") 
	case "$shell_name" in 
		bash) rc_file="$HOME/.bashrc" hook_line='eval "$(direnv hook bash)"' ;; 
		zsh) rc_file="$HOME/.zshrc" hook_line='eval "$(direnv hook zsh)"' ;; 
		*) echo "Unsupported shell: $shell_name" return ;; 
	esac 
	if ! grep -Fxq "$hook_line" "$rc_file" 2>/dev/null; then 
		echo "$hook_line" >> "$rc_file"
	       	echo "Appended direnv hook to $rc_file"
	        echo "run source ~/.$shell_name to apply changes"	
	else 
		echo "direnv hook already present in $rc_file" 
	fi
	# end AI code
	
}

main "$@"
mkdir minipekka
cd minipekka
touch .envrc
echo "nix develop" > .envrc
curl -O https://raw.githubusercontent.com/Phil-OS/redflake/refs/heads/main/flake.nix

