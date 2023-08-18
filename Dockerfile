FROM debian:latest as build
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /build

# Install prerequisites
RUN apt update && apt install -y --no-install-recommends apt-utils \
  && apt install -y cmake curl gcc git libc6-dev make meson pkg-config 

# Build mvdsv
RUN git clone https://github.com/QW-Group/mvdsv.git
WORKDIR /build/mvdsv
RUN cmake . && cmake --build ./ 
WORKDIR /build 

# Build ktx
RUN git clone https://github.com/QW-Group/ktx.git 
WORKDIR ktx
RUN cmake build . && cmake --build ./
WORKDIR /build

FROM debian:latest as run
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /nquake

# Install prerequisites
RUN apt update && apt install -y --no-install-recommends apt-utils \
    && apt install -y cmake curl unzip wget dos2unix gettext dnsutils qstat \
    && rm -rf /var/lib/apt/lists/*

# Copy files
COPY files .
COPY --from=build /build/mvdsv/mvdsv /nquake/mvdsv
COPY --from=build /build/ktx/qwprogs.so /nquake/ktx/qwprogs.so
COPY scripts/healthcheck.sh /healthcheck.sh
COPY scripts/entrypoint.sh /entrypoint.sh

# Cleanup
RUN find . -type f -print0 | xargs -0 dos2unix -q \
  && find . -type f -exec chmod -f 644 "{}" \; \
  && find . -type d -exec chmod -f 755 "{}" \; \
  && chmod +x mvdsv ktx/mvdfinish.qws ktx/qwprogs.so

VOLUME /nquake/logs
VOLUME /nquake/media
VOLUME /nquake/demos

ENTRYPOINT ["/entrypoint.sh"]
