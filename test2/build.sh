set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[ -d toml-spec-tests ] || git clone https://github.com/iarna/toml-spec-tests.git

