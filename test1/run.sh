DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export GOPATH=$DIR/goworkspace # if it isn't already set
# $GOPATH/bin/toml-test $GOPATH/bin/toml-test-decoder # e.g., run tests on my parser
$GOPATH/bin/toml-test  ../toml_json
