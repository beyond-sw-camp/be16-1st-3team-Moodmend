SELECT * FROM moodmend.items;

INSERT INTO moodmend.items (
  members_id, items_name, items_category, items_price, items_desc, items_thumbnail, graphic_source
)
VALUES (
  1, '핑크 곱슬머리', '헤어', 1000, '한정판 핑크 곱슬머리 아바타 아이템입니다.', 'image.url', 'image.url'
);

INSERT INTO moodmend.items (
  members_id, items_name, items_category, items_price, items_desc, items_thumbnail, graphic_source
)
VALUES (
  2, '흰 면 티셔츠', '상의', 20, '기본 아이템입니다.', 'image.url', 'image.url'
);

SELECT * FROM moodmend.items;