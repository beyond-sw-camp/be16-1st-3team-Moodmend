CREATE TABLE payment_detail (
  payment_detail_id BIGINT NOT NULL AUTO_INCREMENT,
  contents_id BIGINT NULL,    -- 콘텐츠 결제일 경우 사용
  payment_id BIGINT NOT NULL, -- 필수
  items_id BIGINT NULL,       -- 아이템 결제일 경우 사용
  purchase_type ENUM('콘텐츠 구매', '아이템 구매') NOT NULL,
  price INT UNSIGNED NOT NULL,

  PRIMARY KEY (payment_detail_id),

  FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
  FOREIGN KEY (payment_id) REFERENCES payment(payment_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id),

  -- 콘텐츠 또는 아이템 중 하나만 존재하도록 체크
  CHECK (
    (contents_id IS NOT NULL AND items_id IS NULL)
    OR
    (contents_id IS NULL AND items_id IS NOT NULL)
  )
);
