# Autojump Plugin for Yazi

This plugin integrates [autojump](https://github.com/wting/autojump) with Yazi file manager, allowing you to quickly navigate to frequently visited directories.

## Requirements

- [autojump](https://github.com/wting/autojump) must be installed and properly configured on your system.

## Installation

1. Clone this repository to your Yazi plugins directory:
   ```bash
   git clone https://github.com/yourusername/yazi-autojump ~/.config/yazi/plugins/autojump.yazi
   ```

   Or manually create the files in `~/.config/yazi/plugins/autojump.yazi/`.

2. Add a keybinding to your `~/.config/yazi/keymap.toml`:
   ```toml
   [[manager.prepend_keymap]]
   on   = "j"
   run  = "plugin autojump"
   desc = "Jump to a directory using autojump"
   ```

## Usage

1. Press the configured key (e.g., `j`) in Yazi.
2. Type a partial name of a directory you've visited before.
3. Press Enter to jump to that directory.

## How it works

The plugin creates an input dialog where you can type a directory pattern. It then passes this pattern to autojump, which returns the most likely directory based on your navigation history. Yazi then navigates to that directory.

## License

MIT 