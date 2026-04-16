# **Proyecto de Automatización Proxy Squid**

## **Descripción General**

Este repositorio contiene un conjunto de herramientas y scripts diseñados para el despliegue automatizado de un servidor Proxy Squid con capacidades de interceptación SSL (SSL Bumping) y gestión mediante una interfaz web integrada. El sistema está optimizado para entornos de red basados en sistemas operativos Debian.
Tambien se incluye instalacion de un servidor RADIUS con DHCP, DNS y extras.

## **Características Técnicas**

* **Intercepción SSL/TLS**: Implementación de SSL Bump para navegacion por sitios HTTPS.
* **Gestión Web Centralizada**: Interfaz administrativa desarrollada en PHP con sistema de autenticación basado en sesiones. (Opcional)
* **Persistencia de Datos**: Almacenamiento de credenciales y registros (RADIUS/Interfaz de config.) en MariaDB/MySQL.
* **Modularidad de PHP**: Detección dinámica de la versión de PHP instalada para la configuración automática de servicios PHP-FPM y sockets de NGINX.
* **Proxy Transparente**: Configuración automatizada de reglas de IPTABLES para la redirección de tráfico sin requerir configuración manual en los dispositivos cliente.
* **RADIUS**: Configuración e instalacion de RADIUS para autenticacion GTC wireless 802.11X.
* **ACL**: Bloqueo basado en listas de control de acceso.

## **Procedimiento de Instalación**

Se requiere un sistema base Debian 12 con al menos dos interfaces de red configuradas (WAN y LAN).

1. Clonar el repositorio:
   git clone https://github.com/JuanPCG/Proyecto-Proxy-Squid.git
2. Acceder al directorio:
   cd Proyecto-Proxy-Squid
3. Ejecutar el instalador (Como superusuario):
   ./main.sh

## **Documentación y Wiki**

Para obtener detalles adicionales sobre la arquitectura de red, manuales de usuario específicos y guías de resolución de problemas técnicos, consulte la wiki oficial: https://cristobal.wiki/  
Mantenido por JuanPCG y LDMG
