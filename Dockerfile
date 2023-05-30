FROM --platform=linux/amd64 ubuntu:22.04 AS build
LABEL author="hundehausen" \
      maintainer="hundehausen"
      
ENV WOWNERO_VERSION=0.11.0.3 WOWNERO_SHA256=e31d9f1e76d5c65e774c4208dfd1a18cfeda9f3822facaf1d114459ca9a38320

RUN apt-get update && apt-get install -y curl bzip2

WORKDIR /root

RUN curl -L -o wownero-x86_64-linux-gnu-v$WOWNERO_VERSION.tar.bz2 https://git.wownero.com/attachments/c1de2873-a72d-41d3-a807-d36e8305ea3f &&\
  echo "$WOWNERO_SHA256  wownero-x86_64-linux-gnu-v$WOWNERO_VERSION.tar.bz2" | sha256sum -c - &&\
  tar -xvf wownero-x86_64-linux-gnu-v$WOWNERO_VERSION.tar.bz2 &&\
  rm wownero-x86_64-linux-gnu-v$WOWNERO_VERSION.tar.bz2 &&\
  cp ./wownero-x86_64-linux-gnu-v$WOWNERO_VERSION/wownerod . &&\
  rm -r wownero-*

FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update && apt-get install --no-install-recommends -y wget
RUN useradd -ms /bin/bash wownero && mkdir -p /home/wownero/.wownero && chown -R wownero:wownero /home/wownero/.wownero
USER wownero
WORKDIR /home/wownero

COPY --chown=wownero:wownero --from=build /root/wownerod /home/wownero/wownerod

# blockchain location
VOLUME /home/wownero/.wownero

EXPOSE 34567
EXPOSE 34568

HEALTHCHECK --interval=30s --timeout=5s CMD wget --no-verbose --tries=1 --spider http://localhost:34568/get_info || exit 

ENTRYPOINT ["./wownerod"]
CMD ["--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=34567", "--non-interactive", "--restricted-rpc", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=34568", "--confirm-external-bind", "--out-peers=16"]
