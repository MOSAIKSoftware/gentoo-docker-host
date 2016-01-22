# Priviliged docker image running docker

This image is meant to be run privileged, e.g.:
```sh
docker run \
	--privileged=true \
	-ti \
	<image-name> \
	bash
```

This image depends on the following remote repositories which are
fetched during build time:
* /etc/paludis server config: https://github.com/hasufell/gentoo-server-config.git
* main gentoo repository: https://github.com/gentoo/gentoo.git
* self-hosted binpkg repository: https://github.com/hasufell/gentoo-binhost.git
* libressl overlay: https://github.com/hasufell/libressl.git
* mosaik overlay: https://github.com/MOSAIKSoftware/mosaik-overlay.git
