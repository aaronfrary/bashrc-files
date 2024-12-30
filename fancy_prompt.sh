
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_DESCRIBE_STYLE="branch"

# Keep working directory description to a reasonable length.
abbrev_home_dir() {
  # Recreate '\w' home dir replacement
  local dir=`pwd`
  if [[ $dir =~ ^$HOME($|\/) ]]; then
    dir="~${dir#$HOME}"
  fi
  echo $dir
}

shorten_dir() {
  local dir=$1
  local maxlen=$2

  local end='/'
  if [ $dir = "/" ]; then
    end=''
  fi

  local slashes=${dir//[^\/]}
  local depth=$((1 + ${#slashes}))

  # Abbreviate until short enough
  local beginning=
  local middle=
  local end=
  local i=2
  while [[ $i -lt $depth && ${#dir} -gt $maxlen ]]; do
    beginning=`echo $dir | cut -d / -f 1-$(($i - 1))`
    middle=`echo $dir | cut -d / -f $i`
    end=`echo $dir | cut -d / -f $(($i + 1))-$depth`
    dir=$beginning'/'${middle:0:2}'/'$end
    i=$(($i+1))
  done

  echo $dir
}

# Main function for the prompt.
prompt() {
  # Check exit code before running any commands.
  local exit_code="$?"

  local max5=`tput cols`
  local max1=$(($max5 / 5))
  local max2=$(($max1 + $max1))
  local max3=$(($max2 + $max1))
  local max4=$(($max2 + $max2))

  # __git_ps1 is defined in git-prompt.sh
  local git=`__git_ps1 "%s"`
  local gitlen=${#git}

  local dir=`abbrev_home_dir`
  local dirlen=${#dir}

  local len=$(($gitlen + $dirlen))

  local br1=
  local br2=

  if [[ $gitlen -gt $max3 ]]; then
    br2='\n'
    if [[ $len -gt $max4 ]]; then
      br1='\n'
    fi
  elif [[ $len -gt $max3 ]]; then
    dir=`shorten_dir $dir $max2`
    len=$(($gitlen + ${#dir}))
    if [[ $len -gt $max4 ]]; then
      br1='\n'
    elif [[ $len -gt $max3 ]]; then
      br2='\n'
    fi
  fi

  local working_dir='['%F{cyan}$dir%f

  local git_info=
  if [[ -n "$git" ]]; then
    git_info=$br1'|'%F{yellow}$git%f
  fi

  local last_status=
  if [ $exit_code -ne 0 ]; then
    last_status=%F{red}'#'%f%F{white}$exit_code%f
  fi

  local prompt_char=%F{white}'$'%f
  if [ `id -u` = 0 ]; then
    prompt_char=%F{red}'#'%f
  fi
  local prompt_end=']'$br2$prompt_char' '

  PS1=$last_status$working_dir$git_info$prompt_end
}

# bash
PROMPT_COMMAND=prompt

# zsh
precmd () { prompt }
