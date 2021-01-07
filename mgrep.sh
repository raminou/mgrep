#!/bin/bash
args=($0 "$@")
PROGNAME=$(basename ${args[0]})

PATTERN=""
EXCLUDE_FILE_ARRAY=()
EXCLUDE_STRING=""
INCLUDE_FILE_ARRAY=()
INCLUDE_STRING=""
usage()
{
    echo "${PROGNAME} PATTERN [-e|--exclude PARAMS ...] [-i|--include PARAMS ...] [-h|--help] [-v|--version] [--case]"
    echo ""
}

if [[ ${#args[*]} -lt 1 ]] ; then
    usage
    exit 1
fi

PATTERN="${args[1]}"
EXCLUDE=0
CASE=1

for i in $(seq 2 ${#args[*]}) ; do
    case ${args[$i]} in
        -h|--help) usage
            exit 0;;
        -v|--version) echo ""
            exit 0;;
        -e|--exclude)
            EXCLUDE=1
            INCLUDE=0;;
        -i|--include)
            INCLUDE=1
            EXCLUDE=0;;
        --case)
            CASE=0;;
        *)
            if [[ $EXCLUDE -eq 1 ]] ; then
                EXCLUDE_FILE_ARRAY+=(${args[$i]})
                EXCLUDE_STRING+="| grep -v \"${args[$i]}\""
            elif [[ $INCLUDE -eq 1 ]] ; then
                INCLUDE_FILE_ARRAY+=(${args[$i]})
                INCLUDE_STRING+="| grep \"${args[$i]}\""
            else
                echo "Invalid command line"
                exit 1
            fi
            ;;
    esac
done

if [[ ${CASE} -eq "1" ]] ; then
    cmd="grep -Ril ${PATTERN}"
else
    cmd="grep -Rl ${PATTERN}"
fi

# for f in $(grep -Ril "${PATTERN}") ; do
for f in $($cmd) ; do
    valid=1
    for exclude_f in ${EXCLUDE_FILE_ARRAY[@]} ; do
        res=$(echo $f | grep -v "${exclude_f}")
        status=$?
        if [[ "$status" -ne 0 ]] ; then
            valid=0
            break
        fi
    done

    for include_f in ${INCLUDE_FILE_ARRAY[@]} ; do
        res=$(echo $f | grep ${include_f})
        if [[ $? -ne 0 ]] ; then
            valid=0
            break
        fi
    done
    if [[ ${valid} -eq 1 ]] ; then
        echo $f
        if [[ ${CASE} -eq "1" ]] ; then
            grep -i -n --color=ALWAYS "${PATTERN}" "$f"
        else
            grep -n --color=ALWAYS "${PATTERN}" "$f"
        fi
        echo
    fi
done

