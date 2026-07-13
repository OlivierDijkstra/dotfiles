# Private, gitignored secrets (e.g. BROWSERBASE_API_KEY)
[ -f "$HOME/.config/browse.env" ] && source "$HOME/.config/browse.env"

export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
	*":$BUN_INSTALL/bin:"*) ;;
	*) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac
