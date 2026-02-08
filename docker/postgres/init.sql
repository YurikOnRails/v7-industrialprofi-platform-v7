-- Initialization script for PostgreSQL
-- Создаем дополнительные БД для Solid Stack

-- Test database
CREATE DATABASE industrialprofi_test;

-- Solid Stack databases (для production-like локального окружения)
CREATE DATABASE industrialprofi_cache;
CREATE DATABASE industrialprofi_queue;
CREATE DATABASE industrialprofi_cable;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE industrialprofi_development TO postgres;
GRANT ALL PRIVILEGES ON DATABASE industrialprofi_test TO postgres;
GRANT ALL PRIVILEGES ON DATABASE industrialprofi_cache TO postgres;
GRANT ALL PRIVILEGES ON DATABASE industrialprofi_queue TO postgres;
GRANT ALL PRIVILEGES ON DATABASE industrialprofi_cable TO postgres;
