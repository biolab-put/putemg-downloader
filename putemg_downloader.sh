#!/bin/bash

WGET="wget -c -N"
BASE_URL='https://chmura.put.poznan.pl/s/45NY5snj0U4tgQz/download?path=%2F'
VIDEO_1080p_DIR=Video-1080p
VIDEO_576p_DIR=Video-576p
DEPTH_DIR=Depth
DATA_HDF5_DIR=Data-HDF5
DATA_CSV_DIR=Data-CSV

set -e

function usage() {
    echo 'Usage:' `basename $0` '<experiment_type> <media_type> [<id1> <id2> ...]'
    echo
    echo 'Arguments:'
    echo '    <experiment_type>    comma-separated list of experiment types (supported types: emg_gestures, emg_force)'
    echo '    <media_type>         comma-separated list of media (supported types: data-csv, data-hdf5, depth, video-1080p, video-576p)'
    echo '    [<id1> <id2> ...]    optional list of two-digit participant IDs, fetches all if none are given'
    echo
    echo 'Examples:'
    echo `basename $0` emg_gestures data-hdf5,video-1080p
    echo `basename $0` emg_gestures,emg_force data-csv,depth 03 04 07
}

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    usage
    exit 1
fi

# parse experiment types
if [ "$1" == "emg_gestures" ]; then
    EXPERIMENT_TYPES=emg_gestures
elif [ "$1" == "emg_force" ]; then
    EXPERIMENT_TYPES='emg_force'
elif [ "$1" == "emg_force,emg_gestures" ] || [ "$1" == "emg_gestures,emg_force" ] ; then
    EXPERIMENT_TYPES='(emg_gestures|emg_force)'
else
    echo "Invalid experiment types $1"
    usage
    exit 1
fi

# parse media types
IFS=',' read -r -a media_types <<< "$2"
DATA_CSV=0
DATA_HDF5=0
DEPTH=0
VIDEO_1080P=0
VIDEO_576P=0

for m in "${media_types[@]}" ; do
    case "$m" in
    "data-csv")
        DATA_CSV=1
        ;;
    "data-hdf5")
        DATA_HDF5=1
        ;;
    "depth")
        DEPTH=1
        ;;
    "video-1080p")
        VIDEO_1080P=1
        ;;
    "video-576p")
        VIDEO_576P=1
        ;;
    *)
        echo "Invalid media type $m"
        usage
        exit 1
        ;;
    esac
done

# parse ids

if [ "$#" -gt 2 ]; then
    shift;shift
    IDS='('
    for id in "$@" ; do
        if [[ $id =~ ^[0-9]{2}$ ]] ; then
            IDS=${IDS}$id\|
        else
            echo "Invalid ID $id"
            usage
            exit 1
        fi
    done
    IDS=${IDS%'|'}\)
else
    IDS='[0-9]{2}'
fi

echo "$IDS"

echo EXPERIMENT_TYPES: $EXPERIMENT_TYPES
echo DATA_CSV: $DATA_CSV
echo DATA_HDF5: $DATA_HDF5
echo DEPTH: $DEPTH
echo VIDEO_1080P: $VIDEO_1080P
echo VIDEO_576P: $VIDEO_576P

REGEX="${EXPERIMENT_TYPES}-${IDS}"

records=`$WGET "$BASE_URL"'&files=records.txt' -O - --quiet | grep -E "$REGEX"`

if [ $DATA_CSV -eq 1 ] ; then
    mkdir -p "$DATA_CSV_DIR"
fi
if [ $DATA_HDF5 -eq 1 ] ; then
    mkdir -p "$DATA_HDF5_DIR"
fi
if [ $DEPTH -eq 1 ] ; then
    mkdir -p "$DEPTH_DIR"
fi
if [ $VIDEO_1080P -eq 1 ] ; then
    mkdir -p "$VIDEO_1080p_DIR"
fi
if [ $VIDEO_576P -eq 1 ] ; then
    mkdir -p "$VIDEO_576p_DIR"
fi

for r in $records ; do
    if [ $DATA_CSV -eq 1 ] ; then
        $WGET "$BASE_URL""$DATA_CSV_DIR"'&files='"${r}.zip" -O "$DATA_CSV_DIR"/"${r}.zip"
    fi
    if [ $DATA_HDF5 -eq 1 ] ; then
        $WGET "$BASE_URL""$DATA_HDF5_DIR"'&files='"${r}.hdf5" -O "$DATA_HDF5_DIR"/"${r}.hdf5"
    fi
    if [ $DEPTH -eq 1 ] ; then
        if [[ "$r" =~ ^emg_gestures.* ]] ; then
            $WGET "$BASE_URL""$DEPTH_DIR"'&files='"${r}.zip" -O "$DEPTH_DIR"/"${r}.zip"
        fi
    fi
    if [ $VIDEO_1080P -eq 1 ] ; then
        $WGET "$BASE_URL""$VIDEO_1080p_DIR"'&files='"${r}.mp4" -O "$VIDEO_1080p_DIR"/"${r}.mp4"
    fi
    if [ $VIDEO_576P -eq 1 ] ; then
        $WGET "$BASE_URL""$VIDEO_576p_DIR"'&files='"${r}.mp4" -O "$VIDEO_576p_DIR"/"${r}.mp4"
    fi
done
