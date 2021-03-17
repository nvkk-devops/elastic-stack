init_lxc_containers() {
    sh resources/lxc/web_test_setup.sh
    lxc list

    # Login to web lxc container
    lxc exec web -- /bin/bash
    systemctl status nginx
    sh resources/lxc/webtest.sh
    tail -f /var/log/nginx/access.log
}


# Install auditbeat on hostmachine
install_auditbeat_hostmachine() {

    # 1: Login to 'web' lxc container
    lxc exec web -- /bin/bash

    # --- Pre-requisite --- #
    systemctl status auditd

    # 2: Install 'auditbeat' plugin as per below instructions
    sudo su -
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    apt-get install apt-transport-https -y
    echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    apt-get update
    apt-get install auditbeat
    systemctl enable auditbeat

    # 3: Configure auditbeat settings
    # Refer: resources/auditbeat_hostmachine.yml

    # 7: Test the configurations
    sudo auditbeat test config
    sudo auditbeat test output

    # 8: Dashboards: setup indexes and default dashboards using CLI
    sudo auditbeat setup -e --dashboards
    # message will appear 'Loaded dashboards'

    # 9: Start auditbeat
    systemctl start auditbeat

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