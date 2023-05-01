#!/usr/bin/env bash
#
# metadata_finder.sh - Search and analyze metadata of specified file types
#
# ------------------------------------------------------------------------ #
#  Find and show metadata of files, all through google, lynx and exiftool
#
#  Examples:
#      $ ./metadata_finder.sh example.com pdf -d 1
#      Find all pdf files of example.com available on google and show up with the 
#           metadata
# ------------------------------------------------------------------------ #
# Tested:
#   bash 5.1.16
#   zsh 5.8.1
# ------------------------------------------------------------------------ #

# ------------------------------- VARIABLES ----------------------------------------- #
RED="\e[31m"
GREEN="\e[32m"
LGRAY="\e[37m"
ENDCOLOR="\e[0m"

USAGE="
$(basename $0)
    -h      - Show help
    -url    - Target's URL
    -type   - Desired file type
    -save   - Keep files instead of deleting them
    -v      - Verbose
"
URL=""
FILETYPE=""
SAVE_FILES=0
VERBOSE=0
# ------------------------------------------------------------------------ #

# ------------------------------- TESTS ----------------------------------------- #
[ ! -x "$(which wget)" ] && echo -e "${RED}Necessary binary \"wget\" not found" && exit 1
[ ! -x "$(which lynx)" ] && echo -e "${RED}Necessary binary \"lynx\" not found" && exit 1
[ ! -x "$(which exiftool)" ] && echo -e "${RED}Necessary binary \"exiftool\" not found" && exit 1

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUTION ----------------------------------------- #
if [ -z "$1" ]
then
    echo "$USAGE"
    exit 0
fi

while test -n "$1"
do
    case "$1" in
        -url) shift && URL="$1"             ;;
        -type) shift && FILETYPE="$1"       ;;
        -v) VERBOSE=1                       ;;
        -save) SAVE_FILES=1                 ;;
        *) echo "$USAGE" && exit 1          ;;
    esac
    shift
done

[ $VERBOSE -eq 1 ] && echo -e "${LGRAY}Searching for files..."

lynx --dump "https://google.com/search?q=site:$URL+ext:$FILETYPE" | grep "\.$FILETYPE" | cut -d "=" -f2 | egrep -v "google|site" | grep "http" | sed 's/...$//' > $URL.log

for i in $(cat $URL.log)
do
    [ $VERBOSE -eq 1 ] && echo -e "${GREEN}Downloading file: $i ${ENDCOLOR}"
	wget -q $i
done

exiftool *.$FILETYPE

if [ $SAVE_FILES -ne 1 ]
then
    [ $VERBOSE -eq 1 ] && echo -e "${LGRAY}Cleaning up..."
    rm $URL.log
    rm *.$FILETYPE
fi
# ------------------------------------------------------------------------ #
