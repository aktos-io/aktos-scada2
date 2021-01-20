#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
errcho(){ >&2 echo $@; }

find_scada_root () {
    local name=""
    testing_dir=$1
    while :; do
        name=$(basename $testing_dir)
        ls "$testing_dir/scada.js" > /dev/null 2>&1
        if [[ "$?" == "0" ]]; then
            echo "$testing_dir/scada.js"
            return 0
        elif [[ "$name" == "scada.js" ]]; then
            echo $testing_dir
            return 0
        elif [[ "$name" == "/" ]]; then
            return 255
        else
            testing_dir=$(realpath "$testing_dir/..")
        fi
    done
}

SCADA_DIR=$(find_scada_root $DIR)

if [[ -d $SCADA_DIR ]]; then
    #echo "DEBUG: found scada root: $SCADA_DIR"
    SCADA_MODULES="${SCADA_DIR}/lib"
    PROJECT_PATH=$(realpath "${SCADA_DIR}/..")

    #errcho "ScadaJS project path: ${PROJECT_PATH}"

    FOUND_MODULES=
    # add every `node_modules` into the path
    while IFS= read -r module; do
        #echo "++++++++++ adding path: $module"
        FOUND_MODULES="${FOUND_MODULES}:$module"
    done < <(find $PROJECT_PATH -type d -name "node_modules" 2> /dev/null | grep -v "node_modules\/" )
fi

export NODE_PATH="${SCADA_MODULES}:${FOUND_MODULES}:${NODE_PATH}"