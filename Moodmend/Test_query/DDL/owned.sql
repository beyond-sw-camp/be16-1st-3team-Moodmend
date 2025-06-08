-- owned는 conetents 와  items 보유 내역을 관리하는 테이블입니다.

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