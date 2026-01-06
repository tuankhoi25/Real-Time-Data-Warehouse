#/bin/bash

/opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server broker-2:19092 \
    --create \
    --topic tracking.web.events \
    --partitions 1 \
    --replication-factor 2

echo "Created TOPIC"