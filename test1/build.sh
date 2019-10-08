
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p $DIR/goworkspace
export GOPATH=$DIR/goworkspace 
go get github.com/BurntSushi/toml-test # install test suite
go get github.com/BurntSushi/toml/cmd/toml-test-decoder # e.g., install my parser
cp $GOPATH/bin/* .

