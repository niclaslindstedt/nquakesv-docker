#!/bin/sh

error() {
  echo
  echo "ERROR: $1"
  exit 1
}

[ -z "$RCON_PASSWORD" ] && error "Please set an RCON_PASSWORD"
[ "$RCON_PASSWORD" = "changeme" ] && error "Please change the RCON_PASSWORD"

echo "============= nQuake server =============="
echo "Using settings:"
[ -z "$HOSTNAME" ] && export HOSTNAME="nQuake KTX Server"; echo " * HOSTNAME=$HOSTNAME"
[ -z "$PORT" ] && export PORT=27500; echo " * PORT=$PORT"
[ -z "$SERVER_ADMIN" ] && export SERVER_ADMIN="anon <anonymous@example.com>"; echo " * SERVER_ADMIN=$SERVER_ADMIN"
[ -z "$REPORT_URL" ] && export REPORT_URL="https://badplace.eu"; echo " * REPORT_URL=$REPORT_URL"
[ -z "$REPORT_KEY" ] && export REPORT_KEY="askmeag"; echo " * REPORT_KEY=$REPORT_KEY"
echo " * RCON_PASSWORD=$(echo $RCON_PASSWORD | sed 's/./*/g')"

[ -z "$SERVER_IP" ] && {
  echo
  echo -n "Detecting external IP..."
  export ADDRESS=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
  [ -z "$ADDRESS" ] && error "Could not detect external IP" || echo "OK ($ADDRESS)"
} || {
  export ADDRESS=$SERVER_IP; echo " * SERVER_IP=$SERVER_IP"
}

[ ! -f /nquake/id1/pak0.pak ] && {
  echo -n "Downloading necessary files..."
  (wget -qO qsw106.zip https://github.com/nQuake/distfiles/releases/download/snapshot/qsw106.zip \
    && wget -qO sv-non-gpl.zip https://github.com/nQuake/distfiles/releases/download/snapshot/sv-non-gpl.zip) || error "Could not download necessary files"
  echo "OK"

  echo -n "Extracting files..."
  (unzip -p qsw106.zip ID1/PAK0.PAK > /nquake/id1/pak0.pak \
    && unzip -qo sv-non-gpl.zip) || error "Could not extract necessary files"
  echo "OK"

  echo -n "Converting file formats..."
  find . -type f -print0 | xargs -0 dos2unix -q || error "Could not convert file formats"
  echo "OK"

  echo -n "Cleaning up downloaded files..."
  rm *.zip || error "Could not remove downloaded files"
  echo "OK"
}

echo -n "Replicating media to shared volume..."
(mkdir -p /nquake/media/maps /nquake/media/progs /nquake/media/sound \
  && cp -rf /nquake/id1/maps/* /nquake/media/maps/ \
  && cp -rf /nquake/id1/progs/* /nquake/media/progs/ \
  && cp -rf /nquake/id1/sound/* /nquake/media/sound/ \
  && cp -rf /nquake/qw/maps/* /nquake/media/maps/) || error "Could not copy media files"
echo "OK"

echo -n "Generating configuration files..."
(envsubst < /nquake/ktx.cfg.template > /nquake/ktx/ktx.cfg \
  && envsubst < /nquake/mvdsv.cfg.template > /nquake/ktx/mvdsv.cfg \
  && envsubst < /nquake/pwd.cfg.template > /nquake/ktx/pwd.cfg) || error "Could not configure nQuake"
echo "OK"

echo
echo "Initialization complete!"
echo

cd /nquake/
./mvdsv -port $PORT -game ktx
