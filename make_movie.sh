#!/usr/bin/env bash

VIDDIR=/home/chuck/projects/neural-style/examples/inputs/VID

# ffmpeg -i examples/inputs/VID_20160610_173817.mp4 -c:a copy -vn  VID_audio_20160610_173817.m4a

#declare -a STYLES=("picasso_selfport1907" "starry_night" "the_scream" "woman-with-hat-matisse" "starry_night" "the_scream" "woman-with-hat-matisse")
#declare -a STYLES=("picasso_selfport1907" "starry_night" "the_scream" "woman-with-hat-matisse" "frida_kahlo" "escher_sphere")
#declare -a STYLES=("picasso_selfport1907" "starry_night" "the_scream" "woman-with-hat-matisse" "frida_kahlo" "escher_sphere")
declare -a STYLES=("escher_sphere" "frida_kahlo" "picasso_selfport1907" "seated-nude" "shipwreck" "starry_night" "the_scream" "woman-with-hat-matisse")

## now loop through the above array
for STYLE in "${STYLES[@]}"
do
  echo "--------------------------------------------------------------"
  echo Processing "${STYLE}"
  echo "--------------------------------------------------------------"

  NEWVIDDIRFULL="${VIDDIR/VID/NEWVID2_${STYLE}}"
  OUTVIDEO=./VID2_${STYLE}_20160610_173817.mp4

  if [ -f "${OUTVIDEO}" ]; then
    echo "[Info] Skipping video=${OUTVIDEO}..."
    continue
  fi

  TMPVIDEO=./_no_audio_VID_${STYLE}_20160610_173817.mp4
  ffmpeg \
    -y \
    -framerate 30 \
    -i ${NEWVIDDIRFULL}/20160610_173817_%06d.jpg \
    -c:v libx264 \
    ${TMPVIDEO}

  ffmpeg \
    -y \
    -i ${TMPVIDEO} \
    -i VID_audio_20160610_173817.m4a \
    -c copy \
    ${OUTVIDEO}

  rm -f ./_no_audio_VID_${STYLE}_20160610_173817.mp4

done
