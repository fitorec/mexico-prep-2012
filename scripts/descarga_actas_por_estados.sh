#!/bin/bash
# Descarga de forma integra las consultas del prep, de algún estado determinado.
# Las consultas quedaran ubicadas en:
#    <REPOSITORIO>/etc/respaldos_consultas/<nombre_estado>/seccion_<num_seccion>.html
#

# Colores solo para que se distinga un poco mejor(creo yo) los procesos que
# realiza el script.
cyan='\e[0;36m'
light='\e[1;36m'
red="\e[0;31m"
yellow="\e[0;33m"
white="\e[0;37m"
end='\e[0m'

#Variables a utilizar
URL="http://www.difusorprep-elecciones2012.unam.mx/prep/DetalleCasillas?"
REPO_PATH=$(readlink -f "$0" | xargs dirname | xargs dirname )
AGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FREE; .NET CLR 1.1.4322)"
ESTADOS=(null 'AGUASCALIENTES' 'BAJA CALIFORNIA' 'B. CALIFORNIA SUR' 'CAMPECHE'
					"COAHUILA\t" 'COLIMA' "CHIAPAS\t" 'CHIHUAHUA' 'DISTRITO FEDERAL' "DURANGO\t"
					'GUANAJUATO' 'GUERRERO' "HIDALGO\t" 'JALISCO' "MÉXICO\t" 'MICHOACÁN' "MORELOS\t"
					'NAYARIT' 'NUEVO LEÓN' 'OAXACA' "PUEBLA\t" 'QUERÉTARO' 'QUINTANA ROO'
					'SAN LUIS POTOSÍ' "SINALOA\t" 'SONORA' "TABASCO\t" 'TAMAULIPAS' "TLAXCALA\t"
					'VERACRUZ' "YUCATÁN\t" 'ZACATECAS')
SLUG_EDO=(null 	'aguascalientes' 'baja_california' 'baja_california_sur' 'campeche'
					"coahuila" 'colima' "chiapas" 'chihuahua' 'distrito_federal' "durango"
					'guanajuato' 'guerrero' "hidalgo" 'jalisco' "mexico" 'michoacan' "morelos"
					'nayarit' 'nuevo_leon' 'oaxaca' "puebla" 'queretaro' 'quintana_roo'
					'san_luis_potosi' "sinaloa" 'sonora' "tabasco" 'tamaulipas' "tlaxcala"
					'veracruz' "yucatan" 'zacatecas')
DEST_PATH=`echo ${REPO_PATH}/etc/respaldos_consultas`
###########################################################################
# Revisa si la variable EDO pertenece a un estado valido, esto lo hace re-
# visando si pertenece al intervalo [1-32]. Devuelve true si es así y
# false en caso contrario.
###########################################################################
function es_edo_vadido() {
	if [ "${EDO}" -gt 0 ] && [ "${EDO}" -lt 33 ]
	then
		echo "true"
	else
		echo 'false'
	fi
}

###########################################################################
# Revisa si el estado es valido, de no serlo muestra un menú,esto lo repite
# asta que el usuario seleccione un estado valido.
###########################################################################
function menu() {
	while [ `es_edo_vadido` == false ]
	do
		echo -e "${light}Inserte un número que seleccione algún estado${end}"
		band=0
		for index in {1..32}
		do
			if [ ${band} -eq 0 ]
			then
				echo -ne " ${yellow}${index}${end} ${cyan}=>${end} ${ESTADOS[index]}\t\t"
				band=1
			else
				echo -e " ${yellow}${index}${end} ${cyan}=>${end} ${ESTADOS[index]}"
				band=0
			fi
		done #fin ciclo for
		read EDO
	done #fin del while
	echo -e "${light}Estado seleccionado:${end} ${yellow}${ESTADOS[EDO]}${end}"
}

###########################################################################
# Revisa si el estado es valido, de no serlo muestra un menú,esto lo repite
# asta que el usuario seleccione un estado valido.
###########################################################################
function descargar_actas() {
	DEST_PATH=$(echo ${DEST_PATH}/${SLUG_EDO[EDO]})
	echo -e "${light}Destino:${end} ${yellow}${DEST_PATH}${end}"
	#si la carpeta destino no existe la creamos.
	if [ ! -e "${DEST_PATH}" ]
	then
		echo -e "${light}Destino inexistente, creando el destino${end}"
		mkdir -p "${DEST_PATH}"
	fi
	echo -ne "${cyan}obteniendo secciones...${end}\r";
	for line in $(cat ${REPO_PATH}/secciones.txt  | grep -E "^${EDO}\s" | sed 's/ /_/' )
	do
		ESTADO=$(echo ${line} | cut -d_ -f1)
		SECCION=$(echo ${line} | cut -d_ -f2)
		FILE_DST=$(echo seccion_${SECCION}.html)
		#Solo debe descargar el archivo si este no existe.
		if [ ! -f "${FILE_DST}" ]
		then
			echo -ne "Descargando: ${yellow}${FILE_DST}${end}\r";
			wget -O "${DEST_PATH}/${FILE_DST}" --user-agent="${AGENT}" -q \
			"${URL}idEdo=${ESTADO}&seccion=${SECCION}&votoExt=1"
		fi
	done
	echo -ne "${cyan}obteniendo secciones...${end}\r";
}

#El estado es el argumento de entrada
EDO=0
if [ $# -gt 0 ]
then
	EDO=$1
	#Opción especial no seleccionable desde el menú.
	#Descarga en orden todos los estados.
	if [ ${EDO} == 'all' ]
	then
		echo -e "${light}Es usted un chingón pretende descargar todo ':¬P!${end}"
		echo "-----------------------------------------------------------------------"
		for edo_index in {1..32}
		do
			$0 $edo_index
		done;
		exit 0;
	fi
fi
#Mandamos a validar el estado a descargar si no se le pedimos al usuario
menu
#Finalmente descargamos el menu
descargar_actas
