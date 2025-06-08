CREATE TABLE payment (
  payment_id BIGINT NOT NULL AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  items_id BIGINT NULL,  -- ✅ 콘텐츠 결제를 위해 NULL 허용
  payment_method ENUM('신용카드','카카오페이','삼성페이','아이템') NOT NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  refund_date DATETIME,
  refund_require BOOLEAN DEFAULT FALSE,
  total_price INT UNSIGNED NOT NULL,
  PRIMARY KEY (payment_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id)
);