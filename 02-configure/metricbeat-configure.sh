init_lxc_containers() {
    sh resources/lxc/web_test_setup.sh
    lxc list

    # Login to web lxc container
    lxc exec web -- /bin/bash
    systemctl status nginx
    sh resources/lxc/webtest.sh
    tail -f /var/log/nginx/access.log
}

# Install metricbeat on elasticsearch server
install_metricbeat_elasticsearch_server(){
    # 1: Login to vagrant@elastic

    # 2: Instll 'metricbeat'
    apt-get update
    apt-get install metricbeat

    # 3: configure 'metricbeat' settings inside elasticsearch.yml 
    # Refer resoures/elasticsearch.yml, section 'x-pack monitoring'
    # Refer resoures/metribeat_elasticserver.yml

    # 4: Restart 'elasticsearch' & metribeat
    systemctl restart elasticsearch
    systemctl start metricbeat

    # Refer the directory: /etc/metricbeat/modules.d/

    # 5: Enable 'elasticsearch-xpack' module
    sudo metricbeat modules enable elasticsearch-xpack

    # 4: Enable 'kibana-xpack' module
    sudo metricbeat modules enable kibana-xpack

    # 5: Enable 'beat-xpack' module : monitor the other shippers
    sudo metricbeat modules enable beat-xpack

    # 6: Test the configurations
    sudo metribeat test config
    sudo metribeat test outout

    # 7: Validate KIBANA UI
    # KibanaUI -> Management -> Stack Monitoring -> Observe Elastic/Kibana metrics
}

# Install metricbeat on hostmachine
install_metricbeat_hostmachine() {
    # 1: Login to 'web' lxc container
    lxc exec web -- /bin/bash

    # 2: Install 'metricbeat' plugin as per below instructions
    sudo su -
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    apt-get install apt-transport-https -y
    echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    apt-get update
    apt-get install metricbeat
    systemctl enable metricbeat

    # 3: Configure metricbeat settings
    # Refer: resources/metricbeat_hostmachine.yml

    # Refer the directory: /etc/metricbeat/modules.d/

    # 4: Enable 'apache' from 'modules.d' directory
    sudo metricbeat modules enable apache
    # NOTE: Edit /etc/metricbeat/modules.d/apache.yml

    # 5: Enable 'system' from 'modules.d' directory
    sudo metricbeat modules enable system

    # 6: Enable 'beat-xpack' from 'modules.d' directory
    sudo metricbeat modules enable beat-xpack

    # 7: Test the configurations
    sudo metribeat test config
    sudo metribeat test outout

    # 8: Dashboards: setup indexes and default dashboards using CLI
    sudo metricbeat setup --dashboards
    # message will appear 'Loaded dashboards'

    # 9: Validate KIBANA UI
    # KibanaUI -> Management -> Stack Monitoring -> Observe Elastic/Kibana metrics
}



modify_elasticsearch_server_for_prodmode() {
    

}


main() {
    init_lxc_containers

    install_metricbeat_elasticsearch_server

    install_metricbeat_hostmachine
    
}

main