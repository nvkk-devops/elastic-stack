#! /bin/bash
# Script for setting up sandbox web server and clients

cat /var/sandbox/sandbox.yml | lxd init --preseed 

echo $(ip -4 a show lxdbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') elastic elastic.local >> /etc/hosts

lxc launch ubuntu:18.04 web
sleep 10
mkdir /var/lib/lxd/storage-pools/default/containers/web/rootfs/var/www/
mv /var/sandbox/ttoo /var/lib/lxd/storage-pools/default/containers/web/rootfs/var/www/html
chown -R 100000:100000 /var/lib/lxd/storage-pools/default/containers/web/rootfs/var/www/

# Install packages on lxc container
lxc exec web -- apt-get update
lxc exec web -- apt-get install -y nginx siege

# copy resources to 'web' lxc container
cp /var/sandbox/nginx.conf /var/lib/lxd/storage-pools/default/containers/web/rootfs/etc/nginx/nginx.conf
chown -R 100000:100000 /var/lib/lxd/storage-pools/default/containers/web/rootfs/etc/nginx/nginx.conf
cp /var/sandbox/urls.txt /var/lib/lxd/storage-pools/default/containers/web/rootfs/etc/urls.txt
chown -R 100000:100000 /var/lib/lxd/storage-pools/default/containers/web/rootfs/etc/urls.txt
cp /var/sandbox/scripts/webtest /var/lib/lxd/storage-pools/default/containers/web/rootfs/usr/local/bin/
chown -R 100000:100000 /var/lib/lxd/storage-pools/default/containers/web/rootfs/usr/local/bin/webtest

lxc exec web -- chgrp -R www-data /var/www/
lxc exec web -- chmod +x /usr/local/bin/webtest
lxc exec web -- systemctl restart nginx


