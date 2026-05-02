#!/bin/bash

# Este script deberia ejecutarse en el CLIENTE.

if ! command -v mysqldump &> /dev/null
then
    sudo apt update && sudo apt install mariadb-client -y
fi

if [[ ! -d $HOME/backups ]]
then
	mkdir $HOME/backups
fi

read -p 'IP del servidor > ' ip

if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] # Esto es regex, que lo copiado de internet, pero se lo que hace.
then
	read -p "Base de datos > " base
	read -p "Usuario de la base de datos > " usuario
	read -p "Contraseña > " contra

	COMANDO="mysqldump -h $ip -u $usuario -p$contra --skip-ssl $base > $HOME/backups/backup_\$(date).sql"
	(crontab -l 2>/dev/null; echo "0 0 * * * $COMANDO") | crontab -

	CLAVE="$HOME/.ssh/id_ed25519"
	if [ ! -f "$CLAVE" ]
	then
		echo "--- GENERANDO CLAVE SSH PARA BACKUPS ---"
		ssh-keygen -t ed25519 -N "" -f "$CLAVE"
	else
		echo "--- USANDO CLAVE YA EXISTENTE ---"
	fi
	
	echo "--- SE VA A INSTALAR LA CLAVE EN $ip ---"
	echo "(Ahora se te va a preguntar por la contraseña)"
	ssh-copy-id root@$ip
	echo "Generando script de copias de seguridad"




cat << 'EOF' > "$HOME/backupdir.sh"
#!/bin/bash
IP_REMOTA="REEMPLAZAR_IP"
DESTINO="$HOME/backups/$(date +%Y/%m/%d)"
mkdir -p "$DESTINO"

scp -rv root@$IP_REMOTA:/etc/squid/squid.conf "$DESTINO/"
scp -rv root@$IP_REMOTA:/etc/squid/acl.txt "$DESTINO/"
scp -rv root@$IP_REMOTA:/etc/dhcp/dhcpd.conf "$DESTINO/"
scp -rv root@$IP_REMOTA:/etc/network/interfaces "$DESTINO/"
scp -rv root@$IP_REMOTA:/etc/freeradius/3.0/clients "$DESTINO/"

ssh root@$IP_REMOTA "iptables-save" > "$DESTINO/iptables.rules"
EOF

    sed -i "s/REEMPLAZAR_IP/$ip/g" "$HOME/backupdir.sh"
    chmod +x "$HOME/backupdir.sh"

    (crontab -l 2>/dev/null | grep -v "backupdir.sh"; echo "30 0 * * * $HOME/backupdir.sh") | crontab -

    echo "[OK]"

else
	echo "Introduce una ip valida!"
fi
