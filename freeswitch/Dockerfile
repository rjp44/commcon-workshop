FROM drachtio/drachtio-freeswitch-mrf:grpc

LABEL maintainer="Rob Pickering <rob@aplisay.uk>"

COPY templates /templates/

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
