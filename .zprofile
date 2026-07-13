export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
	*":$BUN_INSTALL/bin:"*) ;;
	*) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

export NVM_DIR="$HOME/.config/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
	. "$NVM_DIR/nvm.sh"
	nvm use --silent default >/dev/null
fi
