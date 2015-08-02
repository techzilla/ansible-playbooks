#!/bin/sh
##
## FILE: ssl-webenroll.sh
##
## DESCRIPTION: AD CS Web Enroll CSR
##

## Exit Point
die() {
	[ -n "$2" ] && echo "$2"
	exit $1
}

U_CA="$1"
F_CSR="$2"
F_CRT="$3"

## UrlEncode CSR
E_CSR=`cat $F_CSR | hexdump -v -e '1/1 "%02x\t"' -e '1/1 "%_c\n"' |
LANG=C awk '
    $1 == "20"                      { printf("%s",      "+");   next    }
    $2 ~  /^[a-zA-Z0-9.*()\/-]$/    { printf("%s",      $2);    next    }
                                    { printf("%%%s",    $1)             }'`

# Web Enrollment POST, ReqID Capture
REQ_ID=`curl --negotiate -u : -d CertRequest=${E_CSR} -d SaveCert=yes -d Mode=newreq -d CertAttrib=CertificateTemplate:WebServer ${U_CA}/certfnsh.asp | grep -o 'certnew.cer?ReqID=[[:digit:]]\+&amp;Enc=b64' | sed 's/certnew.cer?ReqID=\([[:digit:]]\+\)&amp;Enc=b64/\1/'`

## Download CRT
curl -o "${F_CRT}" --negotiate -u : "${U_CA}/certnew.cer?ReqID=${REQ_ID}&Enc=b64"

## Exit Jump
die 0
