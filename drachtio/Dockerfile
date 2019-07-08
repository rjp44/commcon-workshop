FROM drachtio/drachtio-server:stable

LABEL maintainer="Rob Pickering <rob@aplisay.uk>"

COPY ./dh4096.pem /etc/ssl/dh4096.pem

RUN cd /etc/ssl
RUN mkdir private
RUN openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/key.pem -out /etc/ssl/cert.pem -days 365 -nodes  -subj '/CN=localhost'
RUN ls -l /etc/ssl /etc/ssl/private

COPY ./drachtio.conf.xml /etc/drachtio.conf.xml

ENTRYPOINT ["/entrypoint.sh"]

CMD ["drachtio"]
