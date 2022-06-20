#!/bin/bash


### Create SSL Certificate 4 Internal PKI


#### Some VariableZ

_ssldir=/data/SSL
_sslarchivedir=$_ssldir/archive


#### Some FunctionZ

show_usertext1()
{
    clear

    printf "Wie lautet der Fully Qualified Domain Name? (FQDN) \n"
    printf "\n\n Beispiel: rz-ksvw-mon01.haevg-rz.ag \n\n"
}

show_usertext2()
{
    printf "Willst du zusätzliche SAN einträge dann öffne eine neue Session und bearbeite jetzt die Datei: $_ssldir/$_san1/$_shortname.cfg \n\n"
    printf "Das Skript wurde so lange pausiert. \n\n"
}

show_usertext3()
{
    # INFO
    clear
    printf "\n --> Informationen <--"

    printf "Soll es ein Externes Zertifikat werden dann befolge diese Anleitung:  wiki.haevg-rz.ag/display/technik/externes_zertifikat \n"
    printf "Soll es ein Internes Zertifikat werden dann befolge diese Anleitung:  wiki.haevg-rz.ag/display/technik/internes_zertifikat \n"
}


get_shortname()
{
    echo $_fqdn | awk -F. '{print $1}'
}

get_domain()
{
    echo $_fqdn | awk -F. '{print $2}'
}

get_additional_san()
{
    printf "\n\nTragen Sie jetzt einen weiteren Namen ein. leer lassen wenn keine weitere notwendig sind \n"
    read _san3
}


create_ssldir()
{
    ### Erstelle benötigte Verzeichnisse.
    if [ ! -d "$_ssldir" ]; then
        echo "Erstelle die fehlenden Verzeichnisse."
        mkdir -p $_sslarchivedir
    fi

    ### Prüfe ob das SSL Verzeichnis existiert, wenn ja schiebe das verzeichnis mit einem Datum  nach $_sslarchivedir
    if [ -d "$_ssldir/$_fqdn" ]; then
        mv $_ssldir/$_fqdn $_sslarchivedir/$_fqdn-$(date +"%d.%m.%Y")
        echo "Da $_ssldir/$_fqdn bereits exisitiert, habe ich das bestehende Verzeichnis nach $_sslarchivedir/$_fqdn-$(date +"%d.%m.%Y") verschoben."
    fi

    mkdir $_ssldir/$_fqdn
}

## Lese Aktuelle SAN Konfig aus

create_cfg()
{
### Erzeuge Config für SSL

_domain=$(get_domain)

case "$_domain" in
  haevg-rz)

        cat > $_ssldir/$_fqdn/$_shortname.cfg <<EOF
[ req ]
default_bits                    = 4096
distinguished_name              = req_distinguished_name
req_extensions                  = req_ext
prompt                          = no
[ req_distinguished_name ]
countryName                     = DE
stateOrProvinceName             = NRW
localityName                    = Cologne
organizationName                = HaeVG Rechenzentrum GmbH
commonName                      = $_san1
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1   = $_san1
DNS.2   = $_san2
DNS.3   = $_san3

EOF
    ;;
  hausaerzteverband)
        cat > $_ssldir/$_fqdn/$_shortname.cfg <<EOF
[ req ]
default_bits                    = 4096
distinguished_name              = req_distinguished_name
req_extensions                  = req_ext
prompt                          = no
[ req_distinguished_name ]
countryName                     = DE
stateOrProvinceName             = NRW
localityName                    = Cologne
organizationName                = HAEVG Hausaerztliche Vertragsgemeinschaft AG
commonName                      = $_san1
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1   = $_san1
DNS.2   = $_san2
DNS.3   = $_san3

EOF

    ;;
esac
}

pauseme()
{
echo -n "Fahre fort mit 'create'. "
read yno
case $yno in
    [createCreate] | [Cc][Rr][Ee][Aa][Tt][Ee] )
        echo "Erstelle Zertifikat"
        ;;

    *) echo "Abbruch."
       exit 1
       ;;
esac
}


create_cert()
{
### Erzeuge CSR+KEY
openssl req -nodes -new -newkey rsa:4096 -sha256 -keyout $_ssldir/$_san1/$_shortname.key -out $_ssldir/$_san1/$_shortname.csr -config $_ssldir/$_fqdn/$_shortname.cfg
}

#### Programm Start

# hole FQDN und shortname
show_usertext1 && read _userinput && _fqdn=$_userinput && _shortname=$(get_shortname)
# hole zusätzliche SAN einträge
get_additional_san
# rename VAR to sanX
_san1=$_fqdn
_san2=$_shortname
create_ssldir
create_cfg
show_usertext2 && pauseme
create_cert && clear
printf "\n --> Informationen <--\n"
cat $_ssldir/$_san1/$_shortname.cfg | grep DNS | awk '{print $1 "   ""-->""   " $3}'
printf "\nSoll es ein Externes Zertifikat werden dann befolge diese Anleitung:  wiki.haevg-rz.ag/display/technik/externes_zertifikat \n"
printf "Soll es ein Internes Zertifikat werden dann befolge diese Anleitung:  wiki.haevg-rz.ag/display/technik/internes_zertifikat \n" 