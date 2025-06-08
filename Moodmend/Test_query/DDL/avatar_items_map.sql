CREATE TABLE avatar_items_map (
    avatar_items_map_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    avatar_id           BIGINT NOT NULL,
    items_id            BIGINT NOT NULL,

    CONSTRAINT fk_aim_avatar FOREIGN KEY (avatar_id) REFERENCES avatar(avatar_id),
    CONSTRAINT fk_aim_items FOREIGN KEY (items_id) REFERENCES items(items_id)
);