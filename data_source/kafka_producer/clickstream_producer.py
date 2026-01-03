import pandas as pd
import time
import json
# from kafka import KafkaProducer

df = pd.read_csv('data_source/kaggle_dataset/clickstream.csv')
df['event_timestamp'] = pd.to_datetime(df['event_timestamp'])
df = df.sort_values('event_timestamp')
grouped = df.groupby('event_timestamp')
prev_timestamp = None

# Khởi tạo Kafka Producer
# producer = KafkaProducer(
#     bootstrap_servers=['localhost:9092'],
#     value_serializer=lambda x: json.dumps(x, default=str).encode('utf-8')
# )

for timestamp, frame in grouped:
    
    # Tính toán thời gian chờ
    if prev_timestamp is not None:
        wait_time = (timestamp - prev_timestamp).total_seconds()
        
        if wait_time > 0:
            print(f"--- Chờ {wait_time} giây cho đến mốc: {timestamp} ---")
            time.sleep(wait_time)
    
    # 3. Gửi tất cả các row trong nhóm này vào Kafka
    records = frame.to_dict(orient='records')
    for record in records:
        print(record)
        # producer.send('clickstream_topic', value=record)
    
    # producer.flush()
    print(f"Đã gửi {len(records)} events của mốc thời gian: {timestamp}")
    
    # Cập nhật mốc thời gian vừa xử lý xong
    prev_timestamp = timestamp