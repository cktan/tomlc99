#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

failing=(
	-skip valid/key/escapes                    # Treats "\n" as invalid because it first replaces escapes and then checks.
	-skip valid/key/quoted-unicode             # Doesn't print null byte correctly.
	-skip valid/string/quoted-unicode
	-skip valid/spec/string-7                  # Lots of ''''''' ... that somehow goes wrong.
	-skip invalid/string/literal-multiline-quotes-1
	-skip invalid/string/literal-multiline-quotes-2
	-skip invalid/string/multiline-quotes-1
	-skip invalid/inline-table/trailing-comma  # Trailing comma should be error; not worth fixing as it'll be allowed in 1.1
	-skip invalid/inline-table/add             # Appending existing tables
	-skip invalid/array/extending-table
	-skip invalid/table/append-with-dotted-keys-1
	-skip invalid/table/append-with-dotted-keys-2
	-skip invalid/control/bare-cr              # Doesn't reject some forbidden control characters.
	-skip invalid/control/bare-null
	-skip invalid/control/comment-cr
	-skip invalid/control/comment-del
	-skip invalid/control/comment-lf
	-skip invalid/control/comment-null
	-skip invalid/control/comment-us
	-skip invalid/encoding/bad-codepoint       # Doesn't reject invalid UTF-8; nothing is multi-byte aware, so...
	-skip invalid/encoding/bad-utf8-in-comment
	-skip invalid/encoding/bad-utf8-in-multiline-literal
	-skip invalid/encoding/bad-utf8-in-multiline
	-skip invalid/encoding/bad-utf8-in-string-literal
	-skip invalid/encoding/bad-utf8-in-string
	-skip invalid/encoding/utf16

	# These seem broken in toml-test...
	-skip valid/spec/local-date-time-0
	-skip valid/spec/local-time-0
	-skip valid/spec/offset-date-time-0

	# Fixed in master:
	# https://github.com/toml-lang/toml-test/commit/fe8e1e2fb8b0309d54d6ad677aecb86bcb0ff138
	-skip valid/float/inf-and-nan
	-skip valid/spec/float-2
)

$DIR/toml-test $DIR/../toml_json ${failing[@]} "$@"