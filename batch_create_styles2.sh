#!/usr/bin/env bash

VIDDIR=/home/chuck/projects/neural-style/examples/inputs/VID
OUTVIDDIR=/home/chuck/projects/neural-style/processed_vid

function run_neural_style {
  FILES=$1
  NEWVIDDIR=$2
  STYLE=$3

  PREVIMAGE=""
  ls ${FILES} | tac | while read INIMAGE;
  do
    OUTIMAGE="${INIMAGE/VID/${NEWVIDDIR}}"
    echo "--------------------------------------------------------------"
    echo "Processing image=${INIMAGE}, saving as ${OUTIMAGE}..."

    if [ -f "${OUTIMAGE}" ]; then
      echo "${OUTIMAGE}" already saved. Skipping...
      PREVIMAGE=${OUTIMAGE}
      continue
    fi

    # lock the file
    touch "${OUTIMAGE}"

    STYLEIMAGE=examples/inputs/${STYLE}.jpg
    if [ ! -z "${PREVIMAGE}" ]; then
      STYLEIMAGE="${STYLEIMAGE},${PREVIMAGE}"
    fi
    echo "STYLEIMAGE=${STYLEIMAGE}"
    th neural_style.lua \
      -style_image ${STYLEIMAGE} \
      -content_image "${INIMAGE}" \
      -output_image "${OUTIMAGE}" \
      -model_file models/nin_imagenet_conv.caffemodel \
      -proto_file models/train_val.prototxt \
      -gpu 1 \
      -backend nn \
      -optimizer lbfgs \
      -num_iterations 1000 \
      -seed 9257042 \
      -content_layers relu0,relu3,relu7,relu12 \
      -style_layers relu0,relu3,relu7,relu12 \
      -content_weight 10 \
      -style_weight 1000 \
      -image_size 512 \
      -save_iter 0
    PREVIMAGE=${OUTIMAGE}
  done
}

#declare -a STYLES=("picasso_selfport1907" "starry_night" "the_scream" "woman-with-hat-matisse")
#declare -a STYLES=("starry_night" "the_scream" "woman-with-hat-matisse")
#declare -a STYLES=("tubingen")
#declare -a STYLES=("picasso_selfport1907" "starry_night" "the_scream" "woman-with-hat-matisse" 
declare -a STYLES=("escher_sphere" "frida_kahlo" "picasso_selfport1907" "seated-nude" "shipwreck" "starry_night" "the_scream" "woman-with-hat-matisse")

## now loop through the above array
for STYLE in "${STYLES[@]}"
do
  echo "--------------------------------------------------------------"
  echo "--------------------------------------------------------------"
  echo Processing "${STYLE}"
  echo "--------------------------------------------------------------"
  echo "--------------------------------------------------------------"

  # mkdir
  NEWVIDDIRFULL="${VIDDIR/VID/NEWVID2_${STYLE}}"
  mkdir -p "${NEWVIDDIRFULL}"
  NEWVIDDIRRELATIVE=$(basename ${NEWVIDDIRFULL})

  # loop over all images
  FILES=${VIDDIR}/*.jpg

  run_neural_style "${FILES}" "${NEWVIDDIRRELATIVE}" "${STYLE}"

done
