# oh-my-zsh Zanzibar Theme
# Author: Jeppe Klitgaard - "Dkkline"
# Feel free to contact me at jeppe@dapj.dk if you have any questions/requests/etc.

# Bits of code shamelessly stolen from the Bureau Theme as well as the Robbyrussell Theme

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

zanzibar_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

zanzibar_git_status () {
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  _STATUS=""
  if $(echo "$_INDEX" | grep '^[AMRD]. ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi
  if $(echo "$_INDEX" | grep '^.[MTD] ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi
  if $(echo "$_INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi
  if $(echo "$_INDEX" | grep '^UU ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi
  if $(echo "$_INDEX" | grep '^## .*ahead' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | grep '^## .*behind' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | grep '^## .*diverged' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  echo $_STATUS
}

zanzibar_git_prompt () {
  local _branch=$(zanzibar_git_branch)
  local _status=$(zanzibar_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

## SEPARATOR LINE
_SEP_LINE=""

## STATUS LINE
if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
else
  _USERNAME="%{$fg_bold[green]%}%n"
fi
_USERNAME="$_USERNAME%{$reset_color%}"

_PATH="%{$fg[yellow]%}%~%{$reset_color%}"

get_python_version () {
    echo `python -V 2>&1|grep -Po '\d\.\d'`
}

virtualenv_prompt_info () {
  [[ -n ${VIRTUAL_ENV} ]] || return
  echo "[%{$fg_bold[green]%}${VIRTUAL_ENV:t}%{$reset_color%}|%{$fg[yellow]%}py$(get_python_version)%{$reset_color%}]"
}

get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  for i in {0..$LENGTH}
    do
      SPACES="$SPACES "
    done

  echo $SPACES
}

## PROMPT
_RET_STATUS="%(?:%{$fg[green]%}$ :%{$fg[red]%}$ %s)"
_RET_STATUS="$_RET_STATUS%{$reset_color%}"

_PROMPT="> $_RET_STATUS "

zanzibar_precmd () {
  _1LEFT="$_USERNAME in $_PATH"
  print
  print -rP "$_1LEFT$(get_space $_1LEFT $(virtualenv_prompt_info))$(virtualenv_prompt_info)"
}

setopt prompt_subst
PROMPT='$_PROMPT'
RPROMPT='$(zanzibar_git_prompt)'
autoload -U add-zsh-hook
add-zsh-hook precmd zanzibar_precmd
