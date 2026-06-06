taf-metabat2 2.18-r2

TAFFISH tool app for MetaBAT2, a metagenome binning toolkit for
assembly FASTA files and optional BAM-derived coverage depth tables.
The default upstream command is metabat2.

Version notes:
  TAFFISH package version: 2.18-r2
  Exact upstream source label: 2.18-23-gc869c52
  Runtime banner reported by MetaBAT binaries: 2.17.89-gc869c52
  The runtime banner mismatch comes from upstream MetaBAT version metadata.

Usage:
  taf-metabat2 --help
  taf-metabat2 --version
  taf-metabat2 -- -h
  taf-metabat2 metabat2 -h
  taf-metabat2 metabat2 --inFile assembly.fa --abdFile depth.txt --outFile bins/bin
  taf-metabat2 jgi_summarize_bam_contig_depths --referenceFasta assembly.fa --outputDepth depth.txt sample.bam
  taf-metabat2 runMetaBat.sh assembly.fa sample1.bam sample2.bam

Wrapper options:
  --help       Show this TAFFISH help text.
  --version    Show the TAFFISH package version.
  --compile    Print generated shell instead of running it.
  --           Pass following option-leading arguments to metabat2.

Default upstream command:
  metabat2

Common commands:
  MetaBAT2 binning from a precomputed depth table:
    taf-metabat2 metabat2 \
      --inFile assembly.fa \
      --abdFile depth.txt \
      --outFile bins/bin \
      --numThreads 8

  Create a depth table from sorted BAM files:
    taf-metabat2 jgi_summarize_bam_contig_depths \
      --referenceFasta assembly.fa \
      --outputDepth depth.txt \
      sample1.sorted.bam sample2.sorted.bam

  Use the upstream convenience wrapper:
    taf-metabat2 runMetaBat.sh --numThreads 8 assembly.fa sample.sorted.bam

  Run MetaBAT1:
    taf-metabat2 metabat1 -i assembly.fa -a depth.txt -o bins1/bin

Command mode:
  The first non-option argument is treated as a command inside the same app
  environment. Use:
    taf-metabat2 metabat2 ...
    taf-metabat2 runMetaBat.sh ...
    taf-metabat2 jgi_summarize_bam_contig_depths ...
  Use -- mainly for option-leading arguments to the default metabat2 command.

Packaged commands:
  metabat2, metabat, metabat1, runMetaBat.sh,
  jgi_summarize_bam_contig_depths, contigOverlaps,
  aggregateBinDepths.pl, aggregateContigOverlapsByBin.pl,
  merge_abundances.py, filter_sam_by_min_len.py,
  merge_depths-DEPRECATED.pl.

Inputs:
  Assembly FASTA or gzipped FASTA.
  Optional depth table from jgi_summarize_bam_contig_depths.
  Optional coordinate-sorted and indexed BAM files for runMetaBat.sh.

Outputs:
  Bin FASTA files, depth tables, optional label-only assignments, and helper
  summaries depending on the upstream command and options used.

Boundaries:
  No external database is required or bundled. This app does not align reads,
  sort/index BAMs, estimate MAG completeness or contamination, assign taxonomy,
  or run CheckM/GTDB-Tk. Provide sorted BAMs or a depth table explicitly.

Smoke:
  Smoke is offline and self-contained. It checks runtime banners, helper usage,
  depth generation from a tiny BAM, direct metabat2 binning, runMetaBat.sh, and
  aggregateBinDepths.pl output.

License and citation:
  TAFFISH packaging files are Apache-2.0. Upstream MetaBAT is BSD-3-Clause-LBNL.
  Cite Kang et al. PeerJ 3:e1165, DOI 10.7717/peerj.1165.
