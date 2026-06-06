#!/bin/sh
set -eu

outdir="${1:-/tmp/taf-metabat2-smoke}"
testdata="${METABAT2_TESTDATA:-/opt/metabat2/share/testdata}"

rm -rf "$outdir"
mkdir -p "$outdir/direct" "$outdir/runmetabat"

assembly="$testdata/contigs.fa"
bam="$testdata/contigs-1000.fastq.bam"

test -s "$assembly"
test -s "$bam"
test -s "$bam.bai"

jgi_summarize_bam_contig_depths \
  --referenceFasta "$assembly" \
  --outputDepth "$outdir/depth.txt" \
  "$bam" \
  >"$outdir/jgi.log" 2>&1

test -s "$outdir/depth.txt"
grep -F "contigName" "$outdir/depth.txt" >/dev/null

metabat2 \
  --minClsSize 0 \
  --numThreads 1 \
  --inFile "$assembly" \
  --abdFile "$outdir/depth.txt" \
  --outFile "$outdir/direct/bin" \
  -v \
  >"$outdir/metabat2.log" 2>&1

direct_bin="$(find "$outdir/direct" -type f -name '*.fa' | sort | sed -n '1p')"
test -n "$direct_bin"
test -s "$direct_bin"
grep -F ">" "$direct_bin" >/dev/null

aggregateBinDepths.pl "$outdir/depth.txt" "$direct_bin" > "$outdir/direct_bin_depths.tsv"
test -s "$outdir/direct_bin_depths.tsv"
grep -F "totalLength" "$outdir/direct_bin_depths.tsv" >/dev/null

(
  cd "$outdir/runmetabat"
  runMetaBat.sh --minClsSize 0 "$assembly" "$bam" > "$outdir/runmetabat.log" 2>&1
)

test -s "$outdir/runmetabat.log"
grep -F "Finished metabat2" "$outdir/runmetabat.log" >/dev/null
run_bin="$(find "$outdir/runmetabat" -type f -name '*.fa' | sort | sed -n '1p')"
test -n "$run_bin"
test -s "$run_bin"
grep -F ">" "$run_bin" >/dev/null

merge_abundances.py "$outdir/merged_depth.txt" "$outdir/depth.txt"
test -s "$outdir/merged_depth.txt"
grep -F "contigName" "$outdir/merged_depth.txt" >/dev/null

echo "metabat2 smoke ok"
