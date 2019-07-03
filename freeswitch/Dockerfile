FROM rjp44/drachtio-freeswitch-modules

LABEL maintainer="Rob Pickering <rob@aplisay.uk>"

COPY build.sh /
COPY templates /templates

EXPOSE 5061/tcp 8080/tcp 8443/tcp

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
