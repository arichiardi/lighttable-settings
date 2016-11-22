# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

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
# AR uncomment to use the git prompt
git_prompt=yes

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

if [ -n "git_prompt" ]; then
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWUNTRACKEDFILES=nonempty
    GIT_PS1_SHOWSTASHSTATE=nonempty
    GIT_PS1_SHOWDIRTYSTATE=nonempty
    PS1='\u@\h:\w$(__git_ps1 " (%s)")\$ '
else
    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

SSH_ENV="$HOME/.ssh/environment"

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
    echo succeeded
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
    ssh-add
}

# test for identities
function test_identities {
    # test whether standard identities have been added to the agent already
    ssh-add -l | grep "The agent has no identities" > /dev/null
    if [ $? -eq 0 ]; then
        ssh-add
        # $SSH_AUTH_SOCK broken so we start a new proper agent
        if [ $? -eq 2 ];then
            start_agent
        fi
    fi
}

# check for running ssh-agent with proper $SSH_AGENT_PID
if [ -n "$SSH_AGENT_PID" ]; then
    ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
    if [ $? -eq 0 ]; then
        test_identities
    fi
    # if $SSH_AGENT_PID is not properly set, we might be able to load one from
    # $SSH_ENV
else
    if [ -f "$SSH_ENV" ]; then
        . "$SSH_ENV" > /dev/null
    fi
    ps -ef | grep "$SSH_AGENT_PID" | grep -v grep | grep ssh-agent > /dev/null
    if [ $? -eq 0 ]; then
        test_identities
    else
        start_agent
    fi
fi

# From https://superuser.com/questions/509950/why-are-unicode-characters-not-rendering-correctly
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=en_US.UTF-8

# Idea
# From http://stackoverflow.com/questions/5124368/gradle-doesnt-work-in-intellij-problems-with-java-home
IDEA_JDK=/usr/lib/jvm/java-8-oracle

# Java 8
JAVA8_HOME=/usr/lib/jvm/java-8-oracle
NASHORN_HOME=/usr/lib/jvm/java-8-oracle/bin

# Git
source ~/bin/git/git-completion.bash
source ~/bin/git/git-prompt.sh

# Android SDK
ANDROID_HOME=/usr/local/share/android-sdk

# Path additions
PATH=$PATH:/usr/local/share/scala-2.10.3/bin:/usr/local/share/scala-2.10.3/sbt/bin:/usr/local/share/apache-maven/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools

# Clojure
export CLOJURE_EXT=$HOME/.m2/repository/org/clojure/clojure/1.6.0/clojure-1.6.0.jar
export CLOJURE_OPTS="-Xms128M -Xmx512M -server"

# Emacs default editor
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -t"
export VISUAL="emacsclient -c -a emacs"

# Misc
export XMLLINT_INDENT="  "
export GPGKEY=5BB502F6

function man () {
    if [ $TERM ]; then
        emacsclient -t -c -eval "(progn (setq Man-notify-method 'bully) (man \"$@\"))";
    else
        yelp "man:$@";
    fi
}

# unalias man
# alias man=emacs-man

export GEM_HOME=/home/kapitan/.gem/ruby/2.2.0

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
export COMP_WORDBREAKS

if type complete &>/dev/null; then
    _npm_completion () {
        local si="$IFS"
        IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                                         COMP_LINE="$COMP_LINE" \
                                         COMP_POINT="$COMP_POINT" \
                                         npm completion -- "${COMP_WORDS[@]}" \
                                         2>/dev/null)) || return $?
        IFS="$si"
    }
    complete -F _npm_completion npm
elif type compdef &>/dev/null; then
    _npm_completion() {
        si=$IFS
        compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                               COMP_LINE=$BUFFER \
                               COMP_POINT=0 \
                               npm completion -- "${words[@]}" \
                               2>/dev/null)
        IFS=$si
    }
    compdef _npm_completion npm
elif type compctl &>/dev/null; then
    _npm_completion () {
        local cword line point words si
        read -Ac words
        read -cn cword
        let cword-=1
        read -l line
        read -ln point
        si="$IFS"
        IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                                     COMP_LINE="$line" \
                                     COMP_POINT="$point" \
                                     npm completion -- "${words[@]}" \
                                     2>/dev/null)) || return $?
        IFS="$si"
    }
    compctl -K _npm_completion npm
fi
###-end-npm-completion-###

## From https://stackoverflow.com/questions/10081293/install-npm-into-home-directory-with-distribution-nodejs-package-ubuntu
NPM_PACKAGES="$HOME/.local/share/nodejs"
PATH="$NPM_PACKAGES/bin:$PATH"
MANPATH="$NPM_PACKAGES/share/man:$MANPATH"
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

# Leiningen
export LEIN_JVM_OPTS=
# MOVED TO /etc/bash_completion.d
# source ~/bin/lein_completion.bash

# Boot
export BOOT_JVM_OPTIONS="-Xmx1g -client -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xverify:none -XX:-OmitStackTraceInFastThrow"
export BOOT_COLOR=1

# Docker Remote API
# DOCKER_OPTS='-H tcp://localhost:4243 -H unix:///var/run/docker.sock'

# put /bin/node_modules executables in path

NODE_BIN_PATHS=$(find ~/bin/node_modules/ -type f -executable -exec dirname {} \; | grep bin$ | tr '\n' ':')
PATH="$PATH:$NODE_BIN_PATHS"