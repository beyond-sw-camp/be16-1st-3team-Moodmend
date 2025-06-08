CREATE TABLE avatar (
    avatar_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id    BIGINT NOT NULL UNIQUE,
    avatar_name   VARCHAR(50),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_default    BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT fk_avatar_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);
