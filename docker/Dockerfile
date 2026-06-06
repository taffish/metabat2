ARG METABAT2_VERSION=2.18
ARG METABAT2_UPSTREAM_VERSION=2.18-23-gc869c52
ARG METABAT2_RUNTIME_VERSION=2.17.89-gc869c52
ARG METABAT2_SOURCE_COMMIT=c869c524d0f131d60a03be64bd26b89738160652
ARG METABAT2_SOURCE_SHA256=ab4a4df1a4af3ce315317318a53b242e4f91d03e9ffe356279a69dd5df4d7e3c
ARG DEBIAN_MIRROR=http://deb.debian.org/debian
ARG DEBIAN_SECURITY_MIRROR=http://deb.debian.org/debian-security

FROM debian:12-slim AS builder

ARG METABAT2_VERSION
ARG METABAT2_UPSTREAM_VERSION
ARG METABAT2_RUNTIME_VERSION
ARG METABAT2_SOURCE_COMMIT
ARG METABAT2_SOURCE_SHA256
ARG DEBIAN_MIRROR
ARG DEBIAN_SECURITY_MIRROR

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    sed -i \
      -e "s|http://deb.debian.org/debian-security|${DEBIAN_SECURITY_MIRROR}|g" \
      -e "s|http://deb.debian.org/debian|${DEBIAN_MIRROR}|g" \
      /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
      'Acquire::Retries "5";' \
      'Acquire::http::Pipeline-Depth "0";' \
      'Acquire::http::No-Cache "true";' \
      'Acquire::BrokenProxy "true";' \
      > /etc/apt/apt.conf.d/99taffish-network

RUN set -eux; \
    for attempt in 1 2 3 4 5 6; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            bash \
            bzip2 \
            ca-certificates \
            curl \
            perl \
            pkg-config \
            python3 \
            unzip; then \
        break; \
      fi; \
      if [ "$attempt" = "6" ]; then exit 1; fi; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    for attempt in 1 2 3 4 5 6; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            build-essential \
            cmake; then \
        break; \
      fi; \
      if [ "$attempt" = "6" ]; then exit 1; fi; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    for attempt in 1 2 3 4 5 6; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            libboost-filesystem-dev \
            libboost-graph-dev \
            libboost-iostreams-dev \
            libboost-program-options-dev \
            libboost-serialization-dev \
            libboost-system-dev; then \
        break; \
      fi; \
      if [ "$attempt" = "6" ]; then exit 1; fi; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    for attempt in 1 2 3 4 5 6; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            libbz2-dev \
            libcurl4-gnutls-dev \
            libdeflate-dev \
            libhts-dev \
            liblzma-dev \
            libncurses-dev \
            libssl-dev \
            zlib1g-dev; then \
        break; \
      fi; \
      if [ "$attempt" = "6" ]; then exit 1; fi; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build/metabat2

RUN set -eux; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://bitbucket.org/berkeleylab/metabat/get/${METABAT2_SOURCE_COMMIT}.zip" \
      -o metabat2.zip; \
    echo "${METABAT2_SOURCE_SHA256}  metabat2.zip" | sha256sum -c -; \
    unzip -q metabat2.zip; \
    mv berkeleylab-metabat-* src; \
    cd src; \
    printf "%s\n" "${METABAT2_RUNTIME_VERSION}" > VERSION; \
    sed -i 's/ -mtune=native//g' CMakeLists.txt; \
    cmake -S . -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/metabat2 \
      -DMETABAT_USE_SYSTEM_ZLIB=ON \
      -DMETABAT_USE_SYSTEM_HTSLIB=ON; \
    cmake --build build -j"$(nproc)"; \
    ctest --test-dir build --output-on-failure -j1; \
    cmake --install build; \
    mkdir -p /opt/metabat2/share/doc/metabat2 /opt/metabat2/share/licenses/metabat2 /opt/metabat2/share/testdata; \
    install -m 0644 README.md INSTALL.md VERSION version.h Legal.txt license.txt /opt/metabat2/share/doc/metabat2/; \
    install -m 0644 license.txt /opt/metabat2/share/licenses/metabat2/license.txt; \
    cp -a test/contigs.fa test/contigs-1000.fastq.bam test/contigs-1000.fastq.bam.bai test/contigs_depth.txt /opt/metabat2/share/testdata/; \
    printf "%s\n" "${METABAT2_VERSION}" > /opt/metabat2/share/doc/metabat2/TAFFISH_PACKAGE_VERSION; \
    printf "%s\n" "${METABAT2_UPSTREAM_VERSION}" > /opt/metabat2/share/doc/metabat2/UPSTREAM_VERSION; \
    printf "%s\n" "${METABAT2_RUNTIME_VERSION}" > /opt/metabat2/share/doc/metabat2/RUNTIME_VERSION; \
    printf "%s\n" "${METABAT2_SOURCE_COMMIT}" > /opt/metabat2/share/doc/metabat2/SOURCE_COMMIT; \
    printf "%s\n" "${METABAT2_SOURCE_SHA256}" > /opt/metabat2/share/doc/metabat2/SOURCE_SHA256; \
    PATH="/opt/metabat2/bin:${PATH}" metabat2 -h 2>&1 | grep -F "version 2:${METABAT2_RUNTIME_VERSION};" >/dev/null; \
    PATH="/opt/metabat2/bin:${PATH}" metabat1 -h 2>&1 | grep -F "version 1:${METABAT2_RUNTIME_VERSION};" >/dev/null; \
    PATH="/opt/metabat2/bin:${PATH}" jgi_summarize_bam_contig_depths -h 2>&1 | grep -F "jgi_summarize_bam_contig_depths ${METABAT2_RUNTIME_VERSION}" >/dev/null; \
    PATH="/opt/metabat2/bin:${PATH}" contigOverlaps -h 2>&1 | grep -F "ContigOverlaps ${METABAT2_RUNTIME_VERSION}" >/dev/null; \
    for x in metabat metabat1 metabat2 jgi_summarize_bam_contig_depths contigOverlaps; do \
      command -v "/opt/metabat2/bin/$x" >/dev/null; \
      ldd "/opt/metabat2/bin/$x" > "/tmp/${x}.ldd"; \
      ! grep -F "not found" "/tmp/${x}.ldd" >/dev/null; \
    done

COPY docker/metabat2_smoke.sh /opt/metabat2/share/testdata/metabat2_smoke.sh

RUN set -eux; \
    chmod 0755 /opt/metabat2/share/testdata/metabat2_smoke.sh; \
    PATH="/opt/metabat2/bin:${PATH}" /opt/metabat2/share/testdata/metabat2_smoke.sh /tmp/taf-metabat2-build-smoke; \
    rm -rf /tmp/taf-metabat2-build-smoke

FROM debian:12-slim

ARG METABAT2_RUNTIME_VERSION
ARG DEBIAN_MIRROR
ARG DEBIAN_SECURITY_MIRROR

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    sed -i \
      -e "s|http://deb.debian.org/debian-security|${DEBIAN_SECURITY_MIRROR}|g" \
      -e "s|http://deb.debian.org/debian|${DEBIAN_MIRROR}|g" \
      /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
      'Acquire::Retries "5";' \
      'Acquire::http::Pipeline-Depth "0";' \
      'Acquire::http::No-Cache "true";' \
      'Acquire::BrokenProxy "true";' \
      > /etc/apt/apt.conf.d/99taffish-network

COPY --from=builder /opt/metabat2/share/doc/metabat2/RUNTIME_VERSION /tmp/metabat2-runtime-version

RUN set -eux; \
    for attempt in 1 2 3 4 5 6; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            bash \
            ca-certificates \
            gzip \
            libboost-filesystem1.74.0 \
            libboost-graph1.74.0 \
            libboost-iostreams1.74.0 \
            libboost-program-options1.74.0 \
            libboost-serialization1.74.0 \
            libdeflate0 \
            libgomp1 \
            libhts3 \
            libstdc++6 \
            perl \
            python3 \
            zlib1g; then \
        break; \
      fi; \
      if [ "$attempt" = "6" ]; then exit 1; fi; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -f /tmp/metabat2-runtime-version; \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/metabat2 /opt/metabat2

ENV PATH=/opt/metabat2/bin:$PATH
ENV METABAT2_HOME=/opt/metabat2
ENV METABAT2_TESTDATA=/opt/metabat2/share/testdata

RUN set -eux; \
    metabat2 -h 2>&1 | grep -F "version 2:${METABAT2_RUNTIME_VERSION};" >/dev/null; \
    metabat -h 2>&1 | grep -F "version 2:${METABAT2_RUNTIME_VERSION};" >/dev/null; \
    metabat1 -h 2>&1 | grep -F "version 1:${METABAT2_RUNTIME_VERSION};" >/dev/null; \
    jgi_summarize_bam_contig_depths -h 2>&1 | grep -F "jgi_summarize_bam_contig_depths ${METABAT2_RUNTIME_VERSION}" >/dev/null; \
    contigOverlaps -h 2>&1 | grep -F "ContigOverlaps ${METABAT2_RUNTIME_VERSION}" >/dev/null; \
    runMetaBat.sh 2>&1 | grep -F "runMetaBat.sh" >/dev/null; \
    for x in metabat metabat1 metabat2 jgi_summarize_bam_contig_depths contigOverlaps; do \
      ldd "$(command -v "$x")" > "/tmp/${x}.ldd"; \
      ! grep -F "not found" "/tmp/${x}.ldd" >/dev/null; \
    done; \
    /opt/metabat2/share/testdata/metabat2_smoke.sh /tmp/taf-metabat2-runtime-smoke; \
    rm -rf /tmp/taf-metabat2-runtime-smoke

WORKDIR /root

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=metabat2
