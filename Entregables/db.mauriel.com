$TTL    604800
@       IN      SOA     maestro.mauriel.com. admin.mauriel.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@       IN      NS      maestro.mauriel.com.

maestro IN      A       192.168.56.10
esclavo IN      A       192.168.56.11
parcial IN      A       192.168.56.10