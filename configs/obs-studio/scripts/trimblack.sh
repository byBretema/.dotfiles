#!/usr/bin/env bash
# Removes long black sections from .mp4 files and writes the result, with the
# same filename, to OUTDIR. Each PATH is a .mp4 file or a folder (all its .mp4
# files). Files with no black sections are copied unchanged.
# Skips files whose output already exists.
set -euo pipefail

usage() {
	cat >&2 <<-EOF
		usage: ${0##*/} -o OUTDIR [-d SECONDS] [-t LEVEL] [-n] PATH...
		  -o  output folder (required, must differ from the source folder)
		  -d  minimum black duration to remove, default 2
		  -t  max luma counted as black, 0-1, default 0.10; raise for noisy black
		  -n  only list the black sections that would be removed
	EOF
	exit 2
}

outdir= mindur=2 pixth=0.10 dry=
while getopts o:d:t:nh opt; do
	case $opt in
	o) outdir=$OPTARG ;;
	d) mindur=$OPTARG ;;
	t) pixth=$OPTARG ;;
	n) dry=1 ;;
	*) usage ;;
	esac
done
shift $((OPTIND - 1))
(($#)) || usage
[[ -n $outdir || -n $dry ]] || usage

shopt -s nullglob
srcs=()
for p in "$@"; do
	if [[ -d $p ]]; then
		srcs+=("$p"/*.mp4)
	elif [[ -f $p && $p == *.mp4 ]]; then
		srcs+=("$p")
	else
		echo "error: not a .mp4 file or folder: $p" >&2
		exit 1
	fi
done

[[ -n $dry ]] || mkdir -p "$outdir"

# Prints "start end" (seconds) for each black section of at least $mindur.
detect() {
	ffmpeg -nostdin -hide_banner -i "$1" -an \
		-vf "blackdetect=d=$mindur:pix_th=$pixth" -f null - 2>&1 |
		{ grep -o 'black_start:[0-9.]* black_end:[0-9.]*' || true; } |
		sed 's/black_start://; s/black_end://'
}

for src in "${srcs[@]}"; do
	name=${src##*/}
	if [[ -z $dry ]]; then
		out=$outdir/$name
		if [[ $(realpath "$src") == $(realpath -m "$out") ]]; then
			echo "error: output would overwrite source: $src" >&2
			exit 1
		fi
		if [[ -e $out ]]; then
			echo "skip: $out"
			continue
		fi
	fi

	echo "scan: $src"
	black=$(detect "$src")
	dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$src")
	removed=$(awk 'NF { s += $2 - $1 } END { printf "%.1f", s }' <<<"$black")
	awk 'NF { printf "  black %9.2f - %9.2f  (%.1f s)\n", $1, $2, $2 - $1 }' <<<"$black"
	echo "  remove ${removed}s of ${dur%.*}s"
	[[ -n $dry ]] && continue

	if [[ -z $black ]]; then
		cp "$src" "$out"
		continue
	fi
	if awk -v r="$removed" -v d="$dur" 'BEGIN { exit !(r >= d - 1) }'; then
		echo "  warning: almost all black, skipped" >&2
		continue
	fi

	# Drop frames inside any black section and renumber timestamps so the kept
	# parts join without gaps. Re-encodes with the same settings as vhs2mp4.
	drop=$(awk '{ printf "%sbetween(t,%s,%s)", (NR > 1 ? "+" : ""), $1, $2 }' <<<"$black")
	ffmpeg -nostdin -hide_banner -y -i "$src" -map 0:v:0 -map '0:a?' \
		-vf "select='not($drop)',setpts=N/FRAME_RATE/TB" \
		-af "aselect='not($drop)',asetpts=N/SR/TB" \
		-c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p \
		-c:a aac -b:a 192k -movflags +faststart -f mp4 "$out.part"
	mv "$out.part" "$out"
done
