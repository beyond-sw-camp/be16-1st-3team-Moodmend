-- 로그인 기능을 구현하는 프로시저

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


-- 로그인 프로시저 호출 예시 (관리자 계정으로 로그인)
call moodmend.승지_02_회원관리_로그인('admin@mm.com', '@1234!');