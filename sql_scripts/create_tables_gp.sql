CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    birth_date DATE,
    employer VARCHAR(100)
) WITH (APPENDONLY=FALSE)  -- Использую head, т.к в этой таблице постоянная вставка данных
DISTRIBUTED BY (id);

CREATE TABLE cards (
    id SERIAL PRIMARY KEY,
    card_number VARCHAR(20),
    client_id INT REFERENCES clients(id) ON DELETE CASCADE,
    card_type VARCHAR(50),
    issue_date DATE,
    "expiry_date" DATE
) WITH (APPENDONLY=FALSE) -- Использую head, т.к в этой таблице постоянная вставка данных
DISTRIBUTED BY (id);

CREATE TABLE operations (
    id SERIAL PRIMARY KEY,
    operation_name VARCHAR(50)
) WITH (APPENDONLY=FALSE) -- Использую head, т.к в этой таблице постоянная вставка данных
DISTRIBUTED BY (id);

CREATE TABLE transactions (
    id SERIAL,
    card_id INT REFERENCES cards(id) ON DELETE CASCADE,
    transaction_date DATE,
    amount INT,
    operation_id INT REFERENCES operations(id) ON DELETE CASCADE
) WITH (APPENDONLY=FALSE) -- Использую head, т.к в этой таблице постоянная вставка данных
DISTRIBUTED BY (id)
PARTITION BY RANGE (transaction_date)
(
    PARTITION p2020 START ('2020-01-01') END ('2021-01-01'),
    PARTITION p2021 START ('2021-01-01') END ('2022-01-01'),
    PARTITION p2022 START ('2022-01-01') END ('2023-01-01'),
    PARTITION p2023 START ('2023-01-01') END ('2024-01-01'),
    PARTITION p2024 START ('2024-01-01') END ('2025-01-01'),
    PARTITION p2025 START ('2025-01-01') END ('2026-01-01')
);

CREATE TABLE insufficient_funds (
    id INTEGER,
    card_id INTEGER,
    transaction_date DATE,
    amount INTEGER,
    operation_id INTEGER
) WITH (APPENDONLY=TRUE, -- Использую append-optimized,
                         -- т.к данные вставляются из transactions с помощью запроса
        COMPRESSTYPE=zstd, -- поменял на zstd, оказывается zlib устарелая версия сжатия
        COMPRESSLEVEL=1    -- данных немного (+-10% от таблицы transactions)
                           -- значения 1 хватит для сжатия данных, при этом давая меньшую нагрузку
) DISTRIBUTED BY (id);

CREATE TABLE card_is_invalid (
    id INTEGER,
    card_id INTEGER,
    transaction_date DATE,
    amount INTEGER,
    operation_id INTEGER,
    "expiry_date" DATE
) WITH (APPENDONLY=TRUE, -- Использую append-optimized,
                         -- т.к данные вставляются из transactions с помощью запроса
        COMPRESSTYPE=zstd, -- поменял на zstd, оказывается zlib устарелая версия сжатия
        COMPRESSLEVEL=1 -- данных немного (+-3% от таблицы transactions)
                        -- значения 1 хватит для сжатия данных, при этом давая меньшую нагрузку
) DISTRIBUTED BY (id);