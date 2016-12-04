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
        # check error message
        error=`echo "$DEBRID" | python -c "import sys, json; print(json.load(sys.stdin)['error'])"`
        if [ $error = "premium" ]
        then
            echo "You're account is not a premium account!"
        else
            echo "Bad link"
        fi
    else
        #echo "$DEBRID" | sed -e 's/^.*"link"[ ]*:[ ]*"//' -e 's/".*//' | sed 's/\\//g'
        echo "$DEBRID" | python -c "import sys, json; print(json.load(sys.stdin)['link'])"
    fi
}

usage() {
    echo 'Usage: ./alldebrid.sh <url>'
    exit
}

if [ "$#" -ne 1 ]
then
    usage
else
    if [ -e "cookie-jar" ]
    then
        debrid "$1"
    else
        echo "Login"
        read login
        echo "Password"
        read -s password
        connect "$login" "$password"
        debrid "$1"
    fi
fi

