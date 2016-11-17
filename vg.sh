#!/bin/sh

stashfile=/tmp/.cgvg."$USER"

if test _"0" = _"$#" ; then
  exit 1
fi

n="$1"

file_and_line=$(
  sed -e 's/\x1b\[[0-9]\+m//g' "$stashfile" | # remove colors
  {
  read file
  line="$file"

  while read line ; do
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
#echo "$file_and_line"
#echo ---
#exit 1

file="${file_and_line%%
*}"
line="${file_and_line#*
}"

if test ! -z "$file" -a ! -z "$line" -a _$((line)) = _"$line" ; then
  exec "${EDITOR:-vi}" "$file" +"$line"
else
  echo "error: no such N - $n (try 'cg')"
fi
