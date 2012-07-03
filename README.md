## ELECCIONES MÉXICO 2012

Esta información es pública y ha sido puesta para análisis en el sitio del [PREP](http://prep2012.ife.org.mx/prep/NACIONAL/PresidenteNacionalVPC.html).

Este repositorio no tiene relación con el IFE, por lo tanto no es oficial y no debe asumirse como tal, únicamente sirve para facilitar la consulta de los datos por terceros.

### Relación de estados y secciones

La relación de estados y secciones está en el archivo secciones.txt, la primer columna es el estado y la segunda el número de sección.

### Para obtener una lista de actas

Las actas no están disponibles en un formato de acceso amistoso, sin embargo se puede generar una lista de actas mediante [Web Scrapping](http://en.wikipedia.org/wiki/Web_scraping) en el sitio del PREP:

    $ cd scripts
    $ chmod +x actas.sh
    $ ./actas.sh

Las actas se guardarán en etc/actas.txt

Se recomienda no realizar scraping el sitio del PREP de forma agresiva, una vez se complete una relación de estados y secciones con actas se publicará en etc/actas.txt
