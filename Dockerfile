FROM ubuntu:18.04 as build
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /build

# Install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
  && apt-get install -y curl gcc git libc6-dev make pkg-config qstat

# Build mvdsv
RUN git clone https://github.com/deurk/mvdsv.git && cd mvdsv/build/make \
  && ./configure && make

# Build ktx
RUN git clone https://github.com/deurk/ktx.git && cd ktx \
  && ./configure && make dl

FROM ubuntu:18.04 as run
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /nquake

# Install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
  && apt-get install -y curl unzip wget dos2unix gettext dnsutils \
  && rm -rf /var/lib/apt/lists/*

# Copy files
COPY files .
COPY --from=build /build/mvdsv/build/make/mvdsv /nquake/mvdsv
COPY --from=build /build/ktx/qwprogs.so /nquake/ktx/qwprogs.so
COPY scripts/healthcheck.sh /healthcheck.sh
COPY scripts/entrypoint.sh /entrypoint.sh

# Cleanup
RUN find . -type f -print0 | xargs -0 dos2unix -q \
  && find . -type f -exec chmod -f 644 "{}" \; \
  && find . -type d -exec chmod -f 755 "{}" \; \
  && chmod +x mvdsv ktx/mvdfinish.qws ktx/qwprogs.so

ENTRYPOINT ["/entrypoint.sh"]
