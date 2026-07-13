# OS1 neutral-surface palette for the Pure prompt.
# Reads the currently applied theme mode from theme-mode state.

typeset -g PURE_OS1_LAST_MODE=""

function pure_os1_read_mode() {
  local mode="dark"
  local state_file="${XDG_STATE_HOME:-$HOME/.local/state}/theme-mode/state.json"

  if command -v jq >/dev/null 2>&1 && [[ -r "$state_file" ]]; then
    mode="$(jq -r '.applied // "dark"' "$state_file" 2>/dev/null)"
  fi

  if [[ "$mode" != "light" && "$mode" != "dark" ]]; then
    mode="dark"
  fi

  printf '%s\n' "$mode"
}

function pure_os1_apply_colors() {
  local mode="${1:-$(pure_os1_read_mode)}"

  if [[ "$mode" == "light" ]]; then
    zstyle :prompt:pure:path color '#3F6F9F'
    zstyle :prompt:pure:prompt:success color '#3F7D58'
    zstyle :prompt:pure:prompt:error color '#B84E4E'
    zstyle :prompt:pure:git:dirty color '#916622'
    zstyle :prompt:pure:git:branch color '#737373'
    zstyle :prompt:pure:git:action color '#737373'
    zstyle :prompt:pure:git:arrow color '#A3A3A3'
    zstyle :prompt:pure:git:stash color '#A3A3A3'
    zstyle :prompt:pure:execution_time color '#A3A3A3'
    zstyle :prompt:pure:host color '#A3A3A3'
    zstyle :prompt:pure:user color '#A3A3A3'
    zstyle :prompt:pure:virtualenv color '#737373'
    zstyle :prompt:pure:prompt:continuation color '#A3A3A3'
  else
    zstyle :prompt:pure:path color '#7CA9D8'
    zstyle :prompt:pure:prompt:success color '#76B78B'
    zstyle :prompt:pure:prompt:error color '#E57373'
    zstyle :prompt:pure:git:dirty color '#D2A85B'
    zstyle :prompt:pure:git:branch color '#A3A3A3'
    zstyle :prompt:pure:git:action color '#A3A3A3'
    zstyle :prompt:pure:git:arrow color '#737373'
    zstyle :prompt:pure:git:stash color '#737373'
    zstyle :prompt:pure:execution_time color '#737373'
    zstyle :prompt:pure:host color '#737373'
    zstyle :prompt:pure:user color '#737373'
    zstyle :prompt:pure:virtualenv color '#A3A3A3'
    zstyle :prompt:pure:prompt:continuation color '#737373'
  fi

  PURE_OS1_LAST_MODE="$mode"
}

function pure_os1_sync_colors() {
  local mode
  mode="$(pure_os1_read_mode)"

  if [[ "$mode" != "$PURE_OS1_LAST_MODE" ]]; then
    pure_os1_apply_colors "$mode"
  fi
}

pure_os1_apply_colors "$(pure_os1_read_mode)"

if [[ -z "${precmd_functions[(r)pure_os1_sync_colors]}" ]]; then
  precmd_functions+=(pure_os1_sync_colors)
fi
