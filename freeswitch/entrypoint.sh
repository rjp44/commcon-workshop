#!/bin/bash
# run as user freeswitch
FREESWITCH_USER=${FREESWITCH_USER:-freeswitch}
FREESWITCH_DOMAIN=${FREESWITCH_DOMAIN:-localhost.localdomin}
FREESWITCH_ORG=${FREESWITCH_ORG:-AcmeWidgets}
export freeswitch_sip_port=${FREESWITCH_SIP_PORT:-5080}
export freeswitch_dtls_sip_port=${FREESWITCH_DTLS_SIP_PORT:-5081}
export rtp_start_port=${FREESWITCH_RTP_START_PORT:-25000}
export rtp_end_port=${FREESWITCH_RTP_END_PORT:-25020}
CREDENTIALS="/credentials/google.json"

SUBST=" "
for VAR in $(env);
do
  IFS="=" read -r NAME VALUE <<<$VAR
  EVALUE=$(sed -e 's/\//\\\//g' <<<$VALUE)
  SUBST+=`printf "%ss/___%s___/%s/" " -e " "\\\$$NAME" "$EVALUE"`
done

export GOOGLE_APPLICATION_CREDENTIALS="${CREDENTIALS}";

if [ ! -f $GOOGLE_APPLICATION_CREDENTIALS ]; then
  echo "NO ${GOOGLE_APPLICATION_CREDENTIALS}      please supply..." && exit 1
fi

if [ "$1" = "" ]; then
  COMMAND="/usr/local/freeswitch/bin/freeswitch -db /dev/shm -log /usr/local/freeswitch/log -conf /usr/local/freeswitch/conf -run /usr/local/freeswitch/run"
else
  COMMAND="$@"
fi

# Recursively copy any templated config files (with ENV substitution)
for DIR in /templates/all
do
  if [ -d ${DIR} ]; then
    cd ${DIR}
    for FILE in `find . -type f -print`
    do
      sed $SUBST <${FILE} >/${FILE}
    done
  else
    echo NO Template for ${DIR} - this is probably bad.
    exit 1;
  fi
done


INTERNAL_IP=`ip -o a  | grep eth0  | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1`
# So horrid, but doesn't need extra binaries
EXTERNAL_IP=`wget -qO- http://ifconfig.me | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | xargs echo`
cat >/usr/local/freeswitch/conf/addresses.xml <<__EOF__
<include>
  <X-PRE-PROCESS cmd="set" data="internal_ip=${INTERNAL_IP}"/>
  <X-PRE-PROCESS cmd="set" data="external_ip=${EXTERNAL_IP}"/>
  <X-PRE-PROCESS cmd="set" data="lan_ip=${INTERNAL_IP}"/>
</include>
__EOF__

if [ "${FREESWITCH_UID}" != "" ] && [ "${FREESWITCH_GID}" != "" ]; then
  # recreate user and group for freeswitch
  deluser freeswitch && \
  adduser --gecos "" --no-create-home --uid ${FREESWITCH_UID} --disabled-password ${FREESWITCH_USER} || exit
  chown -R ${FREESWITCH_UID}:${FREESWITCH_UID} /usr/local/freeswitch \
                                           /var/*/freeswitch
fi

exec ${COMMAND}
