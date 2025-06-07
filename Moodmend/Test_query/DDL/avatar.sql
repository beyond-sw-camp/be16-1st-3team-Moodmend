
CREATE TABLE avatar (
    avatar_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id    BIGINT NOT NULL UNIQUE,
    avatar_name   VARCHAR(50),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_default    BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT fk_avatar_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);


CREATE TABLE avatar_items_map (
    avatar_items_map_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    avatar_id           BIGINT NOT NULL,
    items_id            BIGINT NOT NULL,

    CONSTRAINT fk_aim_avatar FOREIGN KEY (avatar_id) REFERENCES avatar(avatar_id),
    CONSTRAINT fk_aim_items FOREIGN KEY (items_id) REFERENCES items(items_id)
);


CREATE TABLE items (
    items_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id       BIGINT NOT NULL,
    items_name       VARCHAR(30) NOT NULL,
    items_category   ENUM('헤어', '상의', '하의', '신발', '악세서리', '테두리', '뱃지') NOT NULL,
    items_price      INT NOT NULL,
    items_desc       TEXT NOT NULL,
    items_thumbnail  TEXT NOT NULL,
    graphic_source   TEXT NOT NULL,

    CONSTRAINT fk_items_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);


CREATE TABLE owned (
    owned_id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id         BIGINT NOT NULL,
    items_id           BIGINT NULL,
    contents_id        BIGINT NULL,
    payment_detail_id  BIGINT NOT NULL,
    acquired_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_type        ENUM('결제', '보상') NOT NULL DEFAULT '결제',
    is_equipped        BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_owned_members         FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_owned_items           FOREIGN KEY (items_id) REFERENCES items(items_id),
    CONSTRAINT fk_owned_contents        FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
    CONSTRAINT fk_owned_payment_detail  FOREIGN KEY (payment_detail_id) REFERENCES payment_detail(payment_detail_id),

    CONSTRAINT uc_owned_item     UNIQUE (members_id, items_id),
    CONSTRAINT uc_owned_contents UNIQUE (members_id, contents_id)
);