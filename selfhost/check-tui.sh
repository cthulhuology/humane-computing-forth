#!/bin/sh
# Check explicit frames and output-vector cleanup without requiring a terminal.
set -eu
runtime=$(realpath "${1:-./forth}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"
cd "$work"

"$runtime" ': panel.example s" first line" s" Example" tui.frame ; panel.example depth . verify? .' > "$work/frame"
awk '
  NR == 1 { if (length != 80 || $0 !~ /^\+- Example -+\+$/) exit 1 }
  NR == 2 { if (length != 80 || $0 !~ /^\| first line .* \|$/) exit 1 }
  NR == 3 { if (length != 80 || $0 !~ /^\+-+\+$/) exit 1 }
  NR == 4 { if ($0 != "0 -1 ") exit 1 }
  END { if (NR != 4) exit 1 }
' "$work/frame"

# ANSI remains absent from automatic inspection in pipes.
"$runtime" 'see dup locate drop where not.in.source words org 16 dump' > "$work/plain"
if LC_ALL=C grep -q "$(printf '\033')" "$work/plain"; then exit 1; fi

# A frame abandoned by a fault cannot retain the TYPE handler after QUIT.
output=$(printf 'output.vector @ . output.image @ . tui.active @ . depth . 42 .\n' |
    "$runtime" ': panel.fault s" Fault" tui.frame.begin 0 @ ; panel.fault')
case "$output" in *'0 0 0 0 42 '*) ;; *) printf '%s\n' "$output"; exit 1 ;; esac

# A relocated image owns its own output vector and produces the same frame.
output=$("$runtime" ": panel.example s\" body\" s\" Relocated\" tui.frame ; rebuild dup image.seal dup ' panel.example image.call image.free depth .")
case "$output" in *'Relocated'*'body'*'0 '*) ;; *) printf '%s\n' "$output"; exit 1 ;; esac
printf 'Native frames, plain output, fault cleanup and relocated output routing passed.\n'

# CLEAR emits erase-display and cursor-home sequences without changing the stack.
"$runtime" '42 clear . depth .' > "$work/clear"
printf '\033[2J\033[H42 0 ' > "$work/clear.expected"
cmp "$work/clear.expected" "$work/clear"
