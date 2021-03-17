install_elasticsearch(){
    sudo su -
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    apt-get update && sudo apt-get install elasticsearch openjdk-11-jre -y
    systemctl start elasticsearch
}

install_kibana(){
    sudo su -
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt-get install -y kibana
    systemctl status kibana

    systemctl start kibana

    # Edit /etc/kibana/kibana.yml 
}

install_logstash(){
    # Add entry to /etc/yum.repos.d/logstash.repo
# [logstash-7.x]
# name=Elastic repository for 7.x packages
# baseurl=https://artifacts.elastic.co/packages/7.x/yum
# gpgcheck=1
# gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
# enabled=1
# autorefresh=1
# type=rpm-md

    sudo apt-get install -y logstash-oss 
    # edit /etc/default/logstash to add JAVA_HOME
    sudo systemctl enable logstash
    sudo systemctl start logstash
}


install_xpack(){
    # Refer to ../03-advanced/install-xpack.sh

}