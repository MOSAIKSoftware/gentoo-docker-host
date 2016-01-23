FROM       hasufell/gentoo-amd64-paludis:latest
MAINTAINER Julian Ospald <hasufell@posteo.de>


##### PACKAGE INSTALLATION #####

# install etckeeper first
RUN chgrp paludisbuild /dev/tty && cave resolve -z -1 sys-apps/etckeeper -x && \
	rm -rf /usr/portage/distfiles/*

# clone repositories
RUN git clone --depth=1 https://github.com/hasufell/gentoo-binhost.git \
		/usr/gentoo-binhost && \
	git clone --depth=1 https://github.com/hasufell/libressl.git \
		/var/db/paludis/repositories/libressl && \
	git clone --depth=1 https://github.com/MOSAIKSoftware/mosaik-overlay.git \
		/var/db/paludis/repositories/mosaik-overlay

# rm paludis dir, because it will be added as a submodule later
RUN rm -rf /etc/paludis

# initialize etckeeper
RUN etckeeper init -d /etc && \
	git -C /etc config --local user.email "root@foo.com" && \
	git -C /etc config --local user.name "Root User" && \
	git -C /etc commit -am "Initial commit"

# add /etc/paludis config as submodule
RUN git -C /etc submodule add \
		https://github.com/hasufell/gentoo-server-config.git paludis && \
	git -C /etc commit -am "Add paludis submodule"

# create various paludis related directories/files and fix permissions
RUN mkdir -p /etc/paludis/tmp /srv/binhost && \
	touch /etc/paludis/tmp/cave_resume /etc/paludis/tmp/cave-search-index && \
	chown paludisbuild:paludisbuild /etc/paludis/tmp/cave_resume \
		/etc/paludis/tmp/cave-search-index /etc/paludis/tmp /srv/binhost && \
	chmod g+w /etc/paludis/tmp/cave_resume /etc/paludis/tmp/cave-search-index \
		/etc/paludis/tmp /srv/binhost

# add /etc/env.d/90cave
RUN echo 'CAVE_RESUME_FILE_OPT="--resume-file /etc/paludis/tmp/cave_resume"' \
		> /etc/env.d/90cave && \
	echo 'CAVE_SEARCH_INDEX=/etc/paludis/tmp/cave-search-index' \
		>> /etc/env.d/90cave

# sync
RUN chgrp paludisbuild /dev/tty && env-update && . /etc/profile && cave sync

# add sets
RUN chgrp paludisbuild /dev/tty && \
	cave update-world --set server && \
	cave update-world --set tools

# install everything
RUN chgrp paludisbuild /dev/tty && \
	cave resolve -e world -x -f \
		--permit-old-version '*/*' -F sys-fs/eudev -U sys-fs/udev && \
	cave resolve -e world -x \
		--permit-old-version '*/*' -F sys-fs/eudev -U sys-fs/udev && \
	rm -rf /srv/binhost/* /usr/portage/distfiles/*

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

################################


# add our /etc/init.d/docker-services template
COPY docker-services /etc/init.d/docker-services
RUN chmod +x /etc/init.d/docker-services
