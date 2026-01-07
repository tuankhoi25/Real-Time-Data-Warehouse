#/bin/bash

/opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server kafka-broker-02:19092 \
    --create \
    --topic tracking.web.events \
    --partitions 1 \
    --replication-factor 2

echo "Created TOPIC"