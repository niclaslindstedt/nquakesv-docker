#!/bin/sh

error() {
  echo $1
  exit 1
}

[ ! -f /nquake/id1/pak0.pak ] && {
  echo "Downloading external files..."
  (wget -qO qsw106.zip https://github.com/nQuake/distfiles/raw/master/qsw106.zip \
    && wget -qO sv-non-gpl.zip https://github.com/nQuake/distfiles/raw/master/sv-non-gpl.zip) || error "Could not download nQuake files"

  echo "Extracting files..."
  (unzip -p qsw106.zip ID1/PAK0.PAK > /nquake/id1/pak0.pak \
    && unzip -qo sv-non-gpl.zip) || error "Could not extract nQuake files"

  echo "Cleaning up installation..."
  (find . -type f -print0 | xargs -0 dos2unix -q \
    && rm *.zip) || error "Could not clean up nQuake files"
}

echo "Configuring nQuake..."
envsubst < /nquake/ktx.cfg.template > /nquake/ktx/ktx.cfg
envsubst < /nquake/mvdsv.cfg.template > /nquake/ktx/mvdsv.cfg
envsubst < /nquake/pwd.cfg.template > /nquake/ktx/pwd.cfg

echo "Starting nQuake"
cd /nquake/
./mvdsv -game ktx
