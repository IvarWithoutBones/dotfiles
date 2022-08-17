#!/usr/bin/env bash

# Test ping and upload/download speeds

set -e

PINGTIME="$(ping google.com -c 5 | grep "min/avg/max" | cut -d"/" -f5)"
echo "Ping: ${PINGTIME}ms"
speedtest | grep -E 'Download|Upload'
