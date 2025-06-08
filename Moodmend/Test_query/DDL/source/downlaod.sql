CREATE TABLE download (
    download_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    contents_id    BIGINT NOT NULL,
    members_id     BIGINT NOT NULL,
    downloaded_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- 외래키 제약
    CONSTRAINT fk_download_contents FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
    CONSTRAINT fk_download_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);