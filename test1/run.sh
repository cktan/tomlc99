DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export GOPATH=$DIR/goworkspace # if it isn't already set

# $GOPATH/bin/toml-test $GOPATH/bin/toml-test-decoder # e.g., run tests on my parser
if [ "$TRAVIS_OS_NAME" == "windows" ]
then
	$GOPATH/bin/toml-test  ../build/Release/toml_json.exe
else
	$GOPATH/bin/toml-test  ../build/toml_json
fi
