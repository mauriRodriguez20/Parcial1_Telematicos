# Parcial 1 – DNS Maestro/Esclavo con BIND9 + Apache con Compresión

**Realizado por:** Mauriel Rodríguez Ospina  
**Entorno:** Windows (host) + VirtualBox + Vagrant  
**VMs:** Ubuntu (Vagrant box `ubuntu/jammy64`)  

---

## 🎯 Objetivo del Parcial

1. Implementar un servidor DNS autoritativo maestro/esclavo usando BIND9, incluyendo:
   - Zona directa
   - Zona inversa
   - Transferencia de zona (AXFR) segura
   - NOTIFY automático
   - Medidas de seguridad (sin recursión pública)

2. Configurar un servidor Apache con compresión gzip usando mod_deflate, aplicar exclusiones y verificar su funcionamiento.

3. Exponer el servidor web mediante ngrok y validar acceso externo.

---

# 1️⃣ Topología del laboratorio

Se crearon dos máquinas virtuales usando Vagrant:

### 🔹 VM1 – maestro.empresa.local
- IP: 192.168.56.10
- Rol:
  - DNS Maestro (BIND9)
  - Servidor Web (Apache)

### 🔹 VM2 – esclavo.empresa.local
- IP: 192.168.56.11
- Rol:
  - DNS Esclavo (BIND9)
  - Cliente para pruebas (dig y curl)

Red privada: 192.168.56.0/24

---

# 2️⃣ Creación de las máquinas con Vagrant

Desde la carpeta del proyecto:

vagrant up


Acceso por SSH:


-vagrant ssh maestro
-vagrant ssh esclavo


---

# 3️⃣ Configuración DNS con BIND9

## 🔹 Instalación en ambas máquinas


sudo apt update
sudo apt install -y bind9 bind9utils dnsutils


Verificación:


sudo systemctl status bind9


---

## 🔹 Seguridad aplicada

En ambas VMs se configuró BIND como autoritativo:

- `recursion no;`
- `allow-recursion { none; };`
- `allow-query { localhost; 192.168.56.0/24; };`

Esto evita que el servidor funcione como open resolver.

---

## 🔹 Zonas configuradas en el Maestro

1. empresa.local (zona directa)
2. 56.168.192.in-addr.arpa (zona inversa)
3. mauriel.com (para Apache)

Se aplicó:

- allow-transfer solo al esclavo (192.168.56.11)
- notify yes;
- also-notify al esclavo

---

## 🔹 Registros creados

### Zona directa empresa.local

- A:
  - maestro → 192.168.56.10
  - esclavo → 192.168.56.11
- CNAME:
  - www → maestro
- AAAA configurado

Validación:


sudo named-checkzone empresa.local /etc/bind/db.empresa.local


---

### Zona inversa

- 10 → maestro.empresa.local
- 11 → esclavo.empresa.local

Validación:


sudo named-checkzone 56.168.192.in-addr.arpa /etc/bind/db.192.168.56


---

## 🔹 Configuración del Esclavo

Se declararon las zonas como:


type slave;
masters { 192.168.56.10; };


Se verificó que los archivos fueran descargados correctamente en:


/var/cache/bind/


---

# 4️⃣ Verificación DNS

Desde el esclavo:

Resolución directa:


dig @192.168.56.11 maestro.empresa.local


Resolución inversa:


dig @192.168.56.11 -x 192.168.56.10


Prueba de seguridad:


dig @192.168.56.11 google.com


No debe resolver dominios externos.

Prueba de alta disponibilidad:
Se detuvo el servicio bind9 en el maestro y el esclavo continuó respondiendo correctamente.

---

# 5️⃣ Configuración de Apache

Instalación en el maestro:


sudo apt install -y apache2
sudo systemctl enable --now apache2


---

## 🔹 VirtualHost

Se configuró el dominio:


parcial.mauriel.com


Apuntando a:


192.168.56.10


Se creó el archivo de configuración en:


/etc/apache2/sites-available/parcial-mauriel.conf


---

# 6️⃣ Compresión gzip con mod_deflate

Activación:


sudo a2enmod deflate
sudo a2enmod headers
sudo systemctl restart apache2


Se configuró compresión para:

- text/html
- text/css
- application/javascript
- application/json

Se excluyeron:

- .jpg
- .png
- .gif
- .mp4
- .pdf

Verificación:


curl -I -H "Accept-Encoding: gzip" http://parcial.mauriel.com


Debe aparecer:


Content-Encoding: gzip


Se comprobó también con navegador (DevTools) y Wireshark.

---

# 7️⃣ Exposición del servidor con ngrok

Desde Windows:


ngrok http 192.168.56.10:80


Se generó una URL pública HTTPS que permitió acceder al servidor desde fuera de la red local.

Se validó mostrando una página personalizada.

---

# 📁 Archivos incluidos en este repositorio

- Vagrantfile
- Archivos de configuración DNS
- Archivos de configuración Apache
- Archivos de zona
- Archivo HTML de prueba
- README con documentación del proceso

---

# ✅ Conclusión

Se implementó correctamente una arquitectura DNS maestro/esclavo segura, se configuró un servi
