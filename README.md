# Parcial 1 – Servicios Telemáticos   
## DNS Maestro/Esclavo con BIND9 + Apache con Compresión + Exposición con ngrok  
  
**Estudiante:** Mauriel Rodríguez Ospina   
**Entorno:** Windows (host) + VirtualBox + Vagrant   
**VMs:** Ubuntu (`ubuntu/jammy64`)   
  
---  
  
# 🎯 Objetivo del Parcial  
  
Implementar un laboratorio completo que incluya:  
  
1. Servidor DNS autoritativo maestro/esclavo con:  
 - Zona directa  
 - Zona inversa  
 - Transferencia de zona (AXFR)  
 - NOTIFY automático  
 - Medidas de seguridad (sin recursión pública)  
  
2. Servidor Apache con:  
 - VirtualHost personalizado  
 - Compresión gzip usando mod_deflate  
 - Exclusiones de archivos ya comprimidos  
 - Validación mediante curl, navegador y Wireshark  
  
3. Exposición del servidor web a Internet usando ngrok.  
  
---  
  
# 🖥️ 1. Topología del Laboratorio  
  
Se crearon dos máquinas virtuales usando Vagrant:  
  
## 🔹 VM1 – maestro.empresa.local  
- IP: 192.168.56.10  
- Rol:  
 - DNS Maestro (BIND9)  
 - Servidor Web (Apache)  
  
## 🔹 VM2 – esclavo.empresa.local  
- IP: 192.168.56.11  
- Rol:  
 - DNS Esclavo  
 - Cliente para pruebas (dig y curl)  
  
Red privada utilizada: 192.168.56.0/24  
  
---  
  
# 🌐 2. Configuración del DNS con BIND9  
  
## Instalación  
  
En ambas máquinas:  

sudo apt update  
sudo apt install -y bind9 bind9utils dnsutils

  
---  
  
## Seguridad aplicada  
  
Se configuró el servidor DNS como autoritativo, evitando que funcione como open resolver:  
  
- `recursion no;`  
- `allow-recursion { none; };`  
- `allow-query { localhost; 192.168.56.0/24; };`  
  
Esto evita que el servidor resuelva dominios externos.  
  
---  
  
## Zonas configuradas en el Maestro  
  
1. empresa.local (zona directa)  
2. 56.168.192.in-addr.arpa (zona inversa)  
3. mauriel.com (para el servidor web)  
  
Se aplicó:  
  
- allow-transfer solo al esclavo (192.168.56.11)  
- notify yes;  
- also-notify 192.168.56.11;  
  
---  
  
## Registros creados  
  
### Zona directa empresa.local  
  
- maestro → 192.168.56.10  
- esclavo → 192.168.56.11  
- www → maestro  
- Registro AAAA configurado  
  
Validación:  

sudo named-checkzone empresa.local /etc/bind/db.empresa.local

  
---  
  
### Zona inversa  
  
- 10 → maestro.empresa.local  
- 11 → esclavo.empresa.local  
  
Validación:  

sudo named-checkzone 56.168.192.in-addr.arpa /etc/bind/db.192.168.56

  
---  
  
## Configuración del Esclavo  
  
Las zonas se declararon como:  

type slave;  
masters { 192.168.56.10; };

  
Se verificó que los archivos de zona fueran transferidos correctamente.  
  
---  
  
# 🔍 3. Verificación del DNS  
  
Se realizaron pruebas con:  

dig @192.168.56.11 maestro.empresa.local  
dig @192.168.56.11 -x 192.168.56.10  
dig @192.168.56.11 google.com

  
Resultados:  
  
- Resolución directa correcta.  
- Resolución inversa correcta.  
- No resuelve dominios externos (seguridad activa).  
  
También se detuvo el maestro para comprobar que el esclavo siguiera respondiendo correctamente.  
  
---  
  
# 🌎 4. Configuración de Apache  
  
## Instalación  

sudo apt install -y apache2  
sudo systemctl enable --now apache2

  
---  
  
## VirtualHost Personalizado  
  
Se creó el dominio:  

parcial.mauriel.com

  
Archivo:  

/etc/apache2/sites-available/parcial-mauriel.conf

  
Se activó con:  

sudo a2ensite parcial-mauriel.conf  
sudo a2dissite 000-default.conf  
sudo systemctl reload apache2

  
Verificación:  

apache2ctl -S

  
El VirtualHost activo es:  

*:80 parcial.mauriel.com

  
---  
  
# 📦 5. Compresión gzip con mod_deflate  
  
Se activaron los módulos:  

sudo a2enmod deflate  
sudo a2enmod headers  
sudo systemctl restart apache2

  
Se configuró compresión para:  
  
- text/html  
- text/css  
- application/javascript  
- application/json  
  
Se excluyeron imágenes y archivos multimedia ya comprimidos.  
  
---  
  
## Verificación de compresión  
  
Sin gzip:  

curl -I [http://parcial.mauriel.com](http://parcial.mauriel.com)

  
Con gzip:  

curl -I -H "Accept-Encoding: gzip" [http://parcial.mauriel.com](http://parcial.mauriel.com)

  
Se verificó la presencia de:  

Content-Encoding: gzip

  
También se validó en:  
  
- DevTools del navegador  
- Wireshark (captura HTTP)  
  
---  
  
# 🌍 6. Exposición con ngrok  
  
Desde Windows:  

ngrok http 192.168.56.10:80

  
Se generó una URL pública HTTPS que permitió acceder al servidor desde fuera de la red local.  
  
Se comprobó mostrando una página personalizada.  
  
---  
  
# 📁 Archivos incluidos  
  
- Vagrantfile  
- Archivos de configuración DNS  
- Archivos de zona  
- Configuración de Apache  
- Configuración de compresión  
- Página HTML de prueba  
- README con documentación  
  
---
