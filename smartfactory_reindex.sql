-- Đảm bảo sử dụng đúng cơ sở dữ liệu hệ thống SmartFactory
CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

-- 1. Giả định cấu trúc bảng IoT logs ban đầu phục vụ bài tập
CREATE TABLE IF NOT EXISTS iot_data (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    device_id INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    recorded_at DATETIME NOT NULL
);

-- Giả định Covering Index cũ bị vi phạm dư thừa không gian bộ nhớ:
-- CREATE INDEX idx_covering_full ON iot_data(recorded_at, status, temperature, humidity);

-- =========================================================================
-- TIÊU CHÍ 1: XÓA INDEX CŨ VÀ TẠO INDEX TINH GỌN CHỈ VỚI 2 CỘT LỌC
-- =========================================================================
-- Bước A: DROP chỉ mục dư thừa
ALTER TABLE iot_data DROP INDEX idx_covering_full;

-- Bước B: CREATE chỉ mục mới tối ưu, chỉ giữ lại 2 cột phục vụ lọc điều kiện (SARGable)
CREATE INDEX idx_date_status ON iot_data(recorded_at, status);


-- =========================================================================
-- TIÊU CHÍ 2: CHỨNG MINH SỰ THAY ĐỔI CỦA CỘT EXTRA TRONG EXPLAIN
-- =========================================================================
-- Lúc này, nếu SELECT toàn bộ cột, hệ thống phải thực hiện Lookup Table (Bookmark Lookup/Key Lookup)
-- Cột Extra sẽ không còn "Using index" (từ bộ nhớ đệm index) nữa mà sẽ chuyển sang "Using where"
EXPLAIN SELECT log_id, device_id, status, temperature, humidity, recorded_at 
FROM iot_data 
WHERE recorded_at >= '2026-09-01 00:00:00' AND status = 'Active';
