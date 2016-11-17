#!/bin/sh

stashfile=/tmp/.cgvg."$USER"

if test _"0" = _"$#" ; then
  exit 1
fi

n="$1"

cwd_and_file_and_line=$(
  sed -e '
    s/\x1b\[[0-9;]*m//g
    s/\x1b\[K//g
  ' "$stashfile" | # remove colors
  {
  # read cg invocation dir
  read line
  echo "$line"

  while read line ; do
    #echo __ "$line [$line_n || $n]"
    if test -z "$line" ; then
      file=""
    elif test -z "$file" ; then
      file="$line"
    else
      line_n="${line%%	*}"
      #echo == "$line [$line_n || $n]"
      if test _"$line_n" = _"$n" ; then
        echo "$line" | {
          read line_n line
          #echo "// $file //"
          #echo "{{ ${line%%:*} }}"
          echo "$file"
          echo "${line%%:*}"
        }
        break
      fi
    fi
  done
  }
)

#echo ---
#echo "$cwd_and_file_and_line"
#echo ---
#exit 1

cwd="${cwd_and_file_and_line%%
*}"
file_and_line="${cwd_and_file_and_line#*
}"
file="${file_and_line%%
*}"
line="${file_and_line#*
}"

#echo ":: $file :: $line"
#exit 1

#echo "$line" | hexdump -C
#exit 1

if test ! -z "$file" -a ! -z "$line" -a _$((line)) = _"$line" ; then
  cd "$cwd" || exit 1
  exec "${EDITOR:-vi}" "$file" +"$line"
else
  echo "error: no such N - $n (try 'cg')"
fi
