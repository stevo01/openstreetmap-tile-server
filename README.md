# overview

the tileserver is based on docker container created by Alexander Overvoorde
see https://github.com/Overv/openstreetmap-tile-server for details.


## notes

### test connection to database
apt update
apt install iputils-ping
ping osmpsql

### get real ip in access logs
real_ip_header X-Forwarded-For;
set_real_ip_from traefik;


## force tirex to pre render zoomlevel 0-13 with lowest prio
tirex-batch map=ajt lon=-180,180 lat=-90,90 z=0-3 --prio=20




## check mapnik
nik4 -b 13.3 52.4 13.6 52.6 --size 800 600      /home/renderer/src/openstreetmap-carto/mapnik.xml      output.png