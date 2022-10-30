#!/usr/bin/env bash

# Enter fullscreen mode on a website while keeping qutebrowser windowed. This is nice for sites
# such as youtube, where the fullscreen video player is much nicer than the windowed alternative.

# Usage: `:spawn --userscript fake-fullscreen.sh`

echo "fake-key f" >> "$QUTE_FIFO"
sleep 0.05
echo "fullscreen" >> "$QUTE_FIFO"
