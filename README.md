\# Parcial 1 - Servicios Telemáticos

\*\*Estudiante:\*\* Mauriel Rodriguez Ospina  

\*\*Repositorio:\*\* Parcial1\_Telematicos  



En este parcial se trabajó con dos máquinas virtuales en VirtualBox creadas con Vagrant, una como servidor \*\*DNS maestro\*\* y otra como \*\*DNS esclavo\*\*. Sobre estas mismas máquinas también se configuró Apache con compresión y finalmente se expuso el servidor web usando ngrok.



---



\## 1. Entorno de trabajo



\- Sistema base: Windows

\- Virtualización: VirtualBox

\- Aprovisionamiento: Vagrant

\- Máquinas:

&nbsp; - \*\*Maestro:\*\* 192.168.56.10

&nbsp; - \*\*Esclavo:\*\* 192.168.56.11



Las dos máquinas se levantaron desde un Vagrantfile y se validó conectividad entre ellas para poder hacer las transferencias de zona.



---



\## 2. Parte 1 - DNS Maestro/Esclavo con transferencia de zona e inversa



Se instaló y configuró \*\*BIND9\*\* en ambas máquinas.



En el \*\*maestro\*\* se creó la zona directa `empresa.local` con registros:

\- A (para maestro y esclavo)

\- CNAME (www apuntando al maestro)

\- AAAA



También se configuró la zona inversa para resolver IP → nombre usando PTR.



En el \*\*esclavo\*\* se configuraron las mismas zonas como tipo \*slave\* para que se descargaran automáticamente desde el maestro. La transferencia se dejó restringida para que solo el esclavo pudiera transferir (por IP), y se habilitó NOTIFY para que el esclavo se actualice cuando haya cambios.



Adicionalmente se deshabilitó la recursión para que el DNS no funcione como resolver público.



\### Pruebas realizadas

\- Resolución directa (A)

\- Alias (CNAME)

\- IPv6 (AAAA)

\- Resolución inversa (PTR)

\- Prueba de seguridad: intento de resolver un dominio externo (no debe resolver por recursión deshabilitada)

\- Tolerancia a fallos: se detuvo el DNS maestro y se verificó que el esclavo siguiera resolviendo.



---



\## 3. Parte 2 - Configuración y evaluación de compresión en Apache



Se instaló \*\*Apache2\*\* en el servidor maestro (192.168.56.10) y se configuró compresión usando `mod\_deflate`.



Se creó el dominio \*\*parcial.mauriel.com\*\* en el DNS local (zona `mauriel.com`) apuntando al servidor web. Esta zona también se replicó al esclavo por transferencia.



Para validar la compresión:

\- Se usó `curl` enviando el header `Accept-Encoding: gzip` y se verificó que el servidor respondiera con `Content-Encoding: gzip`.

\- También se validó en el navegador con DevTools (Network) y en Wireshark capturando el tráfico HTTP.



En las pruebas se observó reducción del tamaño de la respuesta cuando se aplica gzip.



---



\## 4. Parte 3 - Exponer el servidor local a Internet usando ngrok



Se ejecutó \*\*ngrok\*\* desde el equipo host (Windows) creando un túnel HTTP hacia el servidor Apache del maestro:



\- Se generó una URL pública HTTPS.

\- Se verificó que desde esa URL se podía ver el contenido del servidor.

\- Se dejó una página HTML personalizada para evidenciar que el sitio expuesto correspondía al servidor configurado.



---



\## Evidencias / Archivos del repositorio



En este repositorio se encuentra:

\- El `Vagrantfile` usado para levantar las máquinas

\- Archivos de apoyo del parcial (si aplica)

\- Este README con la descripción del trabajo realizado

