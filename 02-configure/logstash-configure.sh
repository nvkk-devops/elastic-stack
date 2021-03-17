configure_for_data_ingestion() {
    cp resources/kern.conf /etc/logstash/conf.d/kern.conf
    chmod a+r /var/log/kern.log
    
    systemctl restart logstash

    # check for any configuration errors
    systemctl status logstash.service

    # From Kibana UI, follow below steps
    # 1. Stack Management > Index Patterns > Create index pattern
    # 2. You will see entries matching pattern 'logstash*'
    # 3. Primary time field use '@timestamp' and Create index  
    # 4. Goto Kibana UI,  discovery menu to verify logs
}

list_logstash_plugins(){
    /usr/share/logstash/bin/logstash-plugins list
    # Below are few examples
    # aws-sqs
    # graphite for Grafana
    # twitter data capture
    # Grok for filter input data i.e, unstructured to structured data
}

interactive_logstash_testing() {
    /usr/share/logstash/bin/logstash -f resources/interactive.conf
    # After jvm starts, paste the commented sample log message from 'interactive.conf' file to test
}


main(){
    configure_for_data_ingestion

    list_logstash_plugins

    interactive_logstash_testing
}

main