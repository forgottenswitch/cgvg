#!/bin/sh

stashfile=/tmp/.cgvg."$USER"

if test _0 = _"$#" ; then
  exec cat "$stashfile"
fi

# Determine the grep tool
for grepper in rg ag grep; do
  type "$grepper" >/dev/null 2>&1 && break
done
profiledir="$HOME/.config/cgvg/$grepper"

args_from_profile=""

if test _"${1#-p}" != _"$1" ; then
  usage_p() {
    echo "Usage: cg -p"
    echo "       cg -pp [PROFILE]"
    echo "       cg -pPROFILE_TO_USE ..."
    echo "       cg -p+ PROFILE OPTION_TO_ADD..."
    echo "       cg -p- PROFILE OPTION_TO_REMOVE..."
    echo "       cg -p-rm PROFILE_TO_REMOVE..."
    echo
  }

  if test _"-p" = _"$1" ; then
    usage_p

    echo "Profiles:"
    mkdir -p "$profiledir"
    ls "$profiledir" |
    sed -e '
      # remove colors
      s/\x1b\[[0-9]*m//g

      # indent
      s/^/  /
    '
    exit
  fi

  test_profile_exists() {
    if test ! -e "$profilefile" ; then
      echo "Profile '$profilefile' does not exist"
      exit 1
    fi
  }

  set_profilefile() {
    # ensure profile is not a path
    profile="${profile##*[/\\]}"
    profilefile="$profiledir"/"$profile"
  }

  if test _"-p-rm" = _"$1" ; then
    if test _$# = _0 ; then
      usage_p
      exit 1
    fi
    # remove profiles
    for profile ; do
      set_profilefile
      test_profile_exists
      rm "$profilefile"
    done
    exit
  fi

  profile_command="$1"
  shift

  shift_profile() {
    profile="$1"
    if test $# -lt 1 ; then
      usage_p
      exit 1
    fi
    shift
  }

  case "$profile_command" in
    -p-) # remove options from profile
      shift_profile
      set_profilefile
      s_prog=""
      for arg ; do
        # escape slashes
        arg=$(echo "$arg" | sed -e 's|/|\x31|')
        # put escaped $arg into sed regex
        s_prog="$s_prog
          /^$arg\$/ D;
          "
      done
      test_profile_exists
      sed -i -e "$s_prog" "$profilefile"
      exit
      ;;
    -p+) # add options to profile
      shift_profile
      set_profilefile
      mkdir -p "$profiledir"
      test -e "$profilefile" || printf '' > "$profilefile"
      for arg ; do
        if ! grep -q -F "$arg" "$profilefile" ; then
          echo "$arg" >> "$profilefile"
        fi
      done
      exit
      ;;
    -pp) # print profiles
      print_profile() {
        echo "$1:"
        sed -e 's/^/  /' "$profiledir"/"$1"
      }
      if test _$# = _0 ; then
        ls "$profiledir" |
        while read profile ; do
          print_profile "$profile"
        done
      fi
      for profile ; do
        set_profilefile
        test_profile_exists
        print_profile "$profile"
      done
      exit
      ;;
    *)
      profile="${profile_command#-p}"
      set_profilefile
      # quote the lines of profile
      args_from_profile=$(
        awk '
          {
            gsub("'"'"'", "&\"&\"&")
            printf " '"'"'" $0 "'"'"'"
          }
        ' "$profilefile"
      )
      # strip trailing backslash
      args_from_profile="${args_from_profile% \\}"
      ;;
  esac
fi

color_reset='\033[0m'

idx_filter() {
  # tell vg the current dir
  pwd
  echo

  read line
  echo "$line"
  printf "$color_reset"

  case "$line" in
    Invalid*|Usage*) exec cat ;;
  esac

  curfile="$line"
  line_idx=1

  while read line ; do
    if test -z "$line" ; then
      echo
      curfile=""
    elif test -z "$curfile" ; then
      curfile="$line"
      echo "$line"
      printf "$color_reset"
    else
      echo "  $line_idx	$line"
      line_idx=$((line_idx+1))
    fi
  done
}

grepper_flags=""
case "$grepper" in
  rg|*/rg) grepper_flags="-p" ;;
  ag|*/ag) grepper_flags="--color -H" ;;
  grep|*/grep)
    grepper_flags="--color=always -n -H -s -r . --binary-files=without-match -e"

    idx_filter() {
      pwd
      echo

      read line

      case "$line" in
        Usage*) exec cat ;;
      esac

      curfile="${line%%:*}"
      match="${line#*:}"
      curfile1=""

      echo "$curfile"
      printf "$color_reset"
      match_idx=1
      echo "  $match_idx	$match"

      while read line ; do
        match_idx=$((match_idx+1))
        curfile1="$curfile"
        curfile="${line%%:*}"
        match="${line#*:}"

        if test _"$curfile1" != _"$curfile" ; then
          echo
          #echo ":: $curfile1 != $curfile" | hexdump -C
          echo "$curfile"
          printf "$color_reset"
        fi

        echo "  $match_idx	$match"
      done
    }

    ;;
esac

pager_flags=""
PAGER="${PAGER:-less}"
case "$PAGER" in
  less|*/less) pager_flags="-R" ;;
esac

#echo "$grepper $grepper_flags $args_from_profile \"\$@\""
#exit 1

eval "$grepper $grepper_flags $args_from_profile \"\$@\"" |
idx_filter | tee "$stashfile" |
"${PAGER}" $pager_flags
