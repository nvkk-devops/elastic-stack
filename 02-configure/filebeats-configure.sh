init_lxc_containers() {
    sh resources/lxc/web_test_setup.sh
    lxc list

    # Login to web lxc container
    lxc exec web -- /bin/bash
    systemctl status nginx
    sh resources/lxc/webtest.sh
    tail -f /var/log/nginx/access.log
}

install_filebeats() {
    # 1: Login to 'web' lxc container
    lxc exec web -- /bin/bash

    # 2: Install 'filebeat' plugin as per below instructions
    sudo su -
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    apt-get update 
    apt-get install filebeat

    # 3: Configure filebeat settings
    cd /etc/filebeat/
    ls
    # notice: filebeat.yml, filebeat.reference.yml, fields.yml, modules.d

    # 4: Enable 'nginx' from 'modules.d' directory
    mv /etc/filebeat/modules.d/nginx.yml.disabled /etc/filebeat/modules.d/nginx.yml

    # 5: Edit 'filebeat.yml' to refer to 'elasticsearch' instance
    vi /etc/filebeat/filebeat.yml
    # edit the entries 'output.elasticsearch'.
    # refer file 'resources/filebeat.yml'
}

modify_elasticsearch_server_for_prodmode() {
    # 1. Login to 'vagrant elastic machine'
    vi /etc/elasticsearch/elasticsearch.yml
    # amend entry " network.host: 0 "
    # amend entry " discovery.type: single-node "

    # 2. Restart elastic instance
    systemctl restart elasticsearch
    
    # 3. [optional] Check the status / goto journalctl to see if any errors.
    systemctl status elasticsearch.service
    journalctl -xe

    # 4. check elastic search
    curl localhost:9200

}

validate_elastic_instance_from_filebeats() {
    # 1. Login to lxc web container
    lxc exec web -- /bin/bash

    # 2. curl elastic instance by host name
    curl http://elastic:9200

    # 3. If success, then start filebeat
    systemctl start filebeat

    systemctl status filebeat
}

main() {
    init_lxc_containers

    install_filebeats

    modify_elasticsearch_server_for_prodmode

    validate_elastic_instance_from_filebeats
}

main