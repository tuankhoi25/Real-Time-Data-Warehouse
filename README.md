# Real-Time-Data-Warehouse

# Đúc kết

Hiểu được cách thiết kế để tích hợp ClickHouse - Apache Kafka cho từng trường hợp. Chi tiết tại [Notion](https://www.notion.so/How-to-integrate-ClickHouse-with-Apache-Kafka-2e5b74c8fed180589fa8c452141f551e?source=copy_link)

# Bộ dữ liệu 

Dữ liệu được sử dụng cho project này sẽ là bộ dữ liệu về một website bán hàng được cung cấp bởi [Kaggle](https://www.kaggle.com/datasets/wafaaelhusseini/e-commerce-transactions-clickstream).

Sử dụng bộ dữ liệu có cả clickstream data và transaction data là để tạo ra use case triển khai một data platform dùng cả batch processing và streaming processing

**Lưu ý**: vì vấn đề bản quyền của bộ dữ liệu của Amazon trên Kaggle nên không public hầu hết các bảng dữ liệu.

Thông tin cơ bản về transaction data
<p align="center">
  <img src="https://github.com/user-attachments/assets/8250443a-0658-4f97-869d-c08cb513bcc8" alt="ERD">
</p>
<p align="center">
  <strong>ERD của data source (OLTP)</strong>
</p>

<br><br>

Thông tin cơ bản về clickstream data
<p align="center">
  <img src="https://github.com/user-attachments/assets/f6f12531-5aa3-46b9-8446-eaf28a00b3eb" alt="Clickstream Flow">
</p>
<p align="center">
  <strong>Flow chuẩn (lý tưởng) kèm payload của các event của clickstream data</strong>
</p>