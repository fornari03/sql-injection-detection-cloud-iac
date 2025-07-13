#Instalation Wazuh in SIEM
``sudo apt-get install gnupg apt-transport-https

#Ports in SIEM Security Groups
1514 - tcp -> sg-webserver
1515 - tcp -> sg-webserver

#Configuration File in SIEM
sudo nano /var/ossec/etc/ossec.conf

<command>
    <name>firewall-drop</name>
    <executable>firewall-drop</executable>
    <expect>srcip</expect>
    <timeout_allowed>yes</timeout_allowed>
  </command>

<active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>ids</rules_id>
    <level>6</level>
  </active-response>

``sudo systemctl restart wazuh-manager

#Active-Response Logs in WebServer
``sudo tail -f /var/ossec/logs/active-responses.log

#IP Blocks in Web Server
``sudo iptables -L INPUT -n --line-numbers

#Alert logs in SIEM
``sudo tail -f /var/ossec/logs/alerts/alerts.log

