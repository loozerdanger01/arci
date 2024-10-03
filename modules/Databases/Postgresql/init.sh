

#!/bin/bash
apt-get -y update
apt-get -y install xfsprogs
UNMOUNTED_DISKS=($(lsblk -n -o NAME,TYPE,MOUNTPOINT | awk '$2=="disk" && $3=="" && $4=="" {print "/dev/" $1}'))
echo "UNMOUNTED_DISKS - $UNMOUNTED_DISKS"

UNPARTIONED_DISK=$(for disk_device in $UNMOUNTED_DISKS; do fdisk -l "$disk_device" | grep -q "Disklabel type:" || { echo "$disk_device"; break; }; done)
if [[ ! -z "$UNPARTIONED_DISK" ]]
then
    apt-get -y install gnupg2 wget
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sh -c "gpg --dearmor > /etc/apt/trusted.gpg.d/postgresqldb.gpg"

    apt-get -y update
    apt-get -y install postgresql-14
    systemctl restart postgresql

    pg_createcluster -u postgres -d $MOUNT_POINT/postgresql/postgresql-14/primary 14 primary

    PRIVATE_IP=$(hostname -I | awk '{print $1}')
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses='$PRIVATE_IP'/g" /etc/postgresql/14/primary/postgresql.conf

    sed -i "s/max_connections = 100/max_connections=9999/g" /etc/postgresql/14/primary/postgresql.conf

    tee -a /etc/postgresql/14/primary/pg_hba.conf <<EOF 
    host          all          all          ${VpcCIDR}     md5
EOF

    systemctl enable postgresql
    pg_ctlcluster 14 primary start
    systemctl restart postgresql

    sudo -u postgres psql -p ${DatabasePort} -c "CREATE DATABASE ${DatabaseName};"
    sudo -u postgres psql -p ${DatabasePort} -c "CREATE USER ${DatabaseUser} WITH CREATEROLE CREATEDB SUPERUSER REPLICATION PASSWORD '${DatabasePassword}';"
    sudo -u postgres psql -p ${DatabasePort} -d ${DatabaseName}  -c "ALTER USER postgres PASSWORD '${DatabasePassword}';"
    
    pg_ctlcluster 14 main stop
fi