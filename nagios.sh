#!/bin/bash

wget=""
echo " #########installing of wget comamnd############"$wget
yum install wget

echo "##############Install Required Dependencies###############"
dnf install -y gcc glibc glibc-common perl httpd php wget gd gd-devel
echo "###############start the HTTPD service for now, enable it to automatically start at system boot and check its status using the systemctl commands####################."
systemctl start httpd  
systemctl enable httpd  
systemctl start httpd  

echo "##################Downloading, Compiling and Installing Nagios Core##############"
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.3.tar.gz
tar xzf nagioscore.tar.gz
cd nagioscore-nagios-4.4.3/
echo "##############commands to configure the source package and build it#################"
./configure  
make all  
echo "##############create the Nagios User and Group##################"
make install-groups-user
usermod -a -G nagios apache
echo "##############install the binary files, CGIs, and HTML files with using the following commands.############"
make install  
make install-daemoninit
echo "#############install and configure the external command file, a sample configuration file and the Apache-Nagios configuration file.#################"
make install-commandmode 
make install-config 
make install-webconf 
echo " ###############HTTP basic authentication.#################"
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
echo "############Installing Nagio Plugins in RHEL 8##############"
dnf install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils  

echo "##########extract the latest version of the Nagios Plugins using the following commands.##########"
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz 
tar zxf nagios-plugins.tar.gz      
echo "##############Move into the extracted directory.##################"
cd nagios-plugins-release-2.2.1/  
./tools/setup   
./configure   
 make   
make install

echo "############restart webserver##################"
systemctl restart httpd.service 
echo "#################start nagios service#################"
systemctl start nagios.service 
echo "###########status of nagios service################"
systemctl status nagios.service
echo "##############If you have firewall running, you need to open port 80 in the firewall.############"
firewall-cmd --permanent --zone=public --add-port=80/tcp 
firewall-cmd --reload    
echo "############disable SELinux #############"
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config 
setenforce 0  


