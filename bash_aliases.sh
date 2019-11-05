alias ls='ls -GFh'
alias la='ls -a'
alias ll='ls -l'

alias xvim='xargs -o nvim -p'
alias vim='nvim'
alias vimconfig='nvim ~/.config/nvim/vimrc'

cd_to_git_root() {
  local dir=
  while : ; do
    dir=`pwd`
    [ -d ".git" ] && break;
    [ $dir = "/" ] && break;
    cd ..
  done
}

alias cdr='cd_to_git_root'
