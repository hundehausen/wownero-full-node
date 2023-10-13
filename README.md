# wownero-full-node

docker image to run a wownero full node on mainnet

Disclaimer: I am not updating this image regularly. If you want to use it, you should check the release notes and update it manually.

# Usage

`docker run -tid --restart=always -v wowchain:/home/wownero/.wownero -p 34567:34567 -p 34568:34568 --name=wownerod hundehausen/wownero-full-node`

## Release Notes

### Important Notes
[Read the release notes, there are breaking changes in v0.11.0.3!]([https://git.wownero.com/wownero/wownero/releases](https://git.wownero.com/wownero/wownero/releases/tag/v0.11.0.3))

```
04.04.2023: initial release
30.05.2023: Kunty Karen, Point Release v0.11.0.3
31.05.2023: new commands for running wownerod
13.10.2023: Point Release v0.11.1.0
```

## Updating
Manual Way
```
docker pull hundehausen/wownero-full-node:latest
docker stop wownerod
docker rm wownerod
docker run -tid --restart=always -v wowchain:/home/wownero/.wownero -p 34567:34567 -p 34568:34568 --name=wownerod hundehausen/wownero-full-node
```

Automatic way
https://github.com/v2tec/watchtower

# Donations

I am supporting this image in my spare time and would be very happy about some donations to keep this going. You can support me by sending some XMR to: `89HEKdUFM2dJGDFLpV7CoLUW1Swux7iBMMCXMC5y3U2DihmrbYh6AEoanoHb8VPJrCDLTa9FJfooHdz1rGZH9L342TXwZh7`
