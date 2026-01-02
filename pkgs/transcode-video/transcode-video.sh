#!/usr/bin/env bash

set -euo pipefail

USAGE="usage: transcode-video [OPTIONS] <INPUT>

Transcodes videos to HEVC/OPUS using ffmpeg, optionally compressing them to reduce file size.

Positional arguments:
  INPUT                   Path to input video file or directory containing video files.

Options:
  -o, --output <path>         Path to output file or directory. Required unless using --in-place.
  -i, --in-place              Overwrite the input file with the transcoded output. Cannot be used with --output.
  -r, --resolution <res>      Target vertical resolution (e.g. 720p, 1080p). Defaults to the original resolution.
  -c, --compression <level>   Compression level: none, low, medium, or high. Lower values yield better quality at the cost of larger file sizes. Default is none.
      --copy-audio            Copy the audio stream without re-encoding.
      --dry-run               Show what would be done without modifying any files.
  -h, --help                  Show this help message and exit."

panic() {
    if [[ -z ${NO_COLOR:-} ]]; then
        printf '\e[31merror: %s\e[0m\n%s\n' "$1" "${USAGE}" >&2
    else
        echo -e "error: $1\n${USAGE}" >&2
    fi
    exit 1
}

info() {
    if [[ -z ${NO_COLOR:-} ]]; then
        printf '\e[32m%s\e[0m\n' "$@"
    else
        echo "$@"
    fi
}

# The flags to use for each ffmpeg invocation, cached to avoid recomputing them when processing multiple files.
FFMPEG_HARDWARE_FLAGS=()
FFMPEG_OUTPUT_FLAGS=()

setFfmpegFlags() {
    # Detetect the available hardware accelerations methods
    local crf="${1:-15}" audioBitrate="${2:-}" resolution="${3:-}" copyAudio="${4:-0}"

    # Transcode video to HEVC using hardware acceleration if available
    local availableEncoders
    availableEncoders="$(ffmpeg -hide_banner -encoders)"
    if grep -q "hevc_nvenc" <<< "${availableEncoders}"; then
        # NVIDIA GPU with CUDA support
        FFMPEG_HARDWARE_FLAGS+=(
            # Use the first CUDA GPU for accelerated encoding and decoding (if supported)
            -init_hw_device cuda=hwDevice:0
            -hwaccel_device hwDevice
            -hwaccel cuda
            -hwaccel_output_format cuda
        )

        FFMPEG_OUTPUT_FLAGS+=(
            -filter_hw_device hwDevice # Use the CUDA device initialized above for encoding
            -vcodec hevc_nvenc         # Use NVIDIA's HEVC encoder
            -tune hq                   # High quality tuning
            -preset p7                 # Optimize for quality over speed
            -rc-lookahead 32           # Look N frames ahead for better compression
            -multipass fullres         # Enable multipass encoding
            -rc vbr                    # Use variable bitrate mode
            -spatial-aq true           # Enable spatial adaptive quantization
            -aq-strength 15            # Adaptive quantization strength
            -qmin "${crf}"             # Minimum quantization parameter
            -qmax 51                   # Maximum quantization parameter
            -cq "${crf}"               # Constant quality factor
        )

        if [[ -n "${resolution:-}" ]]; then
            FFMPEG_OUTPUT_FLAGS+=(
                -noautoscale
                -vf "format=nv12|cuda,hwupload,scale_cuda=-2:${resolution%p}:force_original_aspect_ratio=decrease"
            )
        fi
    else
        # Software encoding fallback
        FFMPEG_OUTPUT_FLAGS+=(
            -vcodec hevc
            -preset slow
            -crf "${crf}"
        )

        if [[ -n "${resolution:-}" ]]; then
            FFMPEG_OUTPUT_FLAGS+=(-vf "scale=-2:${resolution%p}:force_original_aspect_ratio=decrease")
        fi
    fi

    if ((copyAudio)); then
        # Copy the audio stream without re-encoding
        FFMPEG_OUTPUT_FLAGS+=(-acodec copy)
    else
        # Transcode the audio stream to OPUS, optionally adjusting the bitrate
        FFMPEG_OUTPUT_FLAGS+=(-acodec libopus -b:a "${audioBitrate:-"320k"}")
    fi

    FFMPEG_OUTPUT_FLAGS+=(
        -c:s mov_text        # Convert subtitles to mov_text
        -movflags +faststart # Enable fast start for web playback
        -progress pipe:1     # Show progress on stdout
        -loglevel warning    # Reduce log verbosity
        -y                   # Overwrite output file without asking
    )
}

transcodeVideo() {
    local input="$1" output="$2"

    local videoDuration
    videoDuration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal "${input}")"
    [[ ${videoDuration} == [0-9]:* ]] && videoDuration="0${videoDuration}" # ffprobe prints 0:00:00, but ffmpeg adds a leading zero
    videoDuration="${videoDuration%%.*}"                                   # Trim off milliseconds

    local sizeBefore sizeAfter printedProgress=0
    sizeBefore=$(du -h "${input}" | cut -f1)

    ffmpeg "${FFMPEG_HARDWARE_FLAGS[@]}" -i "${input}" "${FFMPEG_OUTPUT_FLAGS[@]}" "${output}" \
        | grep --line-buffered "out_time=" \
        | while IFS= read -r progress; do
            progress="${progress#out_time=}"
            [[ ${progress} == "N/A" ]] && continue
            progress="${progress%%.*}" # Trim off milliseconds

            if ((printedProgress == 0)); then
                printedProgress=1
                echo "${progress}/${videoDuration}" >&2
            else
                # Move cursor up one line and clear line (replacing the previous message), then print progress
                printf '\e[A\e[K%s/%s\n' "${progress}" "${videoDuration}" >&2
            fi
        done

    # Final progress update to show completion
    sizeAfter=$(du -h "${output}" | cut -f1)
    printf '\e[A\e[K%s/%s (%s -> %s)\n' "${videoDuration}" "${videoDuration}" "${sizeBefore}" "${sizeAfter}" >&2
}

VIDEO_PROCESSING_STAGE="done"

trapHandler() {
    # Ensure we clean up temporary files on errors or interrupts
    local exitCode=$? input="$1" output="$2"
    case "${VIDEO_PROCESSING_STAGE}" in
        "done") ;;
        "transcoding" | "in-place-cleanup") rm -f "${output}" ;;
        "in-place-copy")
            cp --force "${output}" "${input}"
            VIDEO_PROCESSING_STAGE="in-place-cleanup"
            rm -f "${output}"
            ;;
        *)
            VIDEO_PROCESSING_STAGE="done"
            panic "unknown video processing stage"
            ;;
    esac
    VIDEO_PROCESSING_STAGE="done"
    exit "${exitCode}"
}

handleVideoInput() {
    local input="$1" output="$2" inPlace="$3" dryRun="$4"

    if [[ -n ${output:-} ]]; then
        if [[ -d ${output:-} ]]; then
            output="${output}/$(basename "${input}")"
        elif [[ -e ${output} ]]; then
            panic "output file already exists: '${output}'"
        fi

        # Only show the output filename if it's different from the input filename
        local displayOutput
        if [[ $(basename "${output}") == "$(basename "${input}")" ]]; then
            displayOutput="$(dirname "${output}")"
        else
            displayOutput="${output}"
        fi

        info "transcoding video: '${input}' -> '${displayOutput}'" >&2
    else
        # Create a temporary output file in the same directory as the input file to avoid copying large files across disks
        if ((dryRun == 0)); then
            ((inPlace)) || panic "missing output file"
            output="$(mktemp -p "$(dirname "${input}")" "transcoded-tmp-XXXXXXXXXX-$(basename "${input}")")"
        fi
        info "transcoding video in-place: '${input}'" >&2
    fi

    ((dryRun)) && return

    VIDEO_PROCESSING_STAGE="transcoding"
    # shellcheck disable=SC2064
    trap "trapHandler '${input}' '${output}'" 0

    transcodeVideo "${input}" "${output}"

    if ((inPlace)); then
        VIDEO_PROCESSING_STAGE="in-place-copy"
        cp --force "${output}" "${input}"
        VIDEO_PROCESSING_STAGE="in-place-cleanup"
        rm "${output}"
    fi

    VIDEO_PROCESSING_STAGE="done"
    trap - 0
}

main() {
    local input output inPlace=0 dryRun=0 compression="none" resolution copyAudio=0
    while (($# > 0)); do
        case "$1" in
            -r | --resolution)
                shift || panic "missing argument for '$1'"
                if [[ ! $1 =~ ^[0-9]+p$ ]]; then
                    panic "invalid resolution format: '$1' (expected: 720p, 1080p, ...)"
                fi
                resolution="${1%p}"
                ;;
            -c | --compression)
                shift || panic "missing argument for '$1'"
                compression="$1"
                ;;
            -i | --in-place)
                inPlace=1
                ;;
            -o | --output)
                shift || panic "missing argument for '$1'"
                output="$(realpath "$1")"
                ;;
            --copy-audio) copyAudio=1 ;;
            --dry-run) dryRun=1 ;;
            -h | --help)
                echo "${USAGE}"
                exit 0
                ;;
            *)
                [[ -n ${input:-} ]] && panic "unexpected argument: '$1'"
                input="$(readlink -f "$1")"
                input="${input%/}"
                ;;
        esac
        shift || break
    done

    [[ -z ${input:-} ]] && panic "missing input"
    ((inPlace)) && [[ -n ${output:-} ]] && panic "cannot use --in-place with --output"

    local crf audioBitrate
    case "${compression}" in
        none) ;;
        low)
            crf="20"
            audioBitrate="192k"
            ;;
        medium)
            crf="24"
            audioBitrate="128k"
            ;;
        high)
            crf="28"
            audioBitrate="96k"
            ;;
        *) panic "unknown compression level: '${compression}'" ;;
    esac

    ((dryRun == 0)) && setFfmpegFlags "${crf:-}" "${audioBitrate:-}" "${resolution:-}" "${copyAudio}"

    if [[ -f ${input} ]]; then
        handleVideoInput "${input}" "${output:-}" "${inPlace}" "${dryRun}"
    elif [[ -d ${input} ]]; then
        # If the user specified an output directory, ensure it either already exists or create it
        if [[ -n ${output:-} ]]; then
            output="$(readlink -f "${output}")"
            if [[ -e ${output} ]]; then
                [[ -d ${output} ]] || panic "expected output to be a directory when input is a directory: '${output}'"
            fi

            output="${output%/}"
            ((dryRun == 0)) && mkdir -p "${output}"
        fi

        # Process all video files in the input directory
        local processed=0
        for file in "${input}"/*.{mp4,mkv,avi,mov,wmv,flv,webm}; do
            [[ ! -f ${file} ]] && continue
            processed=1

            local outputFile=""
            if [[ -n ${output:-} ]]; then
                outputFile="${output}/$(basename "${file}")"
            fi

            handleVideoInput "${file}" "${outputFile}" "${inPlace}" "${dryRun}"
        done
        ((processed)) || panic "no videos found in input directory: '${input}'"
    else
        panic "input path does not exist: '${input}'"
    fi
}

main "$@"
