FROM --platform=linux/amd64 ubuntu:22.04 AS build
LABEL author="hundehausen" \
      maintainer="hundehausen"
      
ENV WOWNERO_VERSION=0.11.1.0 WOWNERO_SHA256=a5b2aa0cffa4c7bf82d9d6072aca0bdeb501bdbde33db1d04edb2c4089878e82

RUN apt-get update && apt-get install -y curl bzip2

WORKDIR /root

RUN curl -L -o wownero-x86_64-linux-gnu-v$WOWNERO_VERSION.tar.bz2 https://git.wownero.com/attachments/280753b0-3af0-4a78-a248-8b925e8f4593 &&\
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
CMD ["--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=34567", "--non-interactive", "--restricted-rpc", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=34568", "--confirm-external-bind", "--out-peers=32", "--enforce-dns-checkpointing", "--add-priority-node=143.198.195.132:34567", "--add-priority-node=134.122.53.193:34567", "--add-priority-node=204.48.28.218:34567"]
