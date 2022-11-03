# background color using ANSI escape

_BG_BLACK=$(tput setab 0) # black
_BG_RED=$(tput setab 1) # red
_BG_GREEN=$(tput setab 2) # green
_BG_YELLOW=$(tput setab 3) # yellow
_BG_BLUE=$(tput setab 4) # blue
_BG_MAGENTA=$(tput setab 5) # magenta
_BG_CYAN=$(tput setab 6) # cyan
_BG_WHITE=$(tput setab 7) # white

# foreground color using ANSI escape

_FG_BLACK=$(tput setaf 0) # black
_FG_RED=$(tput setaf 1) # red
_FG_GREEN=$(tput setaf 2) # green
_FG_YELLOW=$(tput setaf 3) # yellow
_FG_BLUE=$(tput setaf 4) # blue
_FG_MAGENTA=$(tput setaf 5) # magenta
_FG_CYAN=$(tput setaf 6) # cyan
_FG_WHITE=$(tput setaf 7) # white

# text editing options

_TX_BOLD=$(tput bold)   # bold
_TX_HALF=$(tput dim)    # half-bright
_TX_UNDERLINE=$(tput smul)   # underline
_TX_ENDUNDER=$(tput rmul)   # exit underline
_TX_REVERSE=$(tput rev)    # reverse
_TX_STANDOUT=$(tput smso)   # standout
_TX_ENDSTAND=$(tput rmso)   # exit standout
_TX_RESET=$(tput sgr0)   # reset attributes
