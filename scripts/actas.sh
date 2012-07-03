#!/bin/bash
IFS='
'

AGENT="MSIE 6.0"

rm -f ../etc/actas.txt

touch ../etc/actas.txt

for line in $(cat ../secciones.txt); do

  IFS=' '

  set -- $(echo $line | awk '{ print $1, $2 }')

  ESTADO=$1
  SECCION=$2

  IFS='
'

  for url in $(curl "http://www.difusorprep-elecciones2012.unam.mx/prep/DetalleCasillas?" --user-agent "$AGENT" -d "idEdo=$ESTADO&seccion=$SECCION&votoExt=true" | sed s/">"/">\n"/g | grep "prep2012.ife.org.mx/actas" | sed s/.*window.open\(\'//g | sed s/\'.*//g); do
    echo "$ESTADO $SECCION $url" >> ../etc/actas.txt;
  done

done

