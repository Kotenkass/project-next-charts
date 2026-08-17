CREATE DATABASE IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS analytics.answers_raw (
    chat_id     Int64,
    answer_id   Int64,
    sent_at     DateTime,
    created_at  DateTime DEFAULT now()
) ENGINE = MergeTree
ORDER BY (chat_id, sent_at);
