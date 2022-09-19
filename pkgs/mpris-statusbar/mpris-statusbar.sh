# Display the currently playing song according to MPRIS, used by my status bar

set -euo pipefail

supportedInstances=( "spotify" "psst" ) # The MPRIS instances to display information for
currentInstances="$(playerctl --list-all)"

# Dont do anything if no supported instance is active
for instance in "${supportedInstances[@]}"; do
    grep -q "$instance" <<< "$currentInstances" && {
        mprisInstance="$instance"
        break
    }
done
test -z "${mprisInstance:-}" && exit

for arg in "$@"; do
    case "$arg" in
        --next)
            playerctl --player="$mprisInstance" next
            exit
            ;;
        --previous)
            playerctl --player="$mprisInstance" previous
            exit
            ;;
        *)
            echo "Usage: $(basename "$0") [--next] [--previous]"
            exit 1
    esac
done

artist="$(playerctl --player="$mprisInstance" metadata artist)"
title="$(playerctl --player="$mprisInstance" metadata title)"
echo "阮 $artist - $title"
