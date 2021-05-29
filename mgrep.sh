#!/bin/bash
args=($0 "$@")
PROGNAME=$(basename ${args[0]})

PATTERN=""
EXCLUDE_FILE_ARRAY=()
EXCLUDE_STRING=""
INCLUDE_FILE_ARRAY=()
INCLUDE_STRING=""
EXCLUDE=0
CASE=1
BIN=1

usage()
{
    echo "${PROGNAME} PATTERN [-e|--exclude PARAMS ...] [-i|--include PARAMS ...] [-h|--help] [-v|--version] [--case] [--nobin]"
    echo -e "\t--exclude to exclude some filename pattern"
    echo -e "\t--include to accept only some filename patter"
    echo -e "\t--help to display this help"
    echo -e "\t--version to display the version"
    echo -e "\t--case to be case sensitive"
    echo -e "\t--nobin to refuse binary file"
    echo
    echo "Display the list of file which contains the PATTERN"
    echo ""
}

if [[ ${#args[*]} -lt 2 ]] ; then
    echo "Provide a PATTERN"
    usage
    exit 1
fi



LENGTH=$((${#args[*]} - 1))
for i in $(seq 1 $LENGTH) ; do
    if [[ ${args[$i]} != "" ]] ; then
        case ${args[$i]} in
            -h|--help) usage
                exit 0;;
            -v|--version) echo "1"
                exit 0;;
            -e|--exclude)
                EXCLUDE=1
                INCLUDE=0;;
            -i|--include)
                INCLUDE=1
                EXCLUDE=0;;
            --case)
                CASE=0;;
            --nobin)
                BIN=0;;
            *)
                if [[ $EXCLUDE -eq 1 ]] ; then
                    EXCLUDE_FILE_ARRAY+=(${args[$i]})
                    EXCLUDE_STRING+="| grep -v \"${args[$i]}\""
                elif [[ $INCLUDE -eq 1 ]] ; then
                    INCLUDE_FILE_ARRAY+=(${args[$i]})
                    INCLUDE_STRING+="| grep \"${args[$i]}\""
                else
                    if [[ ${PATTERN} = "" ]] ; then
                        PATTERN=${args[$i]}
                    else
                        echo "PATTERN already given"
                        exit 1
                    fi
                fi
                ;;
        esac
    fi
done

GREP_OPT="-Rl"
if [[ ${CASE} -eq "1" ]] ; then
    GREP_OPT+="i"
fi
if [[ ${BIN} -eq "0" ]] ; then
    GREP_OPT+="I"
fi

for f in $(grep ${GREP_OPT} "${PATTERN}" $PWD) ; do
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
        echo -e "\033[1m$f\033[0m"
        if [[ ${CASE} -eq "1" ]] ; then
            grep -i -n --color=ALWAYS "${PATTERN}" "$f"
        else
            grep -n --color=ALWAYS "${PATTERN}" "$f"
        fi
        echo
    fi
done

