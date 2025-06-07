CREATE TABLE contents (
    contents_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id     BIGINT NOT NULL,
    emotion_id    BIGINT NOT NULL,
    name          VARCHAR(100) NOT NULL,
    upload_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description   TEXT NOT NULL,
    thumbnail     TEXT NOT NULL,
    duration      INT NOT NULL,
    is_premium    ENUM('일반', '프리미엄') NOT NULL DEFAULT '일반',
    views         BIGINT NOT NULL,
    price         INT UNSIGNED NOT NULL DEFAULT 0,
    video_url     TEXT NOT NULL,

    -- 외래키 제약
    CONSTRAINT fk_contents_members FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_contents_emotion FOREIGN KEY (emotion_id) REFERENCES emotion(emotion_id)
);
