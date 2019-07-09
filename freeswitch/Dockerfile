FROM rjp44/drachtio-freeswitch-modules

LABEL maintainer="Rob Pickering <rob@aplisay.uk>"

COPY templates/* /templates/

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
