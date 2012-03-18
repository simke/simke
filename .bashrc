#!/bin/bash
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


PS1='\[\e[0;34m\]\u\[\e[m\] \[\e[1;31m\]\w\[\e[m\] 
\[\e[1;34m\]\$\[\e[m\] \[\e[1;37m\]'

complete -cf sudo
complete -cf gksu

export EDITOR=vim
export SUDO_EDITOR="/usr/bin/vim -p -X"
export BROWSER=firefox
export LESS="-R"
export VARIABLE=content

s() { su -c "$*";}

alias p='sudo pacman-color'
alias S='sudo pacman-color -S --needed'
alias Ss='pacman-color -Ss'
alias Q='pacman-color -Q'
alias Qi='pacman-color -Qi'
alias R='sudo pacman-color -Run'
alias Ra='sudo pacman-color -Runsc'
alias Syu='sudo pacman-color -Syu'
alias popt='sudo pacman-optimize'
alias rmdblck='sudo rm /var/lib/pacman/db.lck'
alias y='yaourt'
alias yy='yaourt -Syua'
alias pacdif='sudo pacdiffviewer'

alias ..='cd ..'
alias ...='cd ../..'
alias xx='exit'
alias cd~='cd ~/'
alias cdetc='cd /etc'
alias cdusr='cd /usr'
alias cdvar='cd /var'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -p'
alias ls='ls -hF --color=auto --group-directories-first '
alias grep='grep --color=auto'
alias ll='ls -l'
alias la='ls -al | less'
alias l.='ls -d .[[:alnum:]]* 2> /dev/null || echo "No hidden file here..."'

alias h='history'
alias hist='history | grep $1'
alias path='echo -e ${PATH//:/\\n}'
alias dF='df -kTh'
alias swap='sudo swapoff -a && swapon -a'
alias off='sudo shutdown'
alias reb='sudo reboot'
alias tresh='sudo rm -r -f /home/simke/.local/share/Trash'
alias ping='ping -c 4 www.google.com'
alias alijas='cat ~/.bashrc | grep alias'
alias wlanauto='sudo iwconfig wlan0 rate 5.5M auto'
alias wlanfix='sudo iwconfig wlan0 rate 5.5M fixed'
alias up='cd "$(ls -d */ | dmenu -i)"'
alias pp='ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command'
alias pg='ps -Af | grep $1'
alias ii='netstat -pan --inet'
alias gita='git add -A'
alias gitc="git commit -m 'editirano'"
alias gitp='git push -u origin master'
alias awe='awesome -k rc.lua'
alias xdg='xdg_menu --format awesome --root-menu /etc/xdg/menus/xfce-applications.menu >> ~/.config/awesome/xdg-menu.lua'
alias xdg-arch='xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu >> ~/.config/awesome/menu.lua'
alias monitor='xset dpms'

ppp() {
	sudo pppoe-stop
	sudo pppoe-start;
}

rprobe() {
	sudo modprobe -r $1 && sudo modprobe $1;
}
wprobe() {
	sudo rmmod $1 && sudo modprobe $1 && sudo modprobe rtap_iface=$2 $1;
}
chscr() {
	sudo chmod +x ~/.scripts/$1;
}
tintre() {
	killall -e tint2;
	killall -e perl /usr/share/volwheel/volwheel;
	tint2;
	/usr/bin/volwheel;
	exit
}
goto() {
	[ -d "$1" ] && cd "$1" || cd "$(dirname "$1")";
}

cdl() {
	builtin cd $@ && ls
}
cpf() {
	if [[ -d $*[-1] ]]; then
		cp $* && cd $*[-1]
	elif [[ -d ${*[-1]%/*} ]]; then
		cp $* && cd ${*[-1]%/*}
	fi
}
mvf() {
	if [[ -d $*[-1] ]]; then
		mv $* && cd $*[-1]
	elif [[ -d ${*[-1]%/*} ]]; then
		mv $* && cd ${*[-1]%/*}
	fi
}
del() {
	mv "$@" "/${HOME}/.local/share/Trash/files/"
}
ff() {
	/usr/bin/find . -name "$@" ;
}
ffe() {
	/usr/bin/find . -name '*'"$@" ;
}
ffs() {
	/usr/bin/find . -name "$@"'*' ;
}
extract() {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2) tar xvjf $1 ;;
			*.tar.gz) tar xvzf $1 ;;
			*.bz2) bunzip2 $1 ;;
			*.rar) unrar x $1 ;;
			*.gz) gunzip $1 ;;
			*.tar) tar xvf $1 ;;
			*.tbz2) tar xvjf $1 ;;
			*.tgz) tar xvzf $1 ;;
			*.zip) unzip $1 ;;
			*.Z) uncompress $1 ;;
			*.7z) 7z x $1 ;;
			*) echo "'$1' cannot be extracted via >extract<" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}
compress() {
	FILE=$1
	case $FILE in
		*.tar.bz2) shift && tar cjf $FILE $* ;;
		*.tar.gz) shift && tar czf $FILE $* ;;
		*.tgz) shift && tar czf $FILE $* ;;
		*.zip) shift && zip $FILE $* ;;
		*.rar) shift && rar $FILE $* ;;
	esac
}


