#!/bin/bash
# Script per creare il file Json della WSTG

function join { local IFS="$1"; shift; echo "$*"; }

cd document/4-Web_Application_Security_Testing

# Inizializza la stringa json
echo "{" > checklist.json
# Categorie aperte
echo "    \"categories\": {"  >> checklist.json
# Itera tutte le cartelle di categoria per ottenere le categorie
for d in */ ; do
    # Divide il nome della cartella per ottenere la categoria e il numero di categoria
    # Selezionare le cartelle a partire dalla forma 01
    while IFS='-' read -ra FOLD; do
        if [ ${FOLD[0]} -gt 0 ]
        then
            # Nel caso di multeplici nel nome di categoria
            # Unire le sezioni diverse dalla prima
            if [ ${#FOLD[@]} -gt 2 ];then
                category=$(join - ${FOLD[@]:1})
            else
                category=${FOLD[1]}
            fi
            # Inizializza la sottosezione della categoria
            # Aggiunge la virgola dalla seconda voce dell'elenco
            if [ ${FOLD[0]} -gt 1 ];then
                echo "        ,\"${category%?}\": {" | tr '_' ' '  >> checklist.json
            else
                echo "        \"${category%?}\": {" | tr '_' ' '  >> checklist.json
            fi
            # Ottiene l'ID della categoria dal primo file
            cid=`cat $d/01-* | grep "|WSTG-.*" | cut -d "|" -f 2 | sed 's/-01//'`
            # Aggiunge l'ID della categoria e avvia i test
            echo "            \"id\":\"${cid}\","  >> checklist.json
            echo "            \"tests\":["  >> checklist.json
            count=0
            for file in $d*.md; do
                # Rimuove README
                if [[ $file != *"README.md" ]];then
                    # Ottiene l'ID del test
                    tid=`cat $file | grep "|WSTG-.*" | cut -d "|" -f 2`
                    # Se l'id del test esiste
                    if [ ! -z "$tid" ];then
                        # Aggiungere la virgola dalla seconda voce dell'elenco
                        if [ $count -gt 0 ];then
                            echo "                ,{"  >> checklist.json
                        else
                            echo "                {"  >> checklist.json
                        fi
                        # Ottiene l'obiettivo del test dal file
                        objectiveString=`awk "/## Test Objectives/{flag=1; next} /## /{flag=0} flag" $file |  awk 'NF'`
                        objcount=0
                        objectives=()
                        # Converte la stringa dell'obiettivo in un elenco di obiettivi
                        while read line;
                        do
                            objectives[$objcount]=`echo ${line//[$'\t\r\n']} |  cut -c 3-`
                            objcount=$((objcount+1))
                        done <<< "$objectiveString"

                        # Ottiene il nome del test e il link di riferimento dal file
                        read -r tname < $file
                        tname=${tname:2}
                        tref=`echo $file | sed 's/.md//'`
                        # Aggiunge l'ID del test, il nome del test e il link di riferimento dal file.
                        echo "                \"name\":\"${tname}\","  >> checklist.json
                        echo "                \"id\":\"${tid}\","  >> checklist.json
                        echo "                \"reference\":\"https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/$tref\","  >> checklist.json
                        echo "                \"objectives\":["  >> checklist.json
                        # Aggiunge l'array di obiettivi
                        objcount=0
                        for objective in "${objectives[@]}"
                        do
                            objcount=$((objcount+1))
                            # Controlla l'ultima voce dell'Obiettivo e rimuovere la virgola
                            if [ ${#objectives[@]} -eq $objcount ];then
                                echo "                    \"${objective}\""  >> checklist.json
                            else
                                echo "                    \"${objective}\","  >> checklist.json
                            fi
                        done
                        # Chiude l'elenco degli obiettivi
                        echo "                  ]"  >> checklist.json

                        echo "                }"  >> checklist.json
                        count=$((count+1))
                    fi
                fi
            done
            # Chiude l'elenco dei test
            echo "            ]"  >> checklist.json
            # Chiude la sottosezione della categoria
            echo "        }"  >> checklist.json
        fi
    done <<< "$d"
done
# Chiude le categorie
echo "    }"  >> checklist.json
# Conclude la stringa Json
echo "}"  >> checklist.json
cat checklist.json

# Sposta il file generato nella cartella delle liste di controllo
mv checklist.json ../../checklists/.
