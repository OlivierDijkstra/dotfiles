# OS1 palette for the Pure prompt.
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
    zstyle :prompt:pure:path color '#B75A46'
    zstyle :prompt:pure:prompt:success color '#B75A46'
    zstyle :prompt:pure:prompt:error color '#A84736'
    zstyle :prompt:pure:git:dirty color '#C75A44'
    zstyle :prompt:pure:git:branch color '#7D7268'
    zstyle :prompt:pure:git:action color '#8B7E72'
    zstyle :prompt:pure:git:arrow color '#A39384'
    zstyle :prompt:pure:git:stash color '#A39384'
    zstyle :prompt:pure:execution_time color '#A39384'
    zstyle :prompt:pure:host color '#A39384'
    zstyle :prompt:pure:user color '#A39384'
    zstyle :prompt:pure:virtualenv color '#A39384'
    zstyle :prompt:pure:prompt:continuation color '#A39384'
  else
    zstyle :prompt:pure:path color '#E8B7A8'
    zstyle :prompt:pure:prompt:success color '#D66A52'
    zstyle :prompt:pure:prompt:error color '#E07A65'
    zstyle :prompt:pure:git:dirty color '#D66A52'
    zstyle :prompt:pure:git:branch color '#B9AA9D'
    zstyle :prompt:pure:git:action color '#A39384'
    zstyle :prompt:pure:git:arrow color '#E8B7A8'
    zstyle :prompt:pure:git:stash color '#E8B7A8'
    zstyle :prompt:pure:execution_time color '#A39384'
    zstyle :prompt:pure:host color '#8B7E72'
    zstyle :prompt:pure:user color '#8B7E72'
    zstyle :prompt:pure:virtualenv color '#A39384'
    zstyle :prompt:pure:prompt:continuation color '#8B7E72'
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
