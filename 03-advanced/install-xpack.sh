xpack_install() {
    # Applicable for elasticsearch <= 6.2 version

    systemctl stop elasticsearch
    /usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack
    systemctl start elasticsearch
    
    /usr/share/elasticsearch/bin/x-pack/setup-passwords auto
    
    systemctl status kibana

    bin/kibana-plugin install x-pack
}