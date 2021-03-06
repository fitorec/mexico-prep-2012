## BASE DE DATOS ELECCIONES MÉXICO 2012

Esta información es pública y ha sido puesta para análisis en el sitio del [PREP](http://prep2012.ife.org.mx/prep/NACIONAL/PresidenteNacionalVPC.html).

Este repositorio no tiene relación con el IFE, por lo tanto no es oficial y no debe asumirse como tal, únicamente sirve para facilitar la consulta de los datos por terceros.

### ¿Cómo puedo obtener una copia?

Los datos pueden ser copiados libremente mediante [git](http://git-scm.com), pero también están disponibles en formato [zip](https://github.com/xiam/mexico-prep-2012/zipball/master).

Existen varios formatos para la lectura, desde CSV, SQL hasta OpenOffice y Excel. Estos archivos están en el directorio ``dumps``.

Si tienes dudas o dificultades para analizar bases de datos, recomendamos consultar la [versión navegable](http://log.hckr.org/elecciones/prep/2012).

### Mensaje "Error: blob is too big"

En este caso sólo baja el paquete [zip](https://github.com/xiam/mexico-prep-2012/zipball/master) y busca ahí lo que deseas obtener.

### Relación de estados y secciones

La relación de estados y secciones está en el archivo ``secciones.txt``, la primer columna es el estado y la segunda el número de sección.

### Para obtener una lista de actas

Las actas no están disponibles en un formato de acceso amistoso, sin embargo se puede generar una lista de actas mediante [Web Scrapping](http://en.wikipedia.org/wiki/Web_scraping) en el sitio del PREP:

    $ cd scripts
    $ chmod +x actas.sh
    $ ./actas.sh

El último resultado de este script quedó copiado en ``etc/actas.txt`` y se prefiere utilizar éste listado en vez del scraping agresivo.

