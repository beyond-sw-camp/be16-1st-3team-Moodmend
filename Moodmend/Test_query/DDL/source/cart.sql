CREATE TABLE cart (
  cart_id BIGINT NOT NULL AUTO_INCREMENT,
  contents_id BIGINT,                 -- 콘텐츠 ID: NULL 가능
  members_id BIGINT NOT NULL,         -- 회원 ID: 필수
  items_id BIGINT,                    -- 아이템 ID: NULL 가능
  total INT UNSIGNED NOT NULL DEFAULT 0,  -- 총합 금액: 반드시 존재
  
  PRIMARY KEY (cart_id),
  
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id),

  -- 콘텐츠와 아이템 중 하나만 선택 가능
  CHECK (
    (contents_id IS NOT NULL AND items_id IS NULL) OR 
    (contents_id IS NULL AND items_id IS NOT NULL)
  )
);