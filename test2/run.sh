#
#  POSITIVE tests
#
for i in toml-spec-tests/values/*.toml; do
    echo -n $i ' '
    ../toml_json $i >& $i.json.out
    rc=$?
    [ -f $i.json ] && diff=$(diff $i.json $i.json.out) || diff=''
    if [ "$rc" != "0" ] || [ "$diff" != "" ]; then
	echo '[FAILED]'
    else
	echo '[OK]'
    fi
done


#
#  NEGATIVE tests
#
for i in toml-spec-tests/errors/*.toml; do 
    echo -n $i ' '
    ../toml_json $i >& $i.json.out
    rc=$?
    
    if [ "$rc" != "0" ]; then
	echo '[OK]'
    else
	echo '[FAILED]'
    fi

done
