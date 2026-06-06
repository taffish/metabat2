# taf-metabat2

TAFFISH wrapper for MetaBAT2, a metagenome binning toolkit for reconstructing
metagenome-assembled genomes from assembled contigs and optional read-mapping
coverage information.

## Package Identity

- name: `metabat2`
- command: `taf-metabat2`
- version: `2.18-r2`
- kind: `tool`
- image: `ghcr.io/taffish/metabat2:2.18-r2`
- upstream project: MetaBAT
- upstream source: Bitbucket commit `c869c524d0f131d60a03be64bd26b89738160652`
- upstream distribution label: `2.18-23-gc869c52`
- runtime banner: `2.17.89-gc869c52`
- default upstream command: `metabat2`
- app license: Apache-2.0
- upstream license: BSD-3-Clause-LBNL

## Version Notes

The TAFFISH package version intentionally stays simple: `2.18-r2`.

MetaBAT's current official Docker and Bioconda distributions are based on a
post-`v2.18` commit and label that build as `2.18-23-gc869c52`. The upstream
runtime banner is generated from MetaBAT's internal `VERSION` file and reports
`2.17.89-gc869c52`. This mismatch is upstream metadata, not a TAFFISH wrapper
version mismatch. The exact upstream source commit and runtime banner are
recorded in `taffish.toml`, image provenance files, README, help, release notes,
and smoke tests.

The image is built from the checksum-pinned Bitbucket source zip rather than
from the official Docker image. The upstream CMake file adds `-mtune=native` for
Release builds; TAFFISH removes that native CPU tuning during the container
build so the published image is not tied to the build host CPU.

## Installation

Install from the public TAFFISH Hub index:

```sh
taf update
taf install metabat2
```

Install the exact release:

```sh
taf install metabat2 2.18-r2
```

For local testing before public publication:

```sh
taf install --from .
```

## Basic Usage

Show TAFFISH wrapper help and version:

```sh
taf-metabat2 --help
taf-metabat2 --version
```

Show upstream MetaBAT2 help:

```sh
taf-metabat2 -- -h
taf-metabat2 metabat2 -h
```

Run MetaBAT2 from an assembly and depth file:

```sh
taf-metabat2 metabat2 \
  --inFile assembly.fa \
  --abdFile depth.txt \
  --outFile bins/bin \
  --numThreads 8
```

Generate a depth file from coordinate-sorted BAM files:

```sh
taf-metabat2 jgi_summarize_bam_contig_depths \
  --referenceFasta assembly.fa \
  --outputDepth depth.txt \
  sample1.sorted.bam sample2.sorted.bam
```

Run the upstream convenience wrapper:

```sh
taf-metabat2 runMetaBat.sh \
  --numThreads 8 \
  assembly.fa \
  sample1.sorted.bam sample2.sorted.bam
```

Run MetaBAT1 if needed:

```sh
taf-metabat2 metabat1 -i assembly.fa -a depth.txt -o bins1/bin
```

## Command Mode

The default command is `metabat2`. Because command mode is enabled, the first
non-option argument is treated as a command inside the same container.

Recommended patterns:

```sh
taf-metabat2 -- -h
taf-metabat2 metabat2 -h
taf-metabat2 runMetaBat.sh ...
taf-metabat2 jgi_summarize_bam_contig_depths ...
```

For upstream helpers, prefer `taf-metabat2 helper-command ...`. Use `--` mainly
for option-leading arguments to the default `metabat2` command.

## Inputs And Outputs

Core inputs:

- assembly FASTA or gzipped FASTA
- optional depth table produced by `jgi_summarize_bam_contig_depths`
- optional coordinate-sorted and indexed BAM files for `runMetaBat.sh`

Core outputs:

- bin FASTA files from `metabat2`
- depth table from `jgi_summarize_bam_contig_depths`
- optional label-only bin assignments when using MetaBAT options such as `-l`
- helper summaries from scripts such as `aggregateBinDepths.pl`

BAM sorting and indexing are user responsibilities. This app does not align
reads, sort BAMs, index BAMs, assess bin quality, or run CheckM/GTDB-Tk.

## Packaged Runtime

The image includes:

- `metabat2`
- `metabat` symlink to `metabat2`
- `metabat1`
- `runMetaBat.sh`
- `jgi_summarize_bam_contig_depths`
- `contigOverlaps`
- helper scripts: `aggregateBinDepths.pl`, `aggregateContigOverlapsByBin.pl`,
  `merge_abundances.py`, `filter_sam_by_min_len.py`,
  `merge_depths-DEPRECATED.pl`
- Bash, Perl, Python 3, HTSlib runtime, OpenMP runtime, and compression/runtime
  libraries needed for FASTA/BAM/depth workflows

No external database is required. The main external resources are the user's own
assembly FASTA and BAM/depth inputs.

## Boundaries

This app does not bundle large datasets or databases because MetaBAT2 does not
require a reference database for its core binning workflow. It does not perform
read alignment, BAM sort/index, dereplication, taxonomy assignment, bin quality
estimation, or MAG reporting. Those steps should be handled by separate tools or
flows.

The smoke test uses upstream tiny fixture FASTA/BAM files and does not access
the network.

## Smoke Coverage

Smoke tests are offline and self-contained. They check:

- exact runtime banner for `metabat2`, `metabat`, `metabat1`,
  `jgi_summarize_bam_contig_depths`, and `contigOverlaps`
- helper script usage for `runMetaBat.sh`, Perl helpers, and Python helpers
- depth generation from a tiny BAM
- direct `metabat2` binning from a tiny assembly and depth table
- `runMetaBat.sh` wrapper path
- helper summarization with `aggregateBinDepths.pl`

Smoke is not a scientific benchmark and does not judge MAG completeness,
contamination, taxonomy, or downstream quality.

## Citation

Kang et al. MetaBAT, an efficient tool for accurately reconstructing single
genomes from complex microbial communities. PeerJ 3:e1165 (2015).
DOI: <https://doi.org/10.7717/peerj.1165>
