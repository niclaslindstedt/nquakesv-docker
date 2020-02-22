#!/bin/sh

error() {
  echo "ERROR: $1"
  exit 1
}

echo "Setting defaults..."
[ ! -s "$HOSTNAME" ] && export HOSTNAME="nQuake KTX Server"
[ ! -s "$LISTEN_PORT" ] && export LISTEN_PORT=27500
[ ! -s "$QTV_STREAMPORT" ] && export QTV_STREAMPORT=27500
[ ! -s "$RCON_PASSWORD" ] && export RCON_PASSWORD="changeme"
[ ! -s "$SERVER_ADMIN" ] && export SERVER_ADMIN="anon <anonymous@example.com>"
[ ! -s "$REPORT_URL" ] && export REPORT_URL="https://badplace.eu"
[ ! -s "$REPORT_KEY" ] && export REPORT_KEY="askmeag"

[ ! -f /nquake/id1/pak0.pak ] && {
  echo "Downloading external files..."
  (wget -qO qsw106.zip https://github.com/nQuake/distfiles/raw/master/qsw106.zip \
    && wget -qO sv-non-gpl.zip https://github.com/nQuake/distfiles/raw/master/sv-non-gpl.zip) || error "Could not download external files"

  echo "Extracting files..."
  (unzip -p qsw106.zip ID1/PAK0.PAK > /nquake/id1/pak0.pak \
    && unzip -qo sv-non-gpl.zip) || error "Could not extract external files"

  echo "Cleaning up installation..."
  (find . -type f -print0 | xargs -0 dos2unix -q \
    && rm *.zip) || error "Could not clean up installation"
}
echo "Copying QuakeWorld media to media volume..."
(mkdir -p /nquake/media/maps /nquake/media/progs /nquake/media/sound \
  && cp -rf /nquake/id1/maps/* /nquake/media/maps/ \
  && cp -rf /nquake/id1/progs/* /nquake/media/progs/ \
  && cp -rf /nquake/id1/sound/* /nquake/media/sound/ \
  && cp -rf /nquake/qw/maps/* /nquake/media/maps/) || error "Could not copy media files"

echo "Configuring nQuake..."
(envsubst < /nquake/ktx.cfg.template > /nquake/ktx/ktx.cfg \
  && envsubst < /nquake/mvdsv.cfg.template > /nquake/ktx/mvdsv.cfg \
  && envsubst < /nquake/pwd.cfg.template > /nquake/ktx/pwd.cfg) || error "Could not configure nQuake"

echo "Starting nQuake"
cd /nquake/
./mvdsv -game ktx
