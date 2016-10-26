#!/usr/bin/env bash

VIDDIR=/home/chuck/projects/neural-style/examples/inputs/VID

function run_neural_style {
  FILES=$1
  NEWVIDDIR=$2
  STYLE=$3
  ls ${FILES} | tac | while read INIMAGE;
  do
    OUTIMAGE="${INIMAGE/VID/${NEWVIDDIR}}"
    echo "--------------------------------------------------------------"
    echo "Processing image=${INIMAGE}, saving as ${OUTIMAGE}..."

    if [ -f "${OUTIMAGE}" ]; then
      echo "${OUTIMAGE}" already saved. Skipping...
      continue
    fi

    # lock the file
    touch "${OUTIMAGE}"

    th neural_style.lua \
      -style_image examples/inputs/${STYLE}.jpg \
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
  done
}

function run_neural_style_reverse {
  FILES=$1
  NEWVIDDIR=$2
  STYLE=$3
  ls ${FILES} | while read INIMAGE;
  do
    OUTIMAGE="${INIMAGE/VID/${NEWVIDDIR}}"
    echo "--------------------------------------------------------------"
    echo "Processing image=${INIMAGE}, saving as ${OUTIMAGE}..."

    if [ -f "${OUTIMAGE}" ]; then
      echo "${OUTIMAGE}" already saved. Skipping...
      continue
    fi

    # lock the file
    touch "${OUTIMAGE}"

    th neural_style.lua \
      -style_image examples/inputs/${STYLE}.jpg \
      -content_image "${INIMAGE}" \
      -output_image "${OUTIMAGE}" \
      -model_file models/nin_imagenet_conv.caffemodel \
      -proto_file models/train_val.prototxt \
      -gpu 0 \
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
  done
}

#declare -a STYLES=("picasso_selfport1907" "starry_night" "the_scream" "woman-with-hat-matisse")
#declare -a STYLES=("starry_night" "the_scream" "woman-with-hat-matisse")
declare -a STYLES=("tubingen")

## now loop through the above array
for STYLE in "${STYLES[@]}"
do
  echo "--------------------------------------------------------------"
  echo "--------------------------------------------------------------"
  echo Processing "${STYLE}"
  echo "--------------------------------------------------------------"
  echo "--------------------------------------------------------------"

  # mkdir
  NEWVIDDIRFULL="${VIDDIR/VID/NEWVID_${STYLE}}"
  mkdir -p "${NEWVIDDIRFULL}"
  NEWVIDDIRRELATIVE=$(basename ${NEWVIDDIRFULL})

  # loop over all images
  FILES=${VIDDIR}/*.jpg

  run_neural_style         "${FILES}" "${NEWVIDDIRRELATIVE}" "${STYLE}" &
  run_neural_style_reverse "${FILES}" "${NEWVIDDIRRELATIVE}" "${STYLE}"

  sleep 5

  ffmpeg \
    -framerate 25 \
    -i ${NEWVIDDIRFULL}/20160610_173817_%06d.jpg \
    -c:v libx264 \
    ./VID_${STYLE}_20160610_173817.mp4

done
