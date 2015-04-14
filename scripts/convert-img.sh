#!/bin/bash

# convert image sizes
# $1 = image path
FALLBACK_RULES_FILE=fallback.sizes
CONVERT=convert

d_echo(){
    echo "$0: $@"
}
bailout(){
    d_echo "ERROR: $@"
    exit -1
}

get_format_rule(){
    local FORMAT=$1
    local RULES_FILE=$2
    
    FORMAT_RULE=$(grep -v ^\# "$RULES_FILE" | grep "^${FORMAT}:" )
    if [ -z "$FORMAT_RULE" ];then
        d_echo "'$FORMAT' format rule file not found"
    elif [ "$FORMAT_RULE" == "${FORMAT}:" ];then
        d_echo "Void '$FORMAT' format rule found, nothing to do"
        FORMAT_RULE="nothing"
    else
        FORMAT_RULE=${FORMAT_RULE#${FORMAT}:}
        d_echo "'$FORMAT' format rule found: $FORMAT_RULE"
    fi

}

[ -n "$1" ] || bailout "I need the image path as first argument"
[ -n "$2" ] || bailout "I need the document format as second argument"
[ -n "$3" ] || bailout "I need the destination dir as third argument"

IMAGE_PATH=$1
RULES_FILE_FILE=${IMAGE_PATH}.sizes
FALLBACK_RULES_FILE="$(dirname ${IMAGE_PATH})/$FALLBACK_RULES_FILE"
FORMAT=$2
DEST_DIR=$3

[ -f "$IMAGE_PATH" ] || bailout "File '$IMAGE_PATH' not found"
[ -d "$DEST_DIR" ] || bailout "Directory '$DEST_DIR' doesn not exists"
DEST_FILE=$(basename ${IMAGE_PATH})

if [ -f "$RULES_FILE_FILE" ]; then
    RULES_FILE="$RULES_FILE_FILE"
else
    d_echo "Using Fallback file: $FALLBACK_RULES_FILE"
    RULES_FILE="$FALLBACK_RULES_FILE"
fi

if [ -f "$RULES_FILE" ]; then
    FORMAT_RULE=
    get_format_rule "$FORMAT" "$RULES_FILE"
    if [ "$FORMAT_RULE" != "nothing" ];then
        # if normat rule not found falback to "ALL" format
        [ -z "$FORMAT_RULE" ] && get_format_rule ALL "$RULES_FILE"
        if [ -n "$FORMAT_RULE" ] && [ "$FORMAT_RULE" != "nothing" ]; then
            d_echo "Found format rule: '$FORMAT_RULE'"

            d_echo "Image resizing and copying to '${DEST_DIR}/${DEST_FILE}'"
            echo $CONVERT $FORMAT_RULE "$IMAGE_PATH" "${DEST_DIR}/${DEST_FILE}"
            $CONVERT $FORMAT_RULE "$IMAGE_PATH" "${DEST_DIR}/${DEST_FILE}"
            exit
        fi
    fi
fi

d_echo "Copying image to '${DEST_DIR}/${DEST_FILE}'"
cp "$IMAGE_PATH" "${DEST_DIR}/${DEST_FILE}"
