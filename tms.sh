tms() {
  # Get list of existing sessions
  sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
  [ -z "$sessions" ] && echo "No tmux sessions exist." && return 1

  if [ -n "$1" ]; then
    # Check for exact match first
    exact_match=$(echo "$sessions" | grep -x "$1")
    if [ -n "$exact_match" ]; then
      target="$exact_match"
    else
      # Use fzf in filtering mode to rank matches
      matches=$(echo "$sessions" | fzf --filter="$1")
      match_count=$(echo "$matches" | wc -l | tr -d ' ')

      if [ "$match_count" -eq 1 ]; then
        target="$matches"
      elif [ "$match_count" -gt 1 ]; then
        target=$(echo "$matches" | fzf)
      else
        echo "No matching session. Creating new one: $1"
        tmux new -s "$1"
        return
      fi
    fi
  else
    # No argument: pick from all existing sessions
    target=$(echo "$sessions" | fzf)
    [ -z "$target" ] && return
  fi

  # Determine if already inside tmux
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$target"
  else
    tmux attach-session -t "$target"
  fi
}
