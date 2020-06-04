#!/bin/bash
# https://www.softcatala.org/recursos/ es desvia al port 8080 de la màquina virtual interna recursos on hi ha un nginx contestant el port i el #gunicorn contestant al port 8000
#http://172.17.0.2:8080/
/etc/init.d/nginx start
cd /srv/web
bash
#gunicorn web_search:app -b 0.0.0.0:8000

