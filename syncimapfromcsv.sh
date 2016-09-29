#!/bin/bash
# Hilighy inspired by # $Id: sync_loop_unix.sh,v 1.6 2015/11/04 18:23:04 gilles Exp gilles
# Depends on: http://imapsync.lamiral.info/  -> imapsync must be in your PATH

##### Improvements #################################################
# * - Takes a CSV as inpute                                      ###
# * - Tailor-made for my needs                                   ###
# * - Escaping vars for passwords containing chars like "*", ";" ###
# * - Counting errors ##############################################

echo "=== IMAP SYNC of multiples mails account from file $1 ==="
if [ ! -f "$1" ]; then
    echo "$1 is not a file - please double check"
fi

# setting error-checking parameters 

INFILE=$1
PARAMS=0

{ while IFS=';' read -r  h1 u1 p1 h2 u2 p2
do

    # If looping for the 2nd time, PARAMS must be set back to 0
    PARAMS=0
    DERRORS=99999
    if [ ! -z "$h1" ]; then echo "h1 is not NULL"; ((PARAMS=PARAMS+1)); fi
    if [ ! -z "$u1" ]; then echo "u1 is not NULL"; ((PARAMS=PARAMS+1)); fi
    if [ ! -z "$p1" ]; then echo "p1 is not NULL"; ((PARAMS=PARAMS+1)); fi
    if [ ! -z "$h2" ]; then echo "h2 is not NULL"; ((PARAMS=PARAMS+1)); fi
    if [ ! -z "$u2" ]; then echo "u2 is not NULL"; ((PARAMS=PARAMS+1)); fi
    if [ ! -z "$p2" ]; then echo "p1 is not NULL"; ((PARAMS=PARAMS+1)); fi
    echo "$h1;$u1;$p1;$h2;$u2;$p2"
    #  Not the best way but .. check if enough parameters were given.
    if [ ! "$PARAMS" -eq 6 ]; then echo -n "please check your file - not all parameters required are present"; exit 1; fi

    echo "-----------------------------------------------------"
    echo "User $u1 on host $h1 with password $p1"
    echo -n " will be migrated on "
    echo "host $h2 with username $u2 and password $p2"
    echo "-----------------------------------------------------"

    # Will now use IMAPSYNC tool to sync those IMAP accounts over SSL.
    echo "====================================== BEGIN  $u1 ===================================="
    imapsync --ssl1 --host1 "$h1" --port1 993 --user1 "$u1" --password1 "$p1" --ssl2 --host2 "$h2" --user2 "$u2" --password2 "$p2" --port2 993 >> tmpsyncout
    echo "====================================== END    $u0 ===================================="
    
    # DERRORS will now contain the number of errors imapsync encountered
    DERRORS=$(egrep "^Detected.*errors" tmpsyncout|cut -d' ' -f2)
    if [ ! "$DERRORS" -eq 0 ]; then
    echo "Execution: Errors - (DERRORS = "$DERRORS")"
    fi


    # we are done - we unset so were ready to loop over once again
    PARAMS=0
    DERRORS=999999
    unset h1 u1 p1 h2 u2 p2 DERRORS
    rm tmpsyncout

done } < "$INFILE"

