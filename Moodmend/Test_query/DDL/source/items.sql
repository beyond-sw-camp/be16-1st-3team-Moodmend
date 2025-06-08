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