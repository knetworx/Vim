# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Get the actual source location of this script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo "Sourcing: $DIR/.bashrc"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# My custom file for making environment-dependent settings
myenv=''
# Since the current file may be shared between different types of machines, Put the
# .bash_os_env file in your home dir, rather than the same dir as the current script
if [ -f ~/.bash_os_env ]; then
	. ~/.bash_os_env
fi

if [ -z $myenv ]; then
	echo "WARNING: .bash_os_env doesn't exist or \$myenv has not been set!!!"
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# Alias definitions.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f $DIR/.bash_aliases ]; then
    . $DIR/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -d $DIR/bash_completion ] && ! shopt -oq posix; then
	for f in $DIR/bash_completion/*
	do
		echo "Processing completion file $f"
		. $f
	done
fi

colors=1
if [ -f $DIR/colors.bash ]; then
	echo "Initializing colors from $DIR/colors.bash"
	. $DIR/colors.bash
else
	colors=0
	echo "Colors not found in $DIR"
fi

hostname="\H"
# Optional: Show the computer's human-readable name
# Note: Mac hostname can be set via "sudo scutil --set HostName new_hostname"
#if [ $myenv == "mac" ]; then
#	hostname=`(scutil --get ComputerName)`
#fi

#export PS1='[\[\033[41;1m\] LIVE \[\033[0m\]] \u@\h:\w$ '
if [ colors ]; then
	# Set a nice pretty prompt
	PS1="\[$txtred\](\T) \[$txtcyn\]\u@$hostname \[$txtgrn\]\W \$\[$txtrst\] "
else
	# Set a boring old plain text prompt
	PS1="(\T) \u@$hostname \W \$ "
fi

# Add Set the terminal title
PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\W\a\]$PS1"

export GREP_OPTIONS='--color=auto'

# Note: Other export commands are in .profile

# See: http://en.wikipedia.org/wiki/ANSI_escape_code

#Colors
#		 fg 30+ / bg 40+
# black			0
# red			1
# green			2
# yellow		3
# blue			4
# magenta		5
# cyan			6
# white			7
#export GREP_COLOR='1;34'
export GREP_COLOR='0;32'

if [ $myenv == 'mac' ]; then
	function ff { osascript -e 'tell application "Finder"'\
		-e "if (${1-1} <= (count Finder windows)) then"\
		-e "get POSIX path of (target of window ${1-1} as alias)"\
		-e 'else' -e 'get POSIX path of (desktop as alias)'\
		-e 'end if' -e 'end tell'; };\
	
	function cdff { cd "`ff $@`"; };
fi

if [ $myenv == 'mac' ]; then
	tellresult() {
		if [ $? -eq 0 ]; then
			say "build complete"
		else
			say "build failed"
		fi
	}

	svndiff() {
		svn diff "${@}" | colordiff 
	}
fi

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
