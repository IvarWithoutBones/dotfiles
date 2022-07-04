#!@runtimeShell@
# A small script to test ping and upload/download speeds

set -e

PATH=@binPath@

PINGTIME="$(ping google.com -c 5 | grep "min/avg/max" | cut -d"/" -f5)"
echo "Ping: ${PINGTIME}ms"
speedtest | grep -E 'Download|Upload'
