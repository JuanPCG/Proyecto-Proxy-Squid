#!/bin/bash

Pruebas=(cosas/interfaces cosas/acl cosas/squid.conf cosas/sitio cosas/base_router.sql cosas/isc-default cosas/dhcp cosas/radius-eap cosas/radius-sitio-default cosas/sqlconfradius)
nb=(netboot.sh netboot/post.sh netboot/menu netboot/conf_tftp aux/gen_pre.sh iventoy.sh)
srv=(cambiar.php comun.php contra.php index.php reiniciar.php)

if [[ ! -z "$1" ]]
then

	if [[ $1 == "--silencio"  || $1 == "--rapido" ]]
	then
		esperar () {
			echo $@ >> log.install  # Tiene que tener algo
		}
	else
		echo "Uso $0 [--silencio]"
		exit
	fi
else
	esperar() { # En vez de dos lineas, 1, algo mas facil
		echo $@
		echo $@ >> log.install
		sleep 0.1
	}
fi

esperar
esperar "Se va a proceder a comprobar unos requisitos... Por favor, espera"
esperar
esperar "[+] Test Superusuario"



if [[ $UID != 0 ]]
then
	error="\nNo eres superusuario"
	esperar "[!] Superusuario: No"
else
	esperar "[+] Superusuario: Si"
fi

esperar # Los sleeps para que el usuario vea lo que va pasando

esperar "[+] Comprobando estructura de carpetas..."

if [[ ! $(basename $PWD) == "Proyecto-Proxy-Squid" ]]
then
	error="No estas en la carpeta base\n"
	esperar "[!] Ubicacion: Mal"
else
	esperar "[+] Pareces estar en la carpeta correcta"
fi

esperar

if [[ ! -f "extras/coco.jpeg" ]]
then
	esperar "[!] Coco: No"
	error="\n$error Falta archivo integral 'extras/coco.jpeg'"
else
	esperar "[+] coco.jpeg presente"
fi

esperar
esperar "[+] Comprobando archivos necesarios"
esperar
for i in "${Pruebas[@]}"
do
	if [[ -f "$i" ]]
	then
		esperar "[+] Existe: $i"
	else
		esperar "[!] No existe: $i"
		error="$error \nError en $i (No existe o no es ejecutable)"
	fi
esperar
done

esperar
esperar "[+] Comprobando archivos interfaz"
esperar

for i in "${srv[@]}"
do
	if [[ -f "srv/$i" ]]
	then
		esperar "[+] Existe: $i"
	else
		esperar "[!] No existe: $i"
		error="$error \nError en $i (No existe o no es ejecutable)"
	fi
esperar
done

esperar
esperar "[+] Comprobando archivos para netboot"
esperar


for i in "${nb[@]}"
do
	if [[ -f "$i" ]]
	then
		esperar "[+] Existe: $i"
	else
		esperar "[!] No existe: $i - Pero esto no es necesario"
	fi
	esperar
done





if [[ ! -z $error ]] # ¿Por que he usado ! si iba a poner un else de todas formas?
then # Esto se queda con 'echo' por que tiene que salir siempre
	echo
	echo "Se han encontrado errores:"
	echo -e $error
	echo
	exit
else
	if [[ ! $1 == "--silencio"  || ! $1 == "--rapido" ]]
	then # Asumimos, ¿Que podria salir mal?
		read -p "Todas las comprobaciones OK. Presiona enter. "
	fi
fi

esperar "[1] Instalacion"
esperar "Hackeandote el sistema... Espera unos minutos (Esto va a tardar un poco)"
esperar
echo "(Si esto tarda, usa el comando 'tail --follow $(dirname $0)/log')"
echo "Inicio del log---" > log
echo "# sshnuke 10.2.2.2 -rootpw=\"Z10NO101\"" >> log
echo "Connecting to 10.2.2.2:ssh ... successful." >> log
echo "Attempting to exploit SSHv1 CRC32 ... successful." >> log
echo "Reseting root password to \"Z10N0101\"." >> log
echo "# ssh 10.2.2.2 -l root" >> log
echo "root@10.2.2.2's password:" >> log
apt update >> log
DEBIAN_FRONTEND=noninteractive apt install -y -qq whois iptables squid-openssl iptables-persistent isc-dhcp-server nginx php-fpm openssh-server git freeradius freeradius-mysql mariadb-common mariadb-server php-mysql mysql-common mariadb-client mariadb-server sudo jq ed dnsmasq >> log
echo "Final del log, puedes volver al terminal anterior" >> log

esperar "[2] IPTABLES"

iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
esperar "[+] iptables - 1"

iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j REDIRECT --to-port 3128
esperar "[+] iptables - 2"

iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 443 -j REDIRECT --to-port 3129
esperar "[+] iptables - 3"

iptables -t nat -A PREROUTING -i enp0s9 -p tcp --dport 80 -j REDIRECT --to-port 3128
esperar "[+] iptables - 4"

iptables -t nat -A PREROUTING -i enp0s9 -p tcp --dport 443 -j REDIRECT --to-port 3129
esperar "[+] iptables - 5"

iptables -t nat -A PREROUTING -i enp0s10 -p tcp --dport 80 -j REDIRECT --to-port 3128
esperar "[+] iptables - 6"

iptables -t nat -A PREROUTING -i enp0s10 -p tcp --dport 443 -j REDIRECT --to-port 3129
esperar "[+] iptables - 7"

netfilter-persistent save
esperar "[+] iptables - Guardado"

esperar "[3] SSH - Root"
esperar "Permitiendo loguearse como Root con contraseña por SSH"
cat /usr/share/openssh/sshd_config | sed 's/\#PermitRootLogin prohibit-password/PermitRootLogin yes/g' > /etc/ssh/sshd_config
esperar "[+] SSH - Permitido"
esperar "Reiniciando SSH..."
systemctl restart sshd
esperar "[+] SSH - Reiniciado"


esperar "[4] Forwarding"
echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
esperar "[+] Forwarding - Hecho"
sysctl -p
esperar "[+] SYSCTL - Activado"

esperar "[5] Copiando archivos de /srv/"
cp -r srv / >&2
esperar "[+] Copia - srv"


esperar "Saltando [6]..."
esperar "[?] [6] - Saltado"

esperar "[7] Conf. Red"
cp cosas/interfaces /etc/network/interfaces
esperar "[+] Copia - interfaces"



esperar " - Reiniciando red"
systemctl restart networking
esperar "[+] Reinicio - networking"

esperar "[8] Copiando squid"
cp cosas/acl /etc/squid/acl.txt
esperar "[+] Copia - acl"

cp cosas/squid.conf /etc/squid/squid.conf
esperar "[+] Copia - squid.conf"

esperar "[9] Creando certificados"
mkdir -p /etc/squid/ssl_cert
esperar "[+] Carpeta ssl - creada"

chmod 700 /etc/squid/ssl_cert
esperar "[+] Carpeta SSL - permisos"

openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout /etc/squid/ssl_cert/squid_ca.key -out /etc/squid/ssl_cert/squid_ca.pem -sha256 -subj "/C=ES/ST=Andalucia/L=Andalucia/O=Instituto/OU=SquidInstituto/CN=SSL para proxy squid"
esperar "[+] SSL - Generado"

chown proxy:proxy /etc/squid/ssl_cert
esperar "[+] Carpeta SSL - permisos (2)"

mkdir -p /var/lib/squid/
esperar "[+] Carpeta var lib squid - creada"

/usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db -M 4MB
esperar "[+] Generando cache certificados"

chown -R proxy:proxy /var/lib/squid/ssl_db
esperar "[+] Cache certificados - permisos"

esperar " - Reiniciando squid (Esto va a tardar un poco...)"
systemctl restart squid
esperar "[+] Reinicio - squid"

esperar "[10] Conf. dhcp"
cp cosas/dhcp /etc/dhcp/dhcpd.conf
esperar "[+] Copia - dhcp (dhcpd.conf)"

cp cosas/isc-default /etc/default/isc-dhcp-server
esperar "[+] Copia - dhcp (isc-dhcp-server)"

systemctl restart isc-dhcp-server
esperar "[+] Reinicio - dhcp"

esperar "[11] Conf. Nginx"
rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
esperar "[+] NGINX - Borrando sitio por defecto"

cp cosas/sitio /etc/nginx/sites-enabled/default
esperar "[+] NGINX - Creando sitio por defecto"

cp cosas/sitio /etc/nginx/sites-available/default # Esto no hace falta
esperar "[+] NGINX - Creando sitio por defecto (2)"


php_dir=$(ls -d /etc/php/[0-9].* 2>/dev/null | tail -n 1)
esperar "[+] PHP: $php_dir"


versionphp=$(basename "$php_dir")
esperar "[+] PHP Recortado - $versionphp"


cp /etc/squid/ssl_cert/squid_ca.pem /srv/certi.pem
esperar "[+] NGINX - Copiado certificado para descarga"


mysql < cosas/base_router.sql
esperar "[+] SQL - Base router"



echo -n "Introduce la nueva contraseña. NO SALDRA EN EL TERMINAL > "
read -s ncont
conthash=$(php -r "echo password_hash('$ncont', PASSWORD_BCRYPT);")
mysql -D router -e "UPDATE datoslogin SET contrahash = \"$conthash\" WHERE usuario = \"admin\";"
esperar
esperar "[+]  SQL - Cambio contraseña"


echo "www-data ALL=(ALL) NOPASSWD: /sbin/reboot" >> /etc/sudoers
esperar "[+] NGINX - Reglas de sudo "


systemctl restart nginx php$versionphp-fpm
esperar "[+] Reiniciando - NGINX y PHP"



esperar "[12] Haciendo RADIUS"
cp -rvf cosas/radius-sitio-default /etc/freeradius/3.0/sites-enabled/default
esperar "[+] Copia - Radius (1/3)"


cp -rvf cosas/radius-eap /etc/freeradius/3.0/mods-enabled/eap
esperar "[+] Copia - Radius (2/3)"


cp -rvf cosas/sqlconfradius /etc/freeradius/3.0/mods-enabled/sql
esperar "[+] Copia - Radius (3/3)"


mysql -e "CREATE DATABASE baseradius;"
esperar "[+] SQL - baseradius"


mysql -e "CREATE USER 'Fran' IDENTIFIED BY 'FranPassword';"
esperar "[+] SQL - Crear usuario"


mysql -e "GRANT ALL ON baseradius.* TO 'Fran';"
esperar "[+] SQL - Permisos"


mysql -e "FLUSH PRIVILEGES;"
esperar "[+] SQL - Privilegios"


mysql -D baseradius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql
esperar "[+] SQL - Radius / Estructura"



for i in {1..5};
do
	PROF=prof$i
	CONT=$RANDOM$RANDOM$RANDOM
	CHASH=$(mkpasswd $CONT)
	esperar "[+] RADIUS - Agregando usuario $PROF con contraseña $CONT ($i/5)"
	mysql -u Fran -pFranPassword -D baseradius -e "INSERT INTO radcheck (username, attribute, op, value) VALUES ('$PROF', 'Crypt-Password', ':=', '$CHASH');"
done
i=0
for i in {1..50};
do
	ALM=alum$i
	CONT=$RANDOM$RANDOM$RANDOM
	CHASH=$(mkpasswd $CONT)
	esperar "[+] RADIUS - Agregando usuario $ALM con contraseña $CONT ($i/50)"
	mysql -u Fran -pFranPassword -D baseradius -e "INSERT INTO radcheck (username, attribute, op, value) VALUES ('$ALM', 'Crypt-Password', ':=', '$CHASH');"
done

cp -rvf cosas/dnsmasq.conf /etc/dnsmasq.conf
systemctl restart dnsmasq
esperar "[+] DNSmasq preparado"

esperar "Permitiendo copias de seguridad ahora..."
echo "[mysqld]" > /etc/mysql/mariadb.conf.d/99-permitir-copias.cnf
echo "bind-address            = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/99-permitir-copias.cnf
esperar "[+] SQL - Copias / Permitir IPs con contraseña"


systemctl restart freeradius mariadb
esperar "[+] Reiniciar / FreeRADIUS y MariaDB"


echo
echo "Asegurate de instalar tambien de ejecutar aux/backup.sh en al menos un cliente!"
echo
echo
echo "Los siguientes pasos (Opcionales):"
echo "	- Haz el netboot (netboot.sh / iventoy.sh)"
echo "	- Instala correo (JMAIL o Mail (Estandar)) (aux/mail.sh / aux/jmail.sh)"
