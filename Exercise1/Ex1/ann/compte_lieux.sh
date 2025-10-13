mot=$1
annee=$2

echo "Nombre de $mot en $annee:"
cat $annee/* | grep $mot | wc -l