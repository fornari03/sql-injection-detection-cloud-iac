### Instalar pré-requisitos

- sudo apt-get update
- sudo apt-get install -y gnupg apt-transport-https``

### Adicionar o repositório do Wazuh e instalar o Manager no SIEM

- sudo curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && sudo chmod 644 /usr/share/keyrings/wazuh.gpg\n
- sudo echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list\n
- sudo apt-get update\n
- sudo apt-get install -y wazuh-manager``

### Instalar o Agent no WebServer

- sudo curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && sudo chmod 644 /usr/share/keyrings/wazuh.gpg
- sudo echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
- sudo apt-get update
- sudo apt-get install wazuh-agent``

ATENÇÃO
- sudo nano /var/ossec/etc/ossec.conf

```xml
<client>
  <server>
    <address>IP_PRIVADO_DO_SEU_SIEM</address>
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
  ```

- sudo systemctl daemon-reload
- sudo systemctl enable wazuh-agent
- sudo systemctl start wazuh-agent``

### Ports in SIEM Security Groups
1514 - tcp -> sg-webserver
1515 - tcp -> sg-webserver

### Configuration File in SIEM
sudo nano /var/ossec/etc/ossec.conf

```xml
  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop.sh</executable>
    <expect>srcip</expect>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>ids</rules_id>
  </active-response>
```

``sudo systemctl restart wazuh-manager``


### Reiniciar o serviço do Manager
- sudo systemctl restart wazuh-manager
- sudo systemctl enable wazuh-manager


### Configurar o log do Snort no WebServer

- sudo nano /var/ossec/etc/ossec.conf

```xml
<localfile>
  <location>/var/log/snort/snort.alert.fast</location>
  <log_format>snort-fast</log_format>
</localfile>
```


### Reiniciar o serviço do Agente

- sudo systemctl restart wazuh-agent
- sudo systemctl enable wazuh-agent


### No SIEM/Manager: Para ver os alertas centralizados

``sudo tail -f /var/ossec/logs/alerts/alerts.log``
  
### No Webserver/Agente: Para ver as ações de bloqueio

``sudo tail -f /var/ossec/logs/active-responses.log``

### No Webserver/Agente: Para ver os IPs bloqueados no firewall

``sudo iptables -L INPUT -n --line-numbers``
