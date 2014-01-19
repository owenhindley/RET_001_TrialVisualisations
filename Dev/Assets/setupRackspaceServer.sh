#!/bin/bash
 
# log into your server
ssh root@134.213.27.85

# change root password
passwd

# update all packages and operating system
apt-get update && apt-get --yes upgrade

# setup date to match date and time of current timezone
sudo dpkg-reconfigure tzdata

# verify local date and time
date

# make sure the server keeps our time up to date
apt-get install ntp
update-rc.d ntp enable

# I reboot here, log back in and verify the server's time has not changed
reboot
ssh root@134.213.27.85
date

# install common applications
apt-get install members
apt-get install pwgen
apt-get install language-pack-en-base
apt-get install ufw
apt-get install vsftpd
apt-get install aptitude
apt-get install dnsutils
apt-get install make
apt-get install autofs
apt-get install discus

# reboot the box
reboot
ssh root@134.213.27.85

# ------------------------------------------------------------------------------
# SETUP NANO -------------------------------------------------------------------
# ------------------------------------------------------------------------------

nano ~/.nanorc

# add all of the text between the starting [[ and ending ]]
[[

set const

]]

# save file, exit
ctrl+x, y, enter = save file and exit

# ------------------------------------------------------------------------------
# INSTALL APACHE ---------------------------------------------------------------
# ------------------------------------------------------------------------------

apt-get install apache2

# back up the setup files
cp /etc/apache2/httpd.conf /etc/apache2/httpd.conf.original
cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.original
cp /etc/apache2/envvars /etc/apache2/envvars.original
cp /etc/apache2/sites-available/default /etc/apache2/sites-available/default.original
cp /etc/apache2/sites-available/default-ssl /etc/apache2/sites-available/default-ssl.original

# enable modules
sudo a2enmod rewrite

# setup vhosts
nano /etc/apache2/httpd.conf

# add all of the text between the starting [[ and ending ]]
[[

NameVirtualHost *

]]

# reboot the box
reboot
ssh root@134.213.27.85

# ------------------------------------------------------------------------------
# DEFAULT WEBSITE --------------------------------------------------------------
# ------------------------------------------------------------------------------

mkdir /srv/backup
mkdir /srv/ftp
mkdir /srv/www
mkdir /srv/www/default.site

# edit default and add dummy content
nano /srv/www/default.site/index.html

# add all of the text between the starting [[ and ending ]]
# [[

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Hello World</title>
<style>
.container {
  margin: 150px auto;
}
h1 {
  font: 120px/200px Helvetica, sans-serif, bold;
  text-align: center;
}
</style>
</head>
<body>
<div class="container">
 <h1>Hello World</h1>
</div>
</body>
</html>

# ]]

# save file, exit, than open the default configuration
ctrl+x, y, enter = save file and exit

# setup the apache default site
rm /etc/apache2/sites-available/default
nano /etc/apache2/sites-available/default

# add all of the text between the starting [[ and ending ]]
[[

<VirtualHost *>
    ServerAdmin owen.hindley@b-reel.com
    
    ErrorDocument 400 /error.htm
    ErrorDocument 401 /error.htm
    ErrorDocument 403 /error.htm
    ErrorDocument 404 /error.htm
    ErrorDocument 500 /error.htm 

    DocumentRoot /srv/www/default.site
    <Directory />
        Options FollowSymLinks
        AllowOverride None
    </Directory>
    <Directory /srv/www/default.site/>
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
    <Directory /srv/www/default.site/archive>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>


    ErrorLog ${APACHE_LOG_DIR}/error.log

    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    LogLevel warn

    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

]]

# reboot the box
reboot
ssh root@134.213.27.85

# ------------------------------------------------------------------------------
# INSTALL MYSQL ----------------------------------------------------------------
# ------------------------------------------------------------------------------

# make sure to change your root mysql user password, I recommend something different than your server root
apt-get install mysql-server mysql-client
stop mysql

# backup default configuration
cp /etc/mysql/my.cnf /etc/mysql/my.cnf.original

# change default port  
nano /etc/mysql/my.cnf

change port on line 20: [use at least a 4 digit port number, and write down the port you selected]

# save file, exit
ctrl+x, y, enter = save file and exit

# startup mysql
start mysql

# reboot the box
reboot
ssh root@134.213.27.85

# ------------------------------------------------------------------------------
# INSTALL PHP ------------------------------------------------------------------
# ------------------------------------------------------------------------------

# base install
apt-get install php5 libapache2-mod-php5

# required common packages
apt-get install php5-mysql php5-curl php5-gd php5-idn php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# reboot the box
reboot
ssh root@134.213.27.85

# setup php dump file
nano /srv/www/default.site/server.php

# add all of the text between the starting [[ and ending ]]
# [[

<?php
// Show all information, defaults to INFO_ALL
phpinfo();
?>

# ]]

# save file, exit
save file and exit

# reboot the box
reboot
ssh root@134.213.27.85

# ------------------------------------------------------------------------------
# SETUP USERS ----- Add Administrators -----------------------------------------
# ------------------------------------------------------------------------------

# this should be specific to your configuration
adduser sherlock

# groups for global, ftp, ssh
groupadd admin
groupadd sshlogin
groupadd ftplogin

adduser  sherlock adm
adduser  sherlock admin
adduser  sherlock sshlogin
adduser  sherlock ftplogin
adduser  sherlock www-data

# base permissions
chown -R root.admin /srv/backup
chown -R root.www-data /srv/www
chmod -R 775 /srv/www

# ------------------------------------------------------------------------------
# SSH SECURITY -----------------------------------------------------------------
# ------------------------------------------------------------------------------

# copy our ssh key to the server, I use specific keys for numerous connections, check out other posts for help with key generation
scp ~/.ssh/id_rsa.rackspace.pub root@134.213.27.85:/home/sherlock/

# mv the ssh key to our ssh key directory
mkdir /home/sherlock/.ssh
mv /home/sherlock/id_rsa.rackspace.pub /home/sherlock/.ssh/authorized_keys

# root permissions
chown -R sherlock:sherlock /home/sherlock/.ssh
chmod 700 /home/sherlock/.ssh
chmod 600 /home/sherlock/.ssh/authorized_keys

# backup the config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original

# make the config secure
nano /etc/ssh/sshd_config

Set New Port [pick a port >3000 and write down the port you selected]: 0000 [should be on line 5] 
Verify Set to Yes: RSAAuthentication yes [should be on line 31]
Verify Set to Yes: PubkeyAuthentication yes [should be on line 32]
Uncomment: Banner /etc/issue.net  [remove the "#" around line 71]

# add all of the text between the starting [[ and ending ]] to the very end of this file
# [[

#disable dns reverse lookup since we are using keys
UseDNS no
#only the sshlogin group is allowed to ssh into the server
AllowGroups sshlogin

# ]]

# save file, exit
ctrl+x, y, enter = save file and exit

# setup the ssh login message
nano /etc/issue.net

# add all of the text between the starting [[ and ending ]]
# [[

***************************************************************************

                            NOTICE TO USERS

This computer system is the private property of its owner, whether
individual, corporate or government.  It is for authorized use only.
Users (authorized or unauthorized) have no explicit or implicit
expectation of privacy.

Any or all uses of this system and all files on this system may be
intercepted, monitored, recorded, copied, audited, inspected, and
disclosed to your employer, to authorized site, government, and law
enforcement personnel, as well as authorized officials of government
agencies, both domestic and foreign.

By using this system, the user consents to such interception, monitoring,
recording, copying, auditing, inspection, and disclosure at the
discretion of such personnel or officials.  Unauthorized or improper use
of this system may result in civil and criminal penalties and
administrative or disciplinary action, as appropriate. By continuing to
use this system you indicate your awareness of and consent to these terms
and conditions of use. LOG OFF IMMEDIATELY if you do not agree to the
conditions stated in this warning.

****************************************************************************

# ]]

# restart ssh for changes to work
sudo /etc/init.d/ssh restart

# reboot the box
reboot

# test to make sure our ssh keys are setup correctly, this step is CRITICAL. If setup incorrectly, you can lock yourself out of your server
ssh sherlock@134.213.27.85 -p [ssh port setup earlier]

# if you can get in successfully, it's time to lock it down even more, first switch to the root user
su root

# edit the ssh configuration again
nano /etc/ssh/sshd_config

Set: PermitRootLogin no [should be on line 27]
Uncomment and Set: PasswordAuthentication no [should be on line 51]

# save file, exit
ctrl+x, y, enter = save file and exit

# reboot the box
reboot
ssh sherlock@134.213.27.85 -p [ssh port setup earlier]
su root

# ------------------------------------------------------------------------------
# FTP --------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# downgrade vsftp to previous edition to avoid jail ftp user issue
# http://www.benscobie.com/fixing-500-oops-vsftpd-refusing-to-run-with-writable-root-inside-chroot/ 
sudo add-apt-repository ppa:thefrontiergroup/vsftpd
sudo apt-get update
sudo apt-get install vsftpd

# reboot the box
reboot
ssh sherlock@134.213.27.85 -p [ssh port setup earlier]
su root

# backup the ftp configuration
cp /etc/vsftpd.conf /etc/vsftpd.conf.original

#add users that are admins or have full ftp access to this list
nano /etc/vsftpd.chroot_list

# extra help for reference: http://ubuntuforums.org/showthread.php?t=518293
# edit the ftp configuration
nano /etc/vsftpd.conf

# after listen=yes around line 16, hit enter and add the following
listen_port=[pick a port >3000, different from the ssh port, and write down the port you selected] 
Set: anonymous_enable=NO [should be on line 25]
Uncomment: local_enable=YES  [should be on line 28]
Uncomment: write_enable=YES  [remove the "#" around line 31]
Uncomment: local_umask=022  [remove the "#" around line 35]
Uncomment and Set: anon_upload_enable=NO   [remove the "#" around line 40, set to NO]
Uncomment and Set: anon_mkdir_write_enable=NO [remove the "#" around line 44, set to NO]
Set: connect_from_port_20=NO [should be on line 60]
Uncomment: xferlog_file=/var/log/vsftpd.log [should be on line 70]
Uncomment: xferlog_std_format=YES [should be on line 74]
Uncomment: idle_session_timeout=600 [should be on line 77]
Uncomment: data_connection_timeout=120 [should be on line 80]
Comment out: #ftpd_banner=Welcome to blah FTP service. [should be on line 104]
Add: banner_file=/etc/issue.net [add underneath #ftp_banner to match ssh login screen, should be on line 105]
Comment Out: # chroot_local_user=YES [should be on line 115]
Uncomment: chroot_local_user=YES [should be on line 123]
Uncomment: chroot_list_enable=YES [should be on line 124]
Uncomment : chroot_list_file=/etc/vsftpd.chroot_list [should be on line 126]

# add all of the text between the starting [[ and ending ]] to the very end of this file
# [[

# Show hidden files and the "." and ".." folders.
# Useful to not write over hidden files:
force_dot_files=YES

# Hide the info about the owner (user and group) of the files.
hide_ids=YES

# Connection limit for each IP:
max_per_ip=10

# Maximum number of clients:
max_clients=5

# FTP Passive Settings
pasv_enable=YES
#If your listen_port is 8000 set this range to 7500 and 8500 
pasv_min_port=[port range min]
pasv_max_port=[port range max]

# Keep non-chroot listed users jailed
allow_writeable_chroot=YES

# ]]

# restart the ftp service to make the changes stick
sudo service vsftpd restart

#test ftp via secondary terminal window:
ftp [ftp user name]@134.213.27.85 [ftp port]

# reboot the box
reboot
ssh sherlock@134.213.27.85 -p [ssh port setup earlier]
su root

# ------------------------------------------------------------------------------
# FIREWALL ---------------------------------------------------------------------
# ------------------------------------------------------------------------------

# enable the firewall previously installed
ufw enable

# turn on logging
ufw logging on

# set log level
ufw logging low

# delete all existing rules
ufw status numbered
ufw delete

# allow http port
ufw allow 80/tcp

# allow https port
ufw allow 443/tcp

# allow ssh port
ufw limit [ssh port]/tcp   

# allow port for ftp
ufw allow [ftp port]/tcp  

# allow passive ftp ports
ufw allow [min port range]:[max port range]/tcp  

# allow port for mysql
ufw limit [sql port] 

# limit ssh/tcp rapid attacks
ufw limit ssh/tcp

# check firewall rules
ufw status numbered

# reboot the box
reboot
ssh sherlock@134.213.27.85 -p [ssh port setup earlier]
su root

# ------------------------------------------------------------------------------
# Prevent DDOS -----------------------------------------------------------------
# ------------------------------------------------------------------------------

# Install Apache modules
sudo apt-get install libapache2-mod-evasive libapache-mod-security

# Create Backup Dir
sudo mkdir /var/log/apache2/mod_evasive

# Set ownership to Apache
sudo chown www-data:www-data /var/log/apache2/mod_evasive/

# Create a configuration file in your conf.d directory all files in this folder gets read by Apache Server
sudo nano /etc/apache2/conf.d/mod_evasive.conf

# add all of the text between the starting [[ and ending ]] to this file
# [[

DOSHashTableSize 3097
DOSPageCount 2
DOSSiteCount 50
DOSPageInterval 1
DOSSiteInterval 1
DOSBlockingPeriod 10
DOSLogDir /var/log/apache2/mod_evasive
DOSWhitelist 127.0.0.1

# ]]

# Enable the modules and restart Apache Server:
sudo a2enmod mod-evasive
sudo a2enmod mod-security
sudo /etc/init.d/apache2 restart

# Install Mod-Qos:
sudo apt-get install libapache2-mod-qos

# Backup Original Install:
cp /etc/apache2/mods-available/qos.conf /etc/apache2/mods-available/qos.conf.original

# Setup the Config file:
nano /etc/apache2/mods-available/qos.conf 

# add all of the text between the starting [[ and ending ]] to this file
# [[

<IfModule qos_module>

## QoS Settings
# handles connections from up to 100000 different IPs
QS_ClientEntries 100000

# will allow only 50 connections per IP
QS_SrvMaxConnPerIP 50

# maximum number of active TCP connections is limited to 256
MaxClients 256

# disables keep-alive when 70% of the TCP connections are occupied:
QS_SrvMaxConnClose 70%

# minimum request/response speed (deny slow clients blocking the server, ie. slowloris keeping connections open without requesting anything):
QS_SrvMinDataRate 150 1200

# and limit request header and body:
# LimitRequestFields 30
# QS_LimitRequestBody 102400

</IfModule>

# ]]

