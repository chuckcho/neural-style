#!/usr/bin/env bash

VIDDIR=/home/chuck/projects/neural-style/examples/inputs/VID
NEWVIDDIR=NEWVID
STYLE=picasso_selfport1907

# mkdir
NEWVIDDIRFULL="${VIDDIR/VID/${NEWVIDDIR}_${STYLE}}"
mkdir -p "${NEWVIDDIRFULL}"

# loop over all images
FILES=${VIDDIR}/*.jpg
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
