#!/bin/sh
echo "Paramétrage et installation des services du serveur Internet des objets connectés industriel"
echo "Eric Daudrix - Lycée Monnerville - Cahors - CMQE de l'industrie du futur - Decazeville"
echo "configuration du proxy..."
read -p "adresse du proxy? (http://user:pass@xxx.xxx.xxx.xxx:port) "  request
echo "adresse saisie: "$request
read -p "confirmer votre saisie? (oui/non) " confirm
if [ $confirm = "non" ]
then
echo "aucun proxy configuré"
exit
fi
touch http-proxy.conf
echo "[Service]" >> http-proxy.conf
echo "Environment=\"HTTP_PROXY="$request"/\""  >> http-proxy.conf
echo "Environment=\"HTTPS_PROXY="$request"/\""  >> http-proxy.conf

echo "export http_proxy=\""$request"\"" >> /home/pi/.profile
echo "export https_proxy=\""$request"\"" >> /home/pi/.profile
echo "export no_proxy=\"localhost,127.0.0.1\"" >> /home/pi/.profile
. ~/.profile
echo "proxy configuré"
bash