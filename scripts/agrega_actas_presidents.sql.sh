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
FILE_SQL_DST=$(echo ${REPO_PATH}/dumps/mysql/agrega_casillas_presidential.ql)

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
function configuracion() {
	echo `cat "${FILE_CONFIG}" | grep -Ev '^\s*#' | grep -E "\s*${1}=" | sed "s/${1}=//"`
}


MYSQL_USER=`configuracion MYSQL_USER`
MYSQL_PASSWORD=`configuracion MYSQL_PASSWORD`
MYSQL_BD=`configuracion MYSQL_BD`

function nombre_estado() {
echo -e $(mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ${MYSQL_BD} << EOFMYSQL
	SELECT nombre FROM estados WHERE ID=$1;
EOFMYSQL
)  | sed 's/nombre //'
}

###########################################################################
# Inicia el archivo a usar.
###########################################################################
function iniciaFileDst() {
	echo '-- Archivo autogenerado' > "${FILE_SQL_DST}";
	echo "-- Ultima actulizacion: `date`" >> "${FILE_SQL_DST}";

	echo '' >> "${FILE_SQL_DST}";
	echo '--' >> "${FILE_SQL_DST}";
	echo '-- Agregando el campo ACTAS a la tabla presidential' >> "${FILE_SQL_DST}";
	echo '--' >> "${FILE_SQL_DST}";
	echo 'ALTER TABLE presidential ADD ACTAS TEXT;' > ${FILE_SQL_DST};

	echo '' >> "${FILE_SQL_DST}";
	echo '--' >> "${FILE_SQL_DST}";
	echo '-- Comienzo del volcado de actas' >> "${FILE_SQL_DST}";
	echo '--' >> "${FILE_SQL_DST}";
}
iniciaFileDst

###########################################################################
# Carga las tablas de la BD
###########################################################################
function carga_nuevo_esquema() {
	echo -e "${cyan}Actualizando nuevo esquema de datos${end}"
	#Primero borramos todas las tablas existentes en la base de datos
	for t in `mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_BD}" -BNe "SHOW TABLES"`
	do
		echo -ne "${red}Borrando${end} -> ${MYSQL_BD}${yellow}.${end}${light}${t}${end}\r"
		mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_BD}" -e "drop table ${t}"
	done
	echo "--------------------------------------------------------------------"

	#Cargamos la base de datos para presidentes.
	echo -e "Cargando tabla prep presidenciales: ${yellow}/dumps/mysql/presidential.sql${end}";
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_BD}" < \
	"${REPO_PATH}/dumps/mysql/presidential.sql"

	#cargamos la tabla donde vienen los nombres de estados.
	echo -e "Cargando relación de estados: ${yellow}/dumps/mysql/estados.sql${end}";
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_BD}" < \
	"${REPO_PATH}/dumps/mysql/estados.sql"

	echo -e "Actualizando tabla prep presidenciales: ${yellow}/dumps/mysql/agrega_casillas_presidential.ql${end}";
	#Cargamos el archivo que modifica la tabla presidentials
	mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_BD}" < \
	"${FILE_SQL_DST}"
}

###########################################################################
# Cargamos las actas
###########################################################################
function relacion_actas_presidentials() {
	ESTADO_ANTERIOR='0'
	ESTADO_NOMBRE=''
	SECCION_ANTERIOR='0'
	echo -e "${cyan}Insertando las actas, este proceso puede tardar mucho, por favor sea paciente${end}"
	for LINEA in $(cat ${REPO_PATH}/etc/actas.txt | sort -n | sed 's/ /=/g')
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
	echo "UPDATE presidential SET ACTAS=CONCAT(ACTAS,'$HASH','\n') WHERE ESTADO=$ESTADO AND SECCION=$SECCION;" >> \
"${FILE_SQL_DST}";
	done;
	echo -e "${yellow}El script ha finalizado!${end}"
}

#Generamos la relación entre presidentials y actas.
relacion_actas_presidentials

#Actualiza el esquema de la base de datos
#carga_nuevo_esquema
