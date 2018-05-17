FROM gentoo/portage
FROM gentoo/stage3-amd64

COPY --from=gentoo/portage /usr/portage /usr/portage

COPY portage /etc/portage
COPY world /var/lib/portage/world

RUN emerge --jobs 4 -u world \
 && rm -rf /usr/portage/distfiles/*

CMD /bin/bash -l
