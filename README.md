# bgpalerter_with_zabbix
This is a simple guide that uses [BGPalerter](https://github.com/nttgin/BGPalerter) and [Zabbix Log Monitoring feature](https://www.zabbix.com/documentation/current/en/manual/config/items/itemtypes/log_items) to deploy BGPalerter and integrate it into Zabbix monitoring.

Shortly about BGPalerter:
BGP and RPKI monitoring tool. Pre-configured for real-time detection of visibility loss, RPKI invalid announcements, hijacks, ROA misconfiguration, and more.
BGPalerter connects to well known IRR Databases and downloads up to date information about BGP resources. The entire monitoring is done directly in the application. Can be deployed on different OS platforms. As a service, and also as a container.

# Deploying BGPalerter on Linux platforms
In this guide I will focus on deploying it as a Linux systemd service. 

Additionally, I have enhanced bgpalerter with some BASH scripts to automatically check and download updates, check if the service is alive. The scripts can be run automatically using cronjobs or in my case, using systemd timers. Most importantly these scripts also provide logging which will be used by Zabbix to monitor status, updates, errors, and reports.

# Systemd services that will be created
| Name | Description |
| --- | --- |
| bgpalerter.service | The BGPalerter daemon. Runs the binary. |
| bgpalerter-check.service | BGPalerter status check service. Runs bgpalerter-check-status.sh |
| bgpalerter-check.timer | Timer for bgpalerter-check.service. Execute every 5 minutes. |
| bgpalerter-update.service | BGPalerter update checking service. Runs bgpalerter-check-update.sh |
| bgpalerter-update.timer | Timer for bgpalerter-update.service. Execute every month. |

# Create the user and download the binary file
BGPalerter will be deployed locally on the same Host as Zabbix Server.
```
useradd bgpalerter -m -s /bin/bash
su -l bgpalerter
wget https://github.com/nttgin/BGPalerter/releases/latest/download/bgpalerter-linux-x64
chown -R bgpalerter:bgpalerter bgpalerter-linux-x64
chmod +x bgpalerter-linux-x64
```

# Create and import configuration files
More about config.yml, prefixes.yml here: [BGPalerter Configuration](https://github.com/nttgin/BGPalerter/blob/main/docs/configuration.md)
| Name | Description |
| --- | --- |
| config.yml | BGPalerter Main configuration file |
| prefixes.yml | BGPalerter monitored prefixes and ASNs |
| bgpalerter-check-update.sh | BGPalerter update checking script |
| bgpalerter-check-status.sh | BGPalerter status checking script |


```
#IN MY CASE I CREATED CONFIG FILES ON A REMOTE HOST AND SECURE-COPIED THEM TO OUR ZABBIX SERVER
scp config.yml prefixes.yml bgpalerter-check-update.sh bgpalerter-check-status.sh user@zabbix.your.domain
chown -R bgpalerter:bgpalerter config.yml prefixes.yml bgpalerter-check-update.sh bgpalerter-check-status.sh
chmod +x chown -R bgpalerter:bgpalerter bgpalerter-check-update.sh bgpalerter-check-status.sh
```

# Create bgpalerter.service service
```
sudo nano /etc/systemd/system/bgpalerter.service
```
Insert the bgpalerter.service configuration

# Create the bgpalerter-check.service
```
sudo nano /etc/systemd/system/bgpalerter-check.service
```
Insert the bgpalerter-status.service configuration to run the bgpalerter-check-status.sh script.
# Create the bgpalerter-check.timer
```
sudo nano /etc/systemd/system/bgpalerter-check.timer
```
Insert the bgpalerter-check.timer configuration. Execute service every 5 minutes.
# Create the bgpalerter-update.service
```
sudo nano /etc/systemd/system/bgpalerter-update.service
```
Insert the bgpalerter-update.service configuration to run the bgpalerter-check-update.sh script.
# Create the bgpalerter-update.timer
```
sudo nano /etc/systemd/system/bgpalerter-update.timer
```
Insert the bgpalerter-update.timer configuration. Execute service every month.
# Start services and timers
```
sudo systemctl daemon-reload
sudo systemctl enable bgpalerter.service bgpalerter-*.service bgpalerter-*.timer
sudo systemctl start bgpalerter.service bgpalerter-*.service bgpalerter-*.timer
```

# Disable login for user bgpalerter
```
sudo nano /etc/passwd
```
And edit the line of user bgpalerter to:
```
bgpalerter:x:1003:1003::/home/bgpalerter:/sbin/nologin
```


# Logging of BGPalerter
All BGPalerter services are logging into the ```/home/bgpalerter/logs``` directory.

| Name | Description |
| --- | --- |
| reports.log | Reports about AS, Prefix Hijacks, ROA Expiration etc...  |
| error.log | bgpalerter.service execution errors and debug |
| status.log | bgpalerter process for status and update checking |

# Zabbix Monitoring of Logs
BGPalerter is deployed on the same host as Zabbix Server. Now we need to define in Zabbix WEB UI our Items, Alerts and Triggers.

Crete Template:
![9d16e3ad-0547-42f1-9dde-1d02a9ed518d](https://user-images.githubusercontent.com/43334417/222545752-0e5f7780-213a-4b80-87e6-fd0370340b03.png)

Create Items:
![e201d27c-8371-42f2-85d7-c94090c7551c](https://user-images.githubusercontent.com/43334417/222545923-888c3667-5314-4b57-89e4-bd62c1c7fa97.png)

Create Triggers:
![89f06d91-26de-4445-a674-4361756a6e03](https://user-images.githubusercontent.com/43334417/222546405-5d7e3fab-1494-4115-b8da-c30a670f7250.png)

# Final Words
Feel free to update the content of this Project to your needs. All the files are attached.
Thank you!
