#!/bin/bash
################################################################################
# Script for Installation: ODOO 10.0 Community server on Ubuntu 16.04
# Author: cason wang, tailored from Andre' Schenkels
# Author: André Schenkels, ICTSTUDIO 2015
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# USAGE:
#
# odoo-install
#
# EXAMPLE:
# ./odoo-install
#
################################################################################

ODOO_USER="odoo"
ODOO_HOME="/opt/$ODOO_USER"
ODOO_HOME_EXT="/opt/$ODOO_USER/$ODOO_USER-server"

ODOO_VERSION="10.0"

#set the superadmin password
ODOO_SUPERADMIN="1sw-odoo"
ODOO_CONFIG="$ODOO_USER-server"


#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y locales

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
sudo dpkg-reconfigure locales
sudo locale-gen C.UTF-8
sudo /usr/sbin/update-locale LANG=C.UTF-8

echo -e "\n---- Set locales ----"
echo 'LC_ALL=C.UTF-8' >> /etc/environment

echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y

echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"

if [ ! -f /etc/postgresql/9.5/main/postgresql.conf ]; then
    sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/9.5/main/postgresql.conf
fi

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $ODOO_USER" 2> /dev/null || true

sudo systemctl restart postgresql.service
#--------------------------------------------------
# System Settings
#--------------------------------------------------

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$ODOO_HOME --gecos 'ODOO' --group $ODOO_USER

echo -e "\n---- Create Log directory ----"

if [ ! -f /var/log/$ODOO_USER ]; then
    sudo mkdir /var/log/$ODOO_USER
fi

sudo chown $ODOO_USER:$ODOO_USER /var/log/$ODOO_USER

#--------------------------------------------------
# Install Basic Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install wget git python-pip python-imaging python-setuptools python-dev libxslt-dev libxml2-dev libldap2-dev libsasl2-dev node-less postgresql-server-dev-all -y

echo -e "\n---- Install wkhtml and place on correct place for ODOO  ----"

if [ ! -f /usr/local/bin/wkhtmltopdf ]; then
    #sudo wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
    sudo wget https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
    xz -d wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
    tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar

    sudo cp -r wkhtmltox/* /usr/local/
    sudo cp /usr/local/bin/wkhtmltopdf /usr/bin
    sudo cp /usr/local/bin/wkhtmltoimage /usr/bin

    rm -rf wkhtmltox*
fi


#--------------------------------------------------
# Install ODOO
#--------------------------------------------------

echo -e "\n==== Download ODOO Server ===="
cd $ODOO_HOME
sudo su $ODOO_USER -c "git clone --depth 1 --single-branch --branch $ODOO_VERSION https://www.github.com/odoo/odoo $ODOO_HOME_EXT/"
cd -

echo -e "\n---- Create custom module directory ----"
sudo su $ODOO_USER -c "mkdir $ODOO_HOME/custom"
sudo su $ODOO_USER -c "mkdir $ODOO_HOME/custom/addons"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $ODOO_USER:$ODOO_USER $ODOO_HOME/*


#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo pip install -r $ODOO_HOME_EXT/requirements.txt

#echo -e "\n---- Install python packages ----"
sudo easy_install pyPdf vatnumber pydot psycogreen suds ofxparse


#--------------------------------------------------
# Configure ODOO
#--------------------------------------------------
echo -e "* Create server config file"
sudo cp $ODOO_HOME_EXT/debian/odoo.conf /etc/$ODOO_CONFIG.conf
sudo chown $ODOO_USER:$ODOO_USER /etc/$ODOO_CONFIG.conf
sudo chmod 640 /etc/$ODOO_CONFIG.conf

echo -e "* Change server config file"
echo -e "** Remove unwanted lines"
sudo sed -i "/db_user/d" /etc/$ODOO_CONFIG.conf
sudo sed -i "/admin_passwd/d" /etc/$ODOO_CONFIG.conf
sudo sed -i "/addons_path/d" /etc/$ODOO_CONFIG.conf

echo -e "** Add correct lines"
sudo su root -c "echo 'db_user = $ODOO_USER' >> /etc/$ODOO_CONFIG.conf"
sudo su root -c "echo 'admin_passwd = $ODOO_SUPERADMIN' >> /etc/$ODOO_CONFIG.conf"
sudo su root -c "echo 'logfile = /var/log/$ODOO_USER/$ODOO_CONFIG$1.log' >> /etc/$ODOO_CONFIG.conf"
sudo su root -c "echo 'addons_path=$ODOO_HOME_EXT/addons,$ODOO_HOME/custom/addons' >> /etc/$ODOO_CONFIG.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $ODOO_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $ODOO_USER $ODOO_HOME_EXT/openerp-server --config=/etc/$ODOO_CONFIG.conf' >> $ODOO_HOME_EXT/start.sh"
sudo chmod 755 $ODOO_HOME_EXT/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

INIT_FILE=/lib/systemd/system/$ODOO_CONFIG.service

TMP_INIT_FILE=$ODOO_CONFIG.service
touch $TMP_INIT_FILE
chmod 0700 $TMP_INIT_FILE

echo -e "* Create systemd unit file"
echo '[Unit]' >> $TMP_INIT_FILE
echo 'Description=ODOO Application Server' >> $TMP_INIT_FILE
echo 'Requires=postgresql.service' >> $TMP_INIT_FILE
echo 'After=postgresql.service' >> $TMP_INIT_FILE
echo '[Install]' >> $TMP_INIT_FILE
echo "Alias=$ODOO_CONFIG.service" >> $TMP_INIT_FILE
echo '[Service]' >> $TMP_INIT_FILE
echo 'Type=simple' >> $TMP_INIT_FILE
echo 'PermissionsStartOnly=true' >> $TMP_INIT_FILE
echo "User=$ODOO_USER" >> $TMP_INIT_FILE
echo "Group=$ODOO_USER" >> $TMP_INIT_FILE
echo "SyslogIdentifier=$ODOO_CONFIG" >> $TMP_INIT_FILE
echo "PIDFile=/run/odoo/$ODOO_CONFIG.pid" >> $TMP_INIT_FILE
echo "ExecStartPre=/usr/bin/install -d -m755 -o $ODOO_USER -g $ODOO_USER /run/odoo" >> $TMP_INIT_FILE
echo "ExecStart=/opt/odoo/odoo-server/odoo-bin -c /etc/$ODOO_CONFIG.conf --pid=/run/odoo/$ODOO_CONFIG.pid --syslog $OPENERP_ARGS" >> $TMP_INIT_FILE
echo 'ExecStop=/bin/kill $MAINPID' >> $TMP_INIT_FILE
echo '[Install]' >> $TMP_INIT_FILE
echo 'WantedBy=multi-user.target' >> $TMP_INIT_FILE

echo -e "* Enabling Systemd File"
sudo mv $TMP_INIT_FILE $INIT_FILE
sudo systemctl enable $INIT_FILE

echo -e "-- Starting ODOO Server --"
sudo systemctl start $ODOO_CONFIG.service
