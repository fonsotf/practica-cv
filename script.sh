#!/bin/bash
#Alfonso Ruigomez

Ppath=$PWD
cd $Ppath;
lista_provincias=$(cat provincias.csv)
#lista_comunidades=`cat "$lista_provincias" | cut -d ',' -f2 | sort | uniq`
tipo_energias=("Nuclear" "Carbon" "Lignitos" "Fuel" "Gas_natural" "Otros")
IFS=$'\n'
for line in $(cat provincias.csv)
do
	provincia=`echo $line | cut -d ',' -f1`
	comunidad=`echo $line | cut -d ',' -f2`
	mkdir -p $comunidad/$provincia
	for energia in "${tipo_energias[@]}"
		do 
		touch $comunidad/$provincia/$energia.txt; 
	done 
done
#IFS=""
mes=("Enero" "Febrero" "Marzo" "Abril" "Mayo" "Junio" "Julio" "Agosto" "Septiembre" "Octubre" "Noviembre" "Diciembre")
DESCARGAR=0
if (($DESCARGAR == 0)); then
	mkdir data
	for y in '2006' '2007' '2008' '2009' '2010' '2011' '2012' '2013' '2014'
	do
		for m in 'Enero' 'Febrero' 'Marzo' 'Abril' 'Mayo' 'Junio' 'Julio' 'Agosto' 'Septiembre' 'Octubre' 'Noviembre' 'Diciembre' #
			do 
			curl http://www.minetur.gob.es/energia/balances/Publicaciones/ElectricasMensuales/$y/$m\_$y.zip -o data/$m-$y.zip
			unzip data/$m-$y.zip -d data/
			rm data/$m-$y.zip
			mv data/$m data/$m-$y 
			mv data/$m\_$y data/$m-$y #Meses que vien con _
			read mm <<< $(tr '[:upper:]' '[:lower:]' <<< $m) #Meses que vienen en minuscula
			mv data/$mm\ $y data/$m-$y #Meses separados con espacio
			
		done 
	done
	curl http://www.minetur.gob.es/energia/balances/Publicaciones/ElectricasMensuales/2015/Enero_2015.zip -o data/Enero-2015.zip
	unzip data/Enero-2015.zip -d data/
	rm data/Enero-2015.zip
	mv data/Enero\_2015 data/Enero-2015
fi
#IFS=$'\n'
provincias=( $(cut -d ',' -f1 provincias.csv ) )
comunidades=( $(cat provincias.csv | cut -d ',' -f2 | sort | uniq) )
for yy in '2006' '2007' '2008' '2009' '2010' '2011' '2012' '2013' '2014'
do
	for mm in 'Enero' 'Febrero' 'Marzo' 'Abril' 'Mayo' 'Junio' 'Julio' 'Agosto' 'Septiembre' 'Octubre' 'Noviembre' 'Diciembre'
	do #Para recoger los datos, vamos a eleminar la cabecera y los espacios sustituirlos por | para extraerlos mejor. Teniendo cuidado con los espacios entre los nombres de las provincias
		tail -n +10 data/$mm-$yy/T_127P_*.txt > data/$mm-$yy/file.stdout #eliminamos la cabecera
		tr -s " " < data/$mm-$yy/file.stdout > data/$mm-$yy/fichero.dat #eliminamos los espacios dejando solo uno entre cada dato
		sed -i 's/\([[:digit:]]\)\ \([[:digit:]]\)/\1|\2/g' data/$mm-$yy/fichero.dat #cambiamos los espacios entre los números por |
		sed -i 's/\([[:digit:]]\)\ \([[:digit:]]\)/\1|\2/g' data/$mm-$yy/fichero.dat #A la primera no completa todos los campos, repetimos
		sed -i 's/\([[:digit:]]\)\ \([[:upper:]]\)/\1|\2/g' data/$mm-$yy/fichero.dat #cambiamos los espacios entre el último número y la provincia los números por |
		sed -i 's/\([[:upper:]]\)\ \([[:digit:]]\)/\1|\2/g' data/$mm-$yy/fichero.dat #cambiamos los espacios la provincia y el primer numero por |
		fecha=$mm$yy
		for line in $(cat provincias.csv)
		do
			prov=`echo $line | cut -d ',' -f1`
			com=`echo $line | cut -d ',' -f2`
			awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$2} ' data/$mm-$yy/fichero.dat >> $com/$prov/Nuclear.txt
			awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$3} ' data/$mm-$yy/fichero.dat >> $com/$prov/Carbon.txt
			awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$4} ' data/$mm-$yy/fichero.dat >> $com/$prov/Lignitos.txt
			awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$5} ' data/$mm-$yy/fichero.dat >> $com/$prov/Fuel.txt
			awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$6} ' data/$mm-$yy/fichero.dat >> $com/$prov/Gas_natural.txt
			awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$7} ' data/$mm-$yy/fichero.dat >> $com/$prov/Otros.txt
		done
	done
done
#awk -F\| -v var="$fecha" -v var2="$prov" '$1==var2 {print var,$2}' data/Abril-2006/fichero.dat >> CANTABRIA/CANTABRIA/Nuclear.txt