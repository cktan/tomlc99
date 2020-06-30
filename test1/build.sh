
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p $DIR/goworkspace
export GOPATH=$DIR/goworkspace
if [ "$TRAVIS_OS_NAME" == "windows" ]
then
	/c/Go/bin/go.exe get github.com/BurntSushi/toml-test # install test suite	
        /c/Go/bin/go.exe get github.com/BurntSushi/toml/cmd/toml-test-decoder # e.g., install my parser
else
	go get github.com/BurntSushi/toml-test # install test suite
	go get github.com/BurntSushi/toml/cmd/toml-test-decoder # e.g., install my parser
fi
cp $GOPATH/bin/* .

