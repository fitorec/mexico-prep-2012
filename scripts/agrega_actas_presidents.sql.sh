#!/bin/bash
# Carga las tablas en la Base de datos configurada en scripts/mi_configuracion.conf
# a la tabla `presidents` le agrega un campo de texto con el nombre `actas`. A partir
# del archivo /etc/actas.txt obtenemos los datos para insertar el hash de las actas
# en `presidents`.`actas`

cyan='\e[0;36m'
light='\e[1;36m'
red="\e[0;31m"
yellow="\e[0;33m"
white="\e[0;37m"
end='\e[0m'

REPO_PATH=$(readlink -f "$0" | xargs dirname | xargs dirname )
FILE_CONFIG=$(echo ${REPO_PATH}/scripts/mi_configuracion.conf)

#Revisando que exista el archivo de configuracion.
if [ ! -f "${FILE_CONFIG}" ]
then
	echo -e "${red}Error:${end} Archivo de configuracion inexistente:"
	echo "${FILE_CONFIG}"
	echo "Copiando archivo muestra:"
	echo "${FILE_CONFIG}.ejemplo ${FILE_CONFIG}"
	cp ${FILE_CONFIG}.ejemplo ${FILE_CONFIG}
	echo "Edite el archivo ${FILE_CONFIG} con sus datos"
	exit 1;
fi

#Revisando que exista el archivo de actas.
if [ ! -f "${REPO_PATH}/etc/actas.txt" ]
then
	echo -e "${red}Error:${end} no existe el archivo de actas:"
	echo "${REPO_PATH}/etc/actas.txt"
	echo "ejecute el script scripts/actas.sh"
	exit 1;
fi

#########################################################################
# Carga un valor del archivo de configuración
#########################################################################
function configuracion()
{
	echo `cat "${FILE_CONFIG}" | grep -Ev '^\s*#' | grep -E "\s*${1}=" | sed "s/${1}=//"`
}


MYSQL_USER=`configuracion MYSQL_USER`
MYSQL_PASSWORD=`configuracion MYSQL_PASSWORD`
MYSQL_BD=`configuracion MYSQL_BD`

function nombre_estado()
{
echo -e $(mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ${MYSQL_BD} << EOFMYSQL
	SELECT nombre FROM estados WHERE ID=$1;
EOFMYSQL
)  | sed 's/nombre //'
}

###########################################################################
# Carga las tablas de la BD
###########################################################################
function loadSQL(){
	#Cargamos la base de datos para presidentes.
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ${MYSQL_BD} < \
	"${REPO_PATH}/dumps/mysql/presidential.sql"
	#cargamos la tabla donde vienen los nombres de estados.
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ${MYSQL_BD} < \
	"${REPO_PATH}/dumps/mysql/estados.sql"
	#A presidential le agregamos el campo ACTAS donde posteriormente trabajaremos.
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ${MYSQL_BD} << EOFMYSQL
	ALTER TABLE presidential ADD ACTAS TEXT;
EOFMYSQL
}
loadSQL

###########################################################################
# Cargamos las actas
###########################################################################
function cargar_actas() {
	ESTADO_ANTERIOR='0'
	ESTADO_NOMBRE=''
	SECCION_ANTERIOR='0'
	echo -e "${cyan}Insertando las actas, este proceso puede tardar mucho, por favor sea paciente${end}"
	for LINEA in $(cat ${REPO_PATH}/etc/actas.txt | sed 's/ /=/g')
	do
		ESTADO=$(echo $LINEA | cut -d= -f1)
		SECCION=$(echo $LINEA | cut -d= -f2)
		HASH=$(echo $LINEA | cut -d= -f3 | grep -Eio '[0-9a-f]+\.jpg$' | sed 's/.jpg//')
		if [ "${SECCION}" -ne "${SECCION_ANTERIOR}" ]
		then
			SECCION_ANTERIOR=$(echo $SECCION);
			if [ "${ESTADO_ANTERIOR}" -ne "${ESTADO}" ]
			then 
				ESTADO_NOMBRE=`nombre_estado ${ESTADO}`
				ESTADO_ANTERIOR=$(echo $ESTADO);
				echo -e "ESTADO: ${light}${ESTADO_NOMBRE}${end}\t\t";
			fi
			echo -ne "SECCIÓN: ${yellow}$SECCION${end}\r";
		fi;
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ${MYSQL_BD} << EOFMYSQL
		UPDATE presidential SET ACTAS = CONCAT(ACTAS,"$HASH",'\n') WHERE ESTADO=$ESTADO AND SECCION=$SECCION;
EOFMYSQL
	done;
	echo -e "${yellow}El script ha finalizado!${end}"
}

cargar_actas
