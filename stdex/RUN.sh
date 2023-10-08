#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$DIR"
rm -f *.out

ok=0
fail=0
for i in *.toml; do
   ../toml_cat $i >& $i.out
   if [ -f $i.res ]; then
      if $(diff $i.out $i.res >& /dev/null); then
        ok=$(( ok + 1 ))
      else
        fail=$(( fail + 1 ))
        echo >&2 "$0: $i [FAILED]"
        diff -u $i.out $i.res >&2
        echo >&2
      fi
   else
      echo "$i [?????]"
      fail=$(( fail + 1 ))
   fi
done

echo "$0: ok: $ok  fail: $fail"