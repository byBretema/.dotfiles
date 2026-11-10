#!/usr/bin/env bash
# Converts interlaced PAL .mkv masters to 50p 4:3 .mp4. Each PATH is a .mkv
# file or a folder (all its .mkv files); default is the current folder.
# Output goes to OUTDIR, or next to each source if -o is not given.
# Skips files whose .mp4 already exists.
set -euo pipefail

usage() {
	echo "usage: ${0##*/} [-p tff|bff] [-o OUTDIR] [PATH...]" >&2
	exit 2
}

parity=tff outdir=
while getopts p:o:h opt; do
	case $opt in
	p) parity=$OPTARG ;;
	o) outdir=$OPTARG ;;
	*) usage ;;
	esac
done
shift $((OPTIND - 1))
[[ $parity == tff || $parity == bff ]] || usage
(($#)) || set -- .
[[ -n $outdir ]] && mkdir -p "$outdir"

shopt -s nullglob
srcs=()
for p in "$@"; do
	if [[ -d $p ]]; then
		srcs+=("$p"/*.mkv)
	elif [[ -f $p && $p == *.mkv ]]; then
		srcs+=("$p")
	else
		echo "error: not a .mkv file or folder: $p" >&2
		exit 1
	fi
done

for src in "${srcs[@]}"; do
	name=${src##*/}
	dest=${outdir:-$(dirname "$src")}
	out=$dest/${name%.mkv}.mp4
	if [[ -e $out ]]; then
		echo "skip: $out"
		continue
	fi
	# Encode to .part so an interrupted run is not mistaken for a finished file.
	ffmpeg -nostdin -hide_banner -y -i "$src" -map 0:v:0 -map '0:a?' \
		-vf "bwdif=mode=send_field:parity=$parity,setsar=16/15" \
		-c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p \
		-c:a aac -b:a 192k -movflags +faststart -f mp4 "$out.part"
	mv "$out.part" "$out"
done
