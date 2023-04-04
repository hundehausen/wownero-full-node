FROM --platform=linux/amd64 ubuntu:22.04 AS build
LABEL author="hundehausen" \
      maintainer="hundehausen"
      
ENV WOWNERO_VERSION=0.11.0.1 WOWNERO_SHA256=a011cd6b637f5ed7298b03daa9b6ba239143e14626a4da567e2a0943d69f4c61

RUN apt-get update && apt-get install -y curl bzip2

WORKDIR /root

RUN curl -L -o wownero-x86_64-linux-gnu-v$WOWNERO_VERSION.tar.bz2 https://git.wownero.com/attachments/64602dc5-5906-4600-89ef-9b4c0bdc0980 &&\
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
