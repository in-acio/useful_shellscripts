#!/usr/bin/env bash
#
# email_parser.sh - Find all (normal-formatted) e-mails
#
# ------------------------------------------------------------------------ #
#  Given a URL, this script will download it's main page and search for e-mails using regex
#
#  Examples:
#      $ ./email_parser.sh -url "example.com"
#      Go to example.com, download it's main page and print all located e-mails
# ------------------------------------------------------------------------ #

# ------------------------------- VARIABLES ----------------------------------------- #
USAGE="
    $(basename $0)
        -h    - Show help
        -url  - Target's URL
        -save - Keep used files
"
URL=""
SAVE_FILES=0
# ------------------------------------------------------------------------ #

# ------------------------------- TESTS ----------------------------------------- #
[ ! -x "$(which wget)" ] && echo -e "Necessary binary \"wget\" not found" && exit 1
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
        -save) SAVE_FILES=1                 ;;
        *) echo "$USAGE" && exit 1          ;;
    esac
    shift
done

wget -q $URL -O $URL.html
cat $URL.html | grep -E "[a-z0-9._%+-]{3,}@[a-z]{3,}([.]{1}[a-z]{2,}|[.]{1}[a-z]{2,}[.]{1}[a-z]{2,})" > $URL.log
	tr -s '[:space:]' '\t' < $URL.log > $URL.emails


rm $URL.log

if [ "$(cat $URL.emails)" == "" ]
then
	echo "Nothing was found :("
else
	cat $URL.emails
fi

[ $SAVE_FILES -ne 1 ] && rm $URL.emails $URL.html
# ------------------------------------------------------------------------ #
