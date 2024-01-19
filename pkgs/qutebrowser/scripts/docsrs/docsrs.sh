#!/usr/bin/env bash

# A shortcut to search docs.rs for Rust documentation. Workaround for https://github.com/qutebrowser/qutebrowser/issues/5560.
# usage: `:spawn --userscript docsrs.sh [crate] [query]`

set -euo pipefail
URL="https://docs.rs"

if (($# > 0)); then
	URL="$URL/$1/latest/$1" # Append the crate name to the URL if its present
	shift
fi

if (($# > 0)); then
	URL="$URL/?search=$*" # Add the query to the URL, if one is provided
fi

echo "open $URL" > "$QUTE_FIFO"
