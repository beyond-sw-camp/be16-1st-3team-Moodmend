DELIMITER $$Add commentMore actions

CREATE PROCEDURE 승지_01_회원관리_회원가입 (
  IN p_name VARCHAR(20),
  IN p_password VARCHAR(255),
  IN p_phone_number VARCHAR(20),
  IN p_nickname VARCHAR(20),
  IN p_birthday DATE,
  IN p_email VARCHAR(50),
  IN p_role ENUM('Admin', 'Teacher', 'User'),
  IN p_signup_type ENUM('Email', 'Kakao', 'Google', 'Naver')
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM members 
    WHERE phone_number = p_phone_number OR email = p_email
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '이미 등록된 이메일 또는 전화번호입니다.';
  ELSE
    INSERT INTO members (
      name, password, phone_number, nickname, birthday, email,
      role, signup_type, created_at, updated_at, point
    )
    VALUES (
      p_name, p_password, p_phone_number, p_nickname, p_birthday, p_email,
      p_role, p_signup_type, NOW(), NOW(), 0
    );
  END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 승지_02_회원관리_로그인 (
  IN p_login_id VARCHAR(50), -- 이메일 또는 전화번호
  IN p_password VARCHAR(255)
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM members 
    WHERE (email = p_login_id OR phone_number = p_login_id)
      AND password = p_password
  ) THEN
    SELECT members_id, name, nickname FROM members 
    WHERE (email = p_login_id OR phone_number = p_login_id)
      AND password = p_password;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '로그인 정보가 일치하지 않습니다.';
  END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 승지_03_회원관리_로그아웃 (
  IN p_members_id BIGINT
)
BEGIN
  INSERT INTO logout_log (members_id) VALUES (p_members_id);
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 승지_04_회원관리_친구추가 (
  IN p_requester_id BIGINT,
  IN p_receiver_id BIGINT
)
BEGIN
  IF p_requester_id = p_receiver_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '자기 자신을 친구로 추가할 수 없습니다.';
  ELSEIF EXISTS (
    SELECT 1 FROM friend 
    WHERE requester_id = p_requester_id AND receiver_id = p_receiver_id
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '이미 친구 요청을 보냈거나 친구입니다.';
  ELSE
    INSERT INTO friend (requester_id, receiver_id, status)
    VALUES (p_requester_id, p_receiver_id, 'friend');
  END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 승지_05_회원관리_친구삭제 (
  IN p_requester_id BIGINT,
  IN p_receiver_id BIGINT
)
BEGIN
  DELETE FROM friend 
  WHERE requester_id = p_requester_id AND receiver_id = p_receiver_id;
END$$

DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_06_게시판_등록 (
  IN p_members_id BIGINT,
  IN p_avatar_id BIGINT,
  IN p_title VARCHAR(50),
  IN p_text TEXT,
  IN p_category ENUM('고민','질문','좋은글','자유'),
  IN p_is_anonymous BOOLEAN
)
BEGIN
  INSERT INTO post (members_id, avatar_id, title, text, category, is_anonymous, created_at, updated_at)
  VALUES (p_members_id, p_avatar_id, p_title, p_text, p_category, p_is_anonymous, NOW(), NOW());
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_07_게시판_카테고리별조회 (
  IN p_category ENUM('고민','질문','좋은글','자유')
)
BEGIN
  SELECT * FROM post
  WHERE category = p_category;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_08_게시판_조회 (
  IN p_post_id BIGINT
)
BEGIN
  SELECT * FROM post
  WHERE post_id = p_post_id;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_09_게시판_수정 (
  IN p_post_id BIGINT,
  IN p_members_id BIGINT,
  IN p_title VARCHAR(50),
  IN p_text TEXT,
  IN p_category ENUM('고민','질문','좋은글','자유'),
  IN p_is_anonymous BOOLEAN
)
BEGIN
  UPDATE post
  SET title = p_title,
      text = p_text,
      category = p_category,
      is_anonymous = p_is_anonymous,
      updated_at = NOW()
  WHERE post_id = p_post_id AND members_id = p_members_id;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_10_게시판_삭제 (
  IN p_post_id BIGINT,
  IN p_members_id BIGINT
)
BEGIN
  DELETE FROM post
  WHERE post_id = p_post_id AND members_id = p_members_id;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_11_게시판_관리자삭제 (
  IN p_post_id BIGINT
)
BEGIN
  DELETE FROM post
  WHERE post_id = p_post_id;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_12_게시판_조회수별조회 ()
BEGIN
  SELECT * FROM post
  ORDER BY views DESC;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_13_게시판_좋아요수별조회 ()
BEGIN
  SELECT * FROM post
  ORDER BY likes DESC;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_14_게시판_특정조회수확인 (
  IN p_post_id BIGINT
)
BEGIN
  SELECT views FROM post
  WHERE post_id = p_post_id;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE 승지_15_게시판_좋아요수별조회 (
  IN p_post_id BIGINT
)
BEGIN
  SELECT likes FROM post
  WHERE post_id = p_post_id;Add commentMore actions
END;
//
DELIMITER ;