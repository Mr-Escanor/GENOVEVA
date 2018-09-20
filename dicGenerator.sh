#!/bin/bash

#set -x

#Colores
NOCOL='\e[0m' # No Color
GREEN='\e[1;32m'
RED='\e[1;31m'
OK="[${GREEN}✓${NOCOL}]"
KO="[${RED}✗${NOCOL}]"

CONTADOR=1
VERBOSE=0
SIMBOLOS=",.-_!%*+\$"

printHelp() {
    echo
    echo "Uso:"
    echo "$0 -i inputFile -o outputFile [-v]"
    echo "-i: archivo de entrada que contienen las palabras base"
    echo "-o: archivo de salida"
    echo "-v: modo verbose (muestra cada entrada por pantalla)"
}

printInfo() {
    echo
    echo "Genera desde una lista de nombres un diccionario para ataques de fuerza bruta."
    echo "Incluye el nombre con fechas, números, sustitución de vocales por números..."
    echo ""
   }


#Lanzamos la ayuda si falta algo
    if [ $# -eq 0 ]; then
        printInfo
        printHelp
        exit 2
    fi
	

#Pasamos como parámetros las opciones
    while getopts i:o:v OPT $@; do
            case $OPT in
                i) # archivo de entrada
                   ENTRADA="$OPTARG"
                   ;;
				o) # archivo de salida
                   SALIDA="$OPTARG"
                   ;;
                v) VERBOSE=1
            esac
    done
	

#Función de progreso
prog() {
    local w=80 p=$1;  shift
    printf -v dots "%*s" "$(( $p*$w/${LINEAS} ))" ""; dots=${dots// /.};
    printf "\r\e[K|%-*s| %3d %% %s" "$w" "$dots" "$p" "$*"; 
}

#Comprobamos si el archivo de entrada existe
if [ ! -f $ENTRADA ]; then

	echo -e "$KO ${RED}ERROR:${NOCOL} El archivo de entrada $ENTRADA no existe"
    exit 1

fi


#Comprobamos si el archivo de salida ya existe
if [ -f $SALIDA ]; then

    echo -e "$KO ${RED}ERROR:${NOCOL} El archivo de salida $SALIDA ya existe"
    exit 1

fi


#Comprobamos permiso de escritura en el directorio de salida
RUTA=$(dirname $(readlink -f $SALIDA))
if [ ! -w $RUTA ]; then
    
    echo -e "$KO ${RED}ERROR:${NOCOL} No se puede escribir en la ruta $RUTA"
    exit 1

fi
    
#Sacamos el número de líneas para el progreso
LINEAS=$(cat $ENTRADA | tr -d " "  | tr "\t" "\n" | tr [:upper:] [:lower:] | grep . | sort | uniq | wc -l)

echo -e "$OK ${GREEN}[OK!]${NOCOL} Comenzamos a generar el diccionario"

#Limpiamos la entrada de tildes, espacios, líneas vacias, pasamos a minúsculas...
cat $ENTRADA | tr -d " "  | tr "\t" "\n" | tr [:upper:] [:lower:] | grep . | sort | uniq | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/' | while read NOMBRE
    
    do
       
        echo -e "$OK Generando combinaciones para $NOMBRE" 
        #prog "$CONTADOR" Generando $NOMBRE
        CONTADOR=$((CONTADOR+1))
 
        #Nombre normal, capitalizado, mayúsculas:
        echo $NOMBRE >> $SALIDA                                                             #Nombre
        echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' >> $SALIDA                         #Nombre Capitalizado
        echo ${NOMBRE} | tr [:lower:] [:upper:] >> $SALIDA                                  #Nombre Mayúsculas

        #l33t completo de vocales:
        echo ${NOMBRE} | sed 'y/aeioAeio/43104310/' >> $SALIDA                                        #Nombre L33t Solo Vocales
        echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aeioAEIO/43104310/' >> $SALIDA       #Nombe capitalizado L33t Solo vocales
        echo ${NOMBRE} | tr [:lower:] [:upper:] | sed 'y/aeioAEIO/43104310/' >> $SALIDA
       
        #l33t completo de vocales y 's' si lleva "S" el nombre:
        if [[ $NOMBRE == *[Ss]* ]]; then

            echo ${NOMBRE} | sed 'y/sSaeioAeio/$$43104310/' >> $SALIDA
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/sSaeioAEIO/$$43104310/' >> $SALIDA
            echo ${NOMBRE} | tr [:lower:] [:upper:] | sed 'y/sSaeioAEIO/$$43104310/' >> $SALIDA
        
        fi
        

        #l33t solo de una letra cada vez:
        if [[ $NOMBRE == *[aA]* ]]; then
            echo ${NOMBRE} | sed 'y/aA/44/' >> $SALIDA
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aA/44/' >> $SALIDA
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/aA/44/' >> $SALIDA
        fi
        if [[ $NOMBRE == *[eE]* ]]; then
            echo ${NOMBRE} | sed 'y/eE/33/' >> $SALIDA
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/eE/33/' >> $SALIDA
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/eE/33/' >> $SALIDA
        fi
        if [[ $NOMBRE == *[iI]* ]]; then
            echo ${NOMBRE} | sed 'y/iI/11/' >> $SALIDA
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/iI/11/' >> $SALIDA
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/iI/11/' >> $SALIDA
        fi
        if [[ $NOMBRE == *[oO]* ]]; then
            echo ${NOMBRE} | sed 'y/oO/00/' >> $SALIDA
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/oO/00/' >> $SALIDA
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/oO/00/' >> $SALIDA
        fi
        

        



        #Añadimos un símbolo detrás
        for (( i=0; i<${#SIMBOLOS}; i++ ))
        do
            echo "${NOMBRE}${SIMBOLOS:$1:1}" >> $SALIDA
            echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g')${SIMBOLOS:$1:1}" >> $SALIDA
            echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:])${SIMBOLOS:$1:1}" >> $SALIDA
            echo "$(echo ${NOMBRE} | sed 'y/sSaeioAeio/$$43104310/')${SIMBOLOS:$1:1}" >> $SALIDA
            echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aeioAEIO/43104310/')${SIMBOLOS:$1:1}" >> $SALIDA
            echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:] | sed 'y/aeioAEIO/43104310/')${SIMBOLOS:$1:1}" >> $SALIDA


            
            if [[ $NOMBRE == *[Ss]* ]]; then

                echo "$(echo ${NOMBRE} | sed 'y/sS/$$/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/sS/$$/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/sS/$$/')${SIMBOLOS:$1:1}" >> $SALIDA

            fi

            if [[ $NOMBRE == *[aA]* ]]; then
                echo "$(echo ${NOMBRE} | sed 'y/aA/44/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aA/44/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/aA/44/')${SIMBOLOS:$1:1}" >> $SALIDA
            fi
            if [[ $NOMBRE == *[eE]* ]]; then
                echo "$(echo ${NOMBRE} | sed 'y/eE/33/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/eE/33/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/eE/33/')${SIMBOLOS:$1:1}" >> $SALIDA
            fi
            if [[ $NOMBRE == *[iI]* ]]; then
                echo "$(echo ${NOMBRE} | sed 'y/iI/11/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/iI/11/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/iI/11/')${SIMBOLOS:$1:1}" >> $SALIDA
            fi
            if [[ $NOMBRE == *[oO]* ]]; then
                echo "$(echo ${NOMBRE} | sed 'y/oO/00/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/oO/00/')${SIMBOLOS:$1:1}" >> $SALIDA
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/oO/00/')${SIMBOLOS:$1:1}" >> $SALIDA
            fi

        done        


        #Secuencia de números
        echo -e ${NOMBRE}{1..9} | tr [:space:] \\n >> $SALIDA 
        echo -e ${NOMBRE}{00..99} | tr [:space:] \\n >> $SALIDA
        echo -e ${NOMBRE}{000..999} | tr [:space:] \\n >> $SALIDA
        echo -e ${NOMBRE}{0000..9999} | tr [:space:] \\n >> $SALIDA

        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){1..9} | tr [:space:] \\n >> $SALIDA 
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){00..99} | tr [:space:] \\n >> $SALIDA
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){000..999} | tr [:space:] \\n >> $SALIDA
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){0000..9999} | tr [:space:] \\n >> $SALIDA

        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){1..9} | tr [:space:] \\n >> $SALIDA 
        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){00..99} | tr [:space:] \\n >> $SALIDA
        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){000..999} | tr [:space:] \\n >> $SALIDA
        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){0000..9999} | tr [:space:] \\n >> $SALIDA
    

    done 
