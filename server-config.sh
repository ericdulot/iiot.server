#!/bin/sh
echo
echo "Paramétrage et installation des services du serveur Internet des objets connectés industriel"
echo "Eric Daudrix - Lycée Monnerville - Cahors - CMQE de l'industrie du futur - Decazeville"
echo

#installation de docker engine
if [ ! -f "flag.docker" ]
then
echo "installation de docker engine"
echo
curl -fsSL https://get.docker.com -o get-docker.sh
echo "telechargement de get-docker.sh"
while  [ ! -f "get-docker.sh" ]
do
echo
echo "téléchargement..."
done
echo
echo "fin du téléchargement"
echo
echo "execution du script d'installation de docker engine, patience..."
echo
sudo sh get-docker.sh
touch flag.docker
fi

#paramétrage proxy docker
if [ -f "/home/pi/http-proxy.conf" -a ! -f "flag.proxy" ]
then
echo
echo "parametrage du proxy pour docker"
sudo mkdir /etc/systemd/system/docker.service.d
sudo cp /home/pi/http-proxy.conf /etc/systemd/system/docker.service.d/http-proxy.conf
echo 
echo "patientez pendant le redemarrage du service docker"
sudo systemctl daemon-reload
sudo systemctl restart docker
sleep 5
echo
echo "service docker redemarré"

fi

#installation de portainer
if [ ! -f "flag.portainer" ]
then
echo "portainer install"
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest --admin-password '$2y$05$0ZGan1TVB8PPNg8kXFeA7ugbo.XCUFImtJQd8wW7FN940YKVkWmvO'
touch flag.portainer
fi

#installation de nodered
if [ ! -f "flag.nodered" ]
then
echo "nodered install"
sudo docker volume create nodered_data
sudo docker run -d -p 1880:1880 --name nodered --restart=always -v nodered_data:/data  nodered/node-red:3.1

#set registry proxy
if [ -f "/home/pi/http-proxy.conf" -a ! -f "flag.proxy" ]
then
read line < /home/pi/npm-proxy.conf
sudo docker exec nodered /bin/sh -c "npm config set proxy $line"
sudo docker exec nodered /bin/sh -c "npm config set https-proxy $line"
touch flag.proxy
fi
sudo docker restart nodered

#install palettes
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-rpi-shutdown"
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-array-splitter"
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-ifm-al13xx"
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-influxdb"
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-modbus"
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-ui-led"
sudo docker exec nodered /bin/sh -c "npm install node-red-dashboard"
sudo docker exec nodered /bin/sh -c "npm install node-red-contrib-opcua"
sudo docker exec nodered /bin/sh -c "npm install @senx/node-red-contrib-warpscript"

sudo docker restart nodered


touch flag.nodered
fi

#installation de grafana
if [ ! -f "flag.grafana" ]
then
sudo docker volume create grafana_data
sudo docker run -d -p 3000:3000 --name grafana --restart=always -v grafana_data:/var/lib/grafana  grafana/grafana:10.0.10
touch flag.grafana
fi


#installation d'influxdb
if [ ! -f "flag.influxdb" ]
then
sudo docker volume create influxdb_data
sudo docker run -d -p 8086:8086 --name influxdb --restart=always -v influxdb_data:/var/lib/influxdb  influxdb:1.8
#creation base demo
sudo docker exec influxdb influx -execute 'create database demo;'
sudo docker exec influxdb influx -execute 'CREATE RETENTION POLICY "retention_1d" ON "demo" DURATION 1d REPLICATION 1 default;'
touch flag.influxdb
fi


#installation broker
if [ ! -f "flag.broker" ]
then
sudo docker run -d -p 1883:1883 --name brokerMqtt --restart=always  eclipse-mosquitto:1.6.14
touch flag.broker
fi
