-- 게시판 등록 프로시저

DELIMITER $$

CREATE PROCEDURE 승지_06_게시판_등록 (
  IN p_members_id BIGINT,
  IN p_title VARCHAR(50),
  IN p_text TEXT,
  IN p_category VARCHAR(10), -- ENUM이지만 VARCHAR로 받고 체크
  IN p_is_anonymous BOOLEAN
)
BEGIN
  DECLARE v_avatar_id BIGINT;

  -- 유효 카테고리 검사
  IF p_category NOT IN ('고민', '질문', '좋은글', '자유') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '유효하지 않은 게시글 카테고리입니다.';
  END IF;

  -- 아바타 존재 확인
  IF NOT EXISTS (
    SELECT 1 FROM avatar WHERE members_id = p_members_id
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '해당 멤버는 등록된 아바타가 없습니다.';
  END IF;

  -- 아바타 ID 조회
  SELECT avatar_id INTO v_avatar_id
  FROM avatar
  WHERE members_id = p_members_id
  LIMIT 1;

  -- 게시글 등록
  INSERT INTO post (
    members_id, avatar_id, title, text, category, is_anonymous, created_at, updated_at
  ) VALUES (
    p_members_id, v_avatar_id, p_title, p_text, p_category, p_is_anonymous, NOW(), NOW()
  );
END$$

DELIMITER ;


-- 성후라는 일반 유저가 게시판에 글을 등록
call moodmend.승지_06_게시판_등록(3, '안녕하세요.', '임성후입니다.', '자유', 0);

select * from moodmend.post;