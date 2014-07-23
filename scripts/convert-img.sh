#!/bin/bash

# convert image sizes
# $1 = image path

CONVERT=convert

bailout(){
    echo "ERROR: $@"
    exit -1
}

[ -n "$1" ] || bailout "I need the image path as first argument"
[ -n "$2" ] || bailout "I need the document format as second argument"
[ -n "$3" ] || bailout "I need the destination dir as third argument"

IMAGE_PATH=$1
RULES_FILE=${IMAGE_PATH}.sizes
FORMAT=$2
DEST_DIR=$3

[ -f "$IMAGE_PATH" ] || bailout "File '$IMAGE_PATH' not found"
[ -d "$DEST_DIR" ] || bailout "Directory '$DEST_DIR' doesn not exists"
DEST_FILE=$(basename ${IMAGE_PATH})

if [ -f "$RULES_FILE" ]; then

    FORMAT_RULE=$(grep -v ^\# "$RULES_FILE" | grep "^${FORMAT}:" | sed -e s/$FORMAT://g)
    [ -z "$FORMAT_RULE" ] && FORMAT_RULE=$(grep -v ^\# "$RULES_FILE" | grep ALL | sed -e s/^ALL://1)
    if [ -n "$FORMAT_RULE" ]; then
        echo "Found format rule: '$FORMAT_RULE'"


        echo "Image resizing and copying to '${DEST_DIR}/${DEST_FILE}'"
        $CONVERT $FORMAT_RULE "$IMAGE_PATH" "${DEST_DIR}/${DEST_FILE}"
        exit
    fi
fi

echo "Copying image to '${DEST_DIR}/${DEST_FILE}'"
echo cp "$IMAGE_PATH" "${DEST_DIR}/${DEST_FILE}"
