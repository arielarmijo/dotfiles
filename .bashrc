#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\e[1;32m\]\u\[\e[1;37m\]@\[\e[1;35m\]\h \[\e[1;37m\]\w \$\[\e[0m\] '

complete -cf sudo

alias ls='ls --color=auto'
alias clean='sudo pacman -Rns $(pacman -Qtdq)'
alias bt='bluetoothctl'
alias nf='neofetch'
