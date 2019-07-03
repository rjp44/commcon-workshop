#!/bin/bash
# run as user freeswitch
FREESWITCH_USER=${FREESWITCH_USER:-freeswitch}
FREESWITCH_DOMAIN=${FREESWITCH_DOMAIN:-localhost.localdomin}
FREESWITCH_ORG=${FREESWITCH_ORG:-AcmeWidgets}
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
  COMMAND="/usr/local/freeswitch/bin/freeswitch"
else
  COMMAND="$@"
fi

# Recursively copy any templated config files (with ENV substitution)
for DIR in /templates/all /templates/${TRUNK_TYPE}
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

if [ "${FREESWITCH_UID}" != "" ] && [ "${FREESWITCH_GID}" != "" ]; then
  # recreate user and group for freeswitch
  deluser freeswitch && \
  adduser --gecos "" --no-create-home --uid ${FREESWITCH_UID} --disabled-password ${FREESWITCH_USER} || exit
  chown -R ${FREESWITCH_UID}:${FREESWITCH_UID} /usr/local/freeswitch \
                                           /var/*/freeswitch
fi

exec ${COMMAND}
