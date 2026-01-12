/opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server kafka-broker-02:19092 \
    --create \
    --topic tracking.web.events \
    --partitions 4 \
    --replication-factor 2

echo "Created TOPIC"