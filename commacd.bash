# commacd - a faster way to move around (Bash 3+).
# https://github.com/shyiko/commacd
#
# ENV variables that can be used to control commacd:
#   COMMACD_CD - function to change the directory (by default commacd uses builtin cd and pwd)
#   COMMACD_NOTTY - set it to "on" when you want to suppress user input (= print multiple matches and exit)
#   COMMACD_NOFUZZYFALLBACK - set it to "on" if you don't want commacd to use "fuzzy matching" as a fallback for
#     "no matches by prefix" (introduced in 0.2.0)
#   COMMACD_SEQSTART - set it to 1 if you want "multiple choices" to start from 1 instead of 0
#
# @version 0.3.3
# @author Stanley Shyiko <stanley.shyiko@gmail.com>
# @license MIT

# turn on case-insensitive search by default
shopt -s nocaseglob

_commacd_split() {
  # shellcheck disable=SC2001
  echo "$1" | sed $'s|/|\\\n/|g'
}
_commacd_join() { local IFS="$1"; shift; echo "$*"; }
_commacd_expand() ( shopt -s extglob nullglob; local ex=($1); printf "%s\n" "${ex[@]}"; )

_command_cd() {
  local dir=$1 IFS=$' \t\n'
  if [[ -z "$COMMACD_CD" ]]; then
    builtin cd "$dir" && pwd
  else
    $COMMACD_CD "$dir"
  fi
}

# show match selection menu
_commacd_choose_match() {
  local matches=("$@")
  for i in "${!matches[@]}"; do
    printf "%s\t%s\n" "$((i+${COMMACD_SEQSTART:-0}))" "${matches[$i]}" >&2
  done
  local selection;
  read -e -p ': ' selection >&2
  if [[ -n "$selection" ]]; then
    echo -n "${matches[$((selection-${COMMACD_SEQSTART:-0}))]}"
  else
    echo -n "$PWD"
  fi
}

_commacd_prefix_glob() (
  set -f
  local path="${*%/}/" IFS=$'\n'
  # shellcheck disable=SC2046
  echo -n "$(_commacd_join \* $(_commacd_split "$path"))"
)

_commacd_glob() (
  set -f
  local path="${*%/}" IFS=$'\n'
  if [[ "${path/\/}" == "$path" ]]; then
    path="*$path*/"
  else
    # shellcheck disable=SC2046
    path="$(_commacd_join \* $(_commacd_split "$path") | rev | sed 's/\//*\//' | rev)*/"
  fi
  echo -n "$path"
)

_commacd_forward_by_prefix() {
  local matches=($(_commacd_expand "$(_commacd_prefix_glob "$*")"))
  if [[ -z "$COMMACD_NOFUZZYFALLBACK" && ${#matches[@]} -eq 0 ]]; then
    matches=($(_commacd_expand "$(_commacd_glob "$*")"))
  fi
  case ${#matches[@]} in
    0) echo -n "$PWD";;
    *) printf "%s\n" "${matches[@]}"
  esac
}

# jump forward (`,`)
_commacd_forward() {
  if [[ -z "$*" ]]; then return 1; fi
  local IFS=$'\n'
  local dir=($(_commacd_forward_by_prefix "$@"))
  if [[ "$COMMACD_NOTTY" == "on" ]]; then
    printf "%s\n" "${dir[@]}"
    return
  fi
  if [[ ${#dir[@]} -gt 1 ]]; then
    # https://github.com/shyiko/commacd/issues/12
    trap 'trap - SIGINT; stty '"$(stty -g)" SIGINT

    dir=$(_commacd_choose_match "${dir[@]}")

    # make sure trap is removed regardless of whether read -e ... was interrupted or not
    trap - SIGINT
    if [[ -z "$dir" ]]; then return 1; fi
  fi
  _command_cd "$dir"
}

# search backward for the vcs root (`,,`)
_commacd_backward_vcs_root() {
  local dir="${PWD%/*}"
  while [[ ! -d "$dir/.git" && ! -d "$dir/.hg" && ! -d "$dir/.svn" ]]; do
    dir="${dir%/*}"
    if [[ -z "$dir" ]]; then
      echo -n "$PWD"
      return
    fi
  done
  echo -n "$dir"
}

# search backward for the directory whose name begins with $1 (`,, $1`)
_commacd_backward_by_prefix() {
  local prev_dir dir="${PWD%/*}" matches match IFS=$'\n'
  while [[ -n "$dir" ]]; do
    prev_dir="$dir"
    dir="${dir%/*}"
    matches=($(_commacd_expand "$dir/${1}*/"))
    for match in "${matches[@]}"; do
        if [[ "$match" == "$prev_dir/" ]]; then
          echo -n "$prev_dir"
          return
        fi
    done
  done
  # at this point there is still a possibility that $1 is an actual path (passed in
  # by completion or whatever), so let's check that one out
  if [[ -d "$1" ]]; then echo -n "$1"; return; fi
  # otherwise fallback to pwd
  echo -n "$PWD"
}

# replace $1 with $2 in $PWD (`,, $1 $2`)
_commacd_backward_substitute() {
  echo -n "${PWD/$1/$2}"
}

# choose `,,` strategy based on a number of arguments
_commacd_backward() {
  local dir=
  case $# in
    0) dir=$(_commacd_backward_vcs_root);;
    1) dir=$(_commacd_backward_by_prefix "$*")
       if [[ -z "$COMMACD_NOFUZZYFALLBACK" && "$dir" == "$PWD" ]]; then
         dir=$(_commacd_backward_by_prefix "*$*")
       fi;;
    2) dir=$(_commacd_backward_substitute "$@");;
    *) return 1
  esac
  if [[ "$COMMACD_NOTTY" == "on" ]]; then
    echo -n "${dir}"
    return
  fi
  _command_cd "$dir"
}

_commacd_backward_forward_by_prefix() {
  local dir="$PWD" path="${*%/}/" matches match IFS=$'\n'
  if [[ "${path:0:1}" == "/" ]]; then
    # assume that we've been brought here by the completion
    dir=(${path%/}*)
    printf "%s\n" "${dir[@]}"
    return
  fi
  while [[ -n "$dir" ]]; do
    dir="${dir%/*}"
    matches=($(_commacd_expand "$dir/$(_commacd_prefix_glob "$*")"))
    if [[ -z "$COMMACD_NOFUZZYFALLBACK" && ${#matches[@]} -eq 0 ]]; then
      matches=($(_commacd_expand "$dir/$(_commacd_glob "$*")"))
    fi
    case ${#matches[@]} in
      0) ;;
      *) printf "%s\n" "${matches[@]}"
         return;;
    esac
  done
  echo -n "$PWD"
}

# combine backtracking with `, $1` (`,,, $1`)
_commacd_backward_forward() {
  if [[ -z "$*" ]]; then return 1; fi
  local IFS=$'\n'
  local dir=($(_commacd_backward_forward_by_prefix "$@"))
  if [[ "$COMMACD_NOTTY" == "on" ]]; then
    printf "%s\n" "${dir[@]}"
    return
  fi
  if [[ ${#dir[@]} -gt 1 ]]; then
    dir=$(_commacd_choose_match "${dir[@]}")
  fi
  _command_cd "$dir"
}

_commacd_completion_invalid() {
  if [[ "$2" == "$PWD" || "${2// /\\ }" == "$1" ]]; then return 0; else return 1; fi
}

_commacd_completion() {
  local pattern=${COMP_WORDS[COMP_CWORD]} IFS=$'\n'
  # shellcheck disable=SC2088
  if [[ "${pattern:0:2}" == "~/" ]]; then
    # shellcheck disable=SC2116
    pattern=$(echo ~/"${pattern:2}")
  fi
  local completion=($(COMMACD_NOTTY=on $1 "$pattern"))
  if _commacd_completion_invalid "$pattern" "$completion"; then
    pattern="$pattern?"
    # retry with ? matching
    completion=($(COMMACD_NOTTY=on $1 "$pattern"))
    if _commacd_completion_invalid "$pattern" "$completion"; then
      return
    fi
  fi
  # remove trailing / (if any)
  for i in "${!completion[@]}"; do
    completion[$i]="${completion[$i]%/}";
  done
  COMPREPLY=($(compgen -W "$(printf "%s\n" "${completion[@]}")" -- ''))
}

_commacd_forward_completion() {
  _commacd_completion _commacd_forward
}

_commacd_backward_completion() {
  _commacd_completion _commacd_backward
}

_commacd_backward_forward_completion() {
  _commacd_completion _commacd_backward_forward
}

alias ,=_commacd_forward
alias ,,=_commacd_backward
alias ,,,=_commacd_backward_forward

complete -o filenames -F _commacd_forward_completion ,
complete -o filenames -F _commacd_backward_completion ,,
complete -o filenames -F _commacd_backward_forward_completion ,,,
