#! /bin/bash

function install_debian() {
# Installation prereqs
apt-get install apt-transport-https ca-certificates debhelper debsums curl wget gnupg2 software-properties-common


# Basic dev stuff
apt-get install --assume-yes \
	fish \
	zsh \
	htop \
	dstat \
	atop \
	git \
	vim \
	locate \
	linux-perf \
	gcc \
	python3-setuptools \
	python3-pip \

# Terminal utils
apt-get install --assume-yes \
	command-not-found \
	python3-pygments \
	tmux \
	tig \
	zsh-syntax-highlighting \


# VM tools
apt-get install --assume-yes open-vm-tools

# UI
apt-get install --assume-yes \
	fonts-open-sans \
	ttf-mscorefonts-installer

# Docker install
apt-get remove --purge docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-get install --assume-yes docker-ce

}

#install_debian

function install_rc() {

MY_DIR=xirafa
mkdir -p ~/.$MY_DIR
rm -f ~/.$MY_DIR/*

cat > ~/.$MY_DIR/commonrc << EOFFF
# aliases
alias grep='grep --color=auto'
alias g='grep -ina --color=auto'
alias gv='grep -vi'
alias rm='rm --one-file-system'

alias ll='ls -lAF --color=auto'
alias l='ls -lAF --color=auto'
alias ltr='ls -ltrFa --color=auto'
alias ls='ls -F'
alias rm='rm --one-file-system'

alias '..'='cd ..'
alias vi=vim
alias tf='tail -f'
alias gdb='gdb -silent'

export EDITOR=vim

EOFFF

cat > ~/.$MY_DIR/shrc << EOFFF
alias -- -='less -niSR'
alias j='jobs -l'

function p() { ps -ef | grep -i \$@ | grep -v grep ; }

# prettier output for 'mount'
function _mount
{
    if [ -z "\$1" ]; then
	command mount | column -t
    else
	command mount "\$@"
    fi
}
alias mount='_mount'

export EDITOR=vim

EOFFF


cat > ~/.$MY_DIR/bashrc << EOFFF
stty -ixon
shopt -s autocd 		# cd to dirname when just dirname is given as command
shopt -s checkjobs 		# Notify existing jobs before exit
#shopt -s failglob
shopt -s histappend 	# Append to bash history file
#eval "\$(SHELL=/bin/sh lesspipe)"
alias which='type --all'
set -o ignoreeof		# ^D doesnt exit
set -o notify			# Don't wait for next prompt to print job exit status
set mark-symlinked-directories on
set completion-ignore-case on

if [ -n "\$PS1" ]; then
    PS1='\[\033[42;37;1m\]\u@\H\[\033[0m\] \[\033[44;37;1m\]\w\[\033[0m\] \\\$ '
fi

source ~/.$MY_DIR/commonrc
source ~/.$MY_DIR/shrc

EOFFF


# Write zshrc
cat > ~/.$MY_DIR/zshrc << EOFFF

source ~/.$MY_DIR/commonrc
source ~/.$MY_DIR/shrc
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias which='whence -ca'
setopt ignoreeof

if [ -n "\$PS1" ]; then
   PS1='%(?..%B%F{white}%K{red}$?%f%k )%B%F{white}%K{green}%n@%m%f%k%b %B%F{white}%K{blue}%~%f%k%b%# '
fi

# For some reason, /etc/zsh_command_not_found uses "--no-failure-msg". Do this instead.
function command_not_found_handler {
    /usr/lib/command-not-found -- \${1+"\$1"}
}

EOFFF

# Write fishrc
cat > ~/.$MY_DIR/fishrc << EOFFF

source ~/.$MY_DIR/commonrc
alias which='type -a'
alias j='jobs'

function p
	ps -ef | grep -i \$argv[1]
end

function mount
    if test (count \$argv) -gt 0
        command mount \$argv
    else
        command mount | column -t
    end
end

function fish_prompt --description 'Write out the prompt'
    set -l color_cwd
    set -l suffix
    switch "\$USER"
        case root toor
	    set color_cwd yellow
            set suffix '#'
        case '*'
            set color_cwd blue
            set suffix '>'
    end

    set -l last_status \$status
    set -l prompt_status ""
    if test \$last_status != 0
	set prompt_status (set_color -b red) (set_color -o white) \$last_status (set_color normal) ' '
    end

    echo -n -s \$prompt_status (set_color -o white) (set_color -b green) "\$USER" @ (prompt_hostname) (set_color normal) ' ' (set_color -o white) (set_color -b \$color_cwd) (prompt_pwd) (set_color normal) "\$suffix "
end

EOFFF


# Fish setup
if [ ! -s /usr/local/bin/- ]; then
	ln -s $(which less) /usr/local/bin/-
fi
touch ~/.config/fish/config.fish
grep -q $MY_DIR/fishrc ~/.config/fish/config.fish || echo "source ~/.$MY_DIR/fishrc" >> ~/.config/fish/config.fish

curl -Lo ~/.config/fish/functions/humanize_duration.fish --create-dirs https://raw.githubusercontent.com/fishpkg/fish-humanize-duration/master/humanize_duration.fish
curl -Lo ~/.config/fish/conf.d/done.fish --create-dirs https://raw.githubusercontent.com/franciscolourenco/done/master/conf.d/done.fish


# zshrc setup
set +x
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
set -x
touch ~/.zshrc
grep -q $MY_DIR/zshrc ~/.zshrc || echo "source ~/.$MY_DIR/zshrc" >> ~/.zshrc
sed -i 's/^plugins=.*/plugins=(git colored-man-pages colorize docker systemd)/' ~/.zshrc


# bash setup
touch ~/.bashrc
grep -q $MY_DIR/bashrc ~/.bashrc || echo "source ~/.$MY_DIR/bashrc" >> ~/.bashrc

}


# Run stuff
set -x

#install_debian
install_rc

# File indexing
# updatedb

set +x
echo ""
echo "=TODOs="
echo "Install gnome extension: https://extensions.gnome.org/extension/1160/dash-to-panel/"
echo "sudo visudo, then paste: $USER ALL=(ALL) NOPASSWD:ALL"

