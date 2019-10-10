if ! (which jq >& /dev/null); then 
    echo "ERROR: please install the 'jq' utility"
    exit 1
fi

#
#  POSITIVE tests
#
for i in toml-spec-tests/values/*.toml; do
    echo -n $i ' '
    res='[OK]'
    if (../toml_json $i >& $i.json.out); then 
        jq . $i.json.out > t.json
	mv t.json $i.json.out
	if [ -f $i.json ] && (diff $i.json $i.json.out >& /dev/null); then 
	    res='[FAILED]'
	fi
    fi
    echo $res
done


#
#  NEGATIVE tests
#
for i in toml-spec-tests/errors/*.toml; do 
    echo -n $i ' '
    if (../toml_json $i >& $i.json.out); then 
	echo '[FAILED]'
    else
	echo '[OK]'
    fi

done
