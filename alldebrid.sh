#!/bin/sh
#
# Debrid your link using Alldebrid
#
# Author : Ananasr
# Usage : alldebrid.sh <login> <password> <url>

ALLDEBRID_ROOT='https://alldebrid.com'

# connect LOGIN PASSWORD
connect() {
    LOCATION="$(curl --silent -I "$ALLDEBRID_ROOT/register/?action=login&returnpage=%2Faccount%2F&login_login=$1&login_password=$2" -c cookie-jar | perl -n -e '/^Location: (.*)\r$/ && print "$1\n"')"
    if [ "$LOCATION" != "https://alldebrid.com/account/" ]
    then
        echo 'Login failed'
    fi
}

# debrid URL
debrid() {
    DEBRID="$(curl --silent -b cookie-jar "$ALLDEBRID_ROOT/service.php?link=$1&json=true")"
    if (! echo "$DEBRID" | grep '"error":""') > /dev/null
    then
        echo 'Bad link'
    else
        echo "$DEBRID" | sed -e 's/^.*"link"[ ]*:[ ]*"//' -e 's/".*//' | sed 's/\\//g'
    fi
}

usage() {
    echo 'Usage: ./alldebrid.sh <login> <password> <url>'
    exit
}

if [ "$#" -ne 3 ]
then
    usage
else
    connect "$1" "$2"
    debrid "$3"
fi

