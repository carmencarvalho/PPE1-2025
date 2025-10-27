#!/bin/bash

if [ $# -ne 1 ]; then
    echo "en attente d'un argument : fichier d'urls"
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
  echo "erreur : renseignez un fichier valide"
  exit 1
fi

# En-tête du tableau TSV
echo -e "NUMERO\tURL\tCODE_HTTP\tENCODAGE\tNB_MOTS"

num_ligne=1

while read -r line; do
  if [[ $line =~ ^https?:// ]]; then
    # Récupérer le code HTTP
    # -I pour les en-têtes
    # -L pour suivre les redirections
    # -s mode silencieux 
    # -o /dev/null pour ne pas afficher le contenu
    # -w pour afficher uniquement le code de statut HTTP
    http_code=$(curl -I -L -s -o /dev/null -w "%{http_code}" "$line")

    # Récuperer l'encodage depuis les en-têtes HTTP
    encoding=$(curl -I -L -s "$line" | grep -i "content-type" | grep -o "charset=[^;]*" | cut -d= -f2 | tr -d '\r\n' | head -n 1)
    [ -z "$encoding" ] && encoding="N/A"

    # Télécharger la page et compter le nombre de mots avec lynx
    nb_mots=$(lynx -dump -nolist "$line" 2>/dev/null | wc -w)

    # Afficher le résultat en tableaux
    echo -e "${num_ligne}\t${line}\t${http_code}\t${encoding}\t${nb_mots}"
  else
    # Si la ligne n'est pas une URL valide
    echo -e "${num_ligne}\t${line}\tINVALIDE\t\t"
  fi
  num_ligne=$((num_ligne + 1))
done < "$file"

