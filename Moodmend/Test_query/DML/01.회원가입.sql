DELIMITER $$

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
  DECLARE v_members_id BIGINT;
  DECLARE v_initial_point INT DEFAULT 100;

  START TRANSACTION;

  -- 1. 중복 확인
  IF EXISTS (
    SELECT 1 FROM members 
    WHERE phone_number = p_phone_number OR email = p_email
  ) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '이미 등록된 이메일 또는 전화번호입니다.';
  END IF;

  -- 2. 회원 등록 (포인트 기본 100)
  INSERT INTO members (
    name, password, phone_number, nickname, birthday, email,
    role, signup_type, created_at, updated_at, point
  )
  VALUES (
    p_name, p_password, p_phone_number, p_nickname, p_birthday, p_email,
    p_role, p_signup_type, NOW(), NOW(), v_initial_point
  );

  SET v_members_id = LAST_INSERT_ID();

  -- 3. 기본 아바타 등록
  INSERT INTO avatar (
    members_id,
    avatar_name,
    is_default
  ) VALUES (
    v_members_id,
    '기본 아바타',
    TRUE
  );

  -- 4. 포인트 이력 기록
  INSERT INTO point_reward (members_id, point_reward, reason)
  VALUES (v_members_id, v_initial_point, '회원가입 보상');

  COMMIT;
END$$

DELIMITER ;


-- 프로시저 호출 예시 (관리자 계정 생성)
call moodmend.승지_01_회원관리_회원가입('관리자', '@1234!', '01012345678', '관리자', '1980-10-01', 'admin@mm.com', 'Admin', 'Email');

-- 프로시저 호출 예시 (티처 계정 생성)
call moodmend.승지_01_회원관리_회원가입('홍길동', '@1357!', '01022223333', '티처', '1990-03-03', 'teacher@mm.com', 'Teacher', 'Kakao');

-- 프로시저 호출 예시 (일반 사용자 계정 생성)
call moodmend.승지_01_회원관리_회원가입('임성후', '@1223!', '01099991111', '프로명상러', '1993-01-01', 'sh93@google.com', 'User', 'Google');


-- 회원 내역 조회
select * from members;