from pandas import read_csv, to_datetime
from time import sleep
from json import dumps
from kafka import KafkaProducer


df = read_csv('data_source/kaggle_dataset/clickstream.csv')
df['event_timestamp'] = to_datetime(df['event_timestamp'])
df = df.astype(object).where(df.notnull(), None)
df = df.sort_values('event_timestamp')
grouped = df.groupby('event_timestamp')
prev_timestamp = None


try:
    producer = KafkaProducer(
        bootstrap_servers=[
            'localhost:29092',
            'localhost:39092',
            'localhost:49092'
        ],
        value_serializer=lambda x: dumps(x, default=str).encode('utf-8'),
        allow_auto_create_topics=False
    )

    for timestamp, frame in grouped:
        
        # Tính toán thời gian chờ
        if prev_timestamp is not None:
            wait_time = (timestamp - prev_timestamp).total_seconds()
            
            if wait_time > 0:
                print(f"--- Chờ {wait_time} giây cho đến mốc: {timestamp} ---")
                sleep(wait_time)
        
        # 3. Gửi tất cả các row trong nhóm này vào Kafka
        records = frame.to_dict(orient='records')
        for record in records:
            print(record)
            producer.send('tracking.web.events', value=record)
        
        producer.flush()
        print(f"Đã gửi {len(records)} events của mốc thời gian: {timestamp}")
        
        # Cập nhật mốc thời gian vừa xử lý xong
        prev_timestamp = timestamp
except KeyboardInterrupt:
    print("Stopping producer...")
finally:
    producer.flush()
    producer.close()