DELIMITER $$

CREATE PROCEDURE 지현_01_플레이리스트_기능 (
    IN p_action VARCHAR(20),
    IN p_members_id BIGINT,
    IN p_playlist_id BIGINT,
    IN p_title VARCHAR(50),
    IN p_description TEXT,
    IN p_is_public BOOLEAN,
    IN p_contents_id BIGINT
)
BEGIN
    IF p_action = 'create' THEN
        INSERT INTO playlist (members_id, title, description, is_public)
        VALUES (p_members_id, p_title, p_description, p_is_public);

    ELSEIF p_action = 'add' THEN
        INSERT INTO playlist_detail (playlist_id, contents_id)
        VALUES (p_playlist_id, p_contents_id);

    ELSEIF p_action = 'remove' THEN
        DELETE FROM playlist_detail
        WHERE playlist_id = p_playlist_id AND contents_id = p_contents_id;

    ELSEIF p_action = 'rename' THEN
        UPDATE playlist
        SET title = p_title, description = p_description
        WHERE playlist_id = p_playlist_id AND members_id = p_members_id;

    ELSEIF p_action = 'visibility' THEN
        UPDATE playlist
        SET is_public = p_is_public
        WHERE playlist_id = p_playlist_id AND members_id = p_members_id;

    ELSEIF p_action = 'share' THEN
        UPDATE playlist
        SET playlist_share = UUID()
        WHERE playlist_id = p_playlist_id AND members_id = p_members_id;

    ELSEIF p_action = 'view' THEN
        SELECT 
            p.playlist_id,
            p.title,
            p.description,
            p.is_public,
            p.playlist_share,
            d.pd_id,
            c.contents_id,
            c.name AS contents_name,
            c.duration,
            c.thumbnail
        FROM playlist p
        LEFT JOIN playlist_detail d ON p.playlist_id = d.playlist_id
        LEFT JOIN contents c ON d.contents_id = c.contents_id
        WHERE p.members_id = p_members_id AND (p_playlist_id IS NULL OR p.playlist_id = p_playlist_id);
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 지현_02_포인트_이력_조회 (
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        point_reward_id,
        point_reward,
        reward_date,
        reason
    FROM point_reward
    WHERE members_id = p_members_id
    ORDER BY reward_date DESC;
END $$

DELIMITER ; 

DELIMITER $$

CREATE PROCEDURE 지현_03_재화이력조회관리자 ()
BEGIN
    SELECT 
        m.members_id,
        m.nickname,
        m.point,
        pr.point_reward,
        pr.reward_date,
        pr.reason
    FROM members m
    LEFT JOIN point_reward pr ON m.members_id = pr.members_id
    ORDER BY m.members_id, pr.reward_date DESC;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 지현_04_재화_변경_관리자 (
    IN p_members_id BIGINT,
    IN p_point_change INT,
    IN p_reason VARCHAR(50)
)
BEGIN
    UPDATE members
    SET point = point + p_point_change
    WHERE members_id = p_members_id;

    INSERT INTO point_reward (members_id, point_reward, reason)
    VALUES (p_members_id, p_point_change, p_reason);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 지현_05_감정_다이어리_기록 (
    IN p_members_id BIGINT,
    IN p_emotion_id BIGINT,
    IN p_intensity TINYINT,
    IN p_title VARCHAR(255),
    IN p_contents TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM emotion_diary 
        WHERE members_id = p_members_id AND logged_at = CURRENT_DATE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오늘은 이미 감정 다이어리를 작성하셨습니다.';
    END IF;

    INSERT INTO emotion_diary (
        members_id,
        emotion_id,
        title,
        contents,
        logged_at
    ) VALUES (
        p_members_id,
        p_emotion_id,
        p_title,
        p_contents,
        CURRENT_DATE
    );

    UPDATE emotion
    SET intensity = p_intensity
    WHERE emotion_id = p_emotion_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 지현_06_감정_기반_콘텐츠_추천 (
    IN p_members_id BIGINT
)
BEGIN
    DECLARE v_emotion_id BIGINT;

    SELECT emotion_id INTO v_emotion_id
    FROM emotion_diary
    WHERE members_id = p_members_id
    ORDER BY logged_at DESC
    LIMIT 1;

    SELECT 
        c.contents_id,
        c.name,
        c.description,
        c.thumbnail,
        c.duration,
        c.price,
        c.is_premium
    FROM contents c
    WHERE c.emotion_id = v_emotion_id
    ORDER BY upload_at DESC;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 지현_07_출석_기록 (
    IN p_members_id BIGINT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM attendance 
        WHERE members_id = p_members_id AND attendance_date = CURRENT_DATE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오늘은 이미 출석하셨습니다.';
    END IF;

    INSERT INTO attendance (members_id, attendance_date)
    VALUES (p_members_id, CURRENT_DATE);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 지현_08_출석_조회 (
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        attendance_id,
        attendance_date
    FROM attendance
    WHERE members_id = p_members_id
    ORDER BY attendance_date DESC;
END $$

DELIMITER ;


DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `민형_01_장바구니_관리`(
    IN p_action VARCHAR(20),          -- 'add', 'remove', 'clear'
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE v_is_premium ENUM('일반', '프리미엄');

    IF p_action = 'add' THEN
        -- 프리미엄 여부 확인
        SELECT is_premium INTO v_is_premium
        FROM contents
        WHERE contents_id = p_contents_id;

        -- 일반 콘텐츠일 경우 예외 발생
        IF v_is_premium != '프리미엄' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '무료 콘텐츠는 장바구니에 담을 수 없습니다.';
        END IF;

        -- 장바구니에 추가 (중복 방지)
        INSERT IGNORE INTO cart (members_id, contents_id)
        VALUES (p_members_id, p_contents_id);

    ELSEIF p_action = 'remove' THEN
        DELETE FROM cart
        WHERE members_id = p_members_id AND contents_id = p_contents_id;

    ELSEIF p_action = 'clear' THEN
        DELETE FROM cart
        WHERE members_id = p_members_id;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 민형_02_결제_진행 (
    IN p_members_id BIGINT,
    IN p_payment_method ENUM('신용카드', '휴대폰', '계좌이체')
)
BEGIN
    DECLARE v_total INT UNSIGNED DEFAULT 0;
    DECLARE v_payment_id BIGINT;

    -- 총 금액 계산
    SELECT SUM(c.price) INTO v_total
    FROM cart ca
    JOIN contents c ON ca.contents_id = c.contents_id
    WHERE ca.members_id = p_members_id;

    IF v_total IS NULL OR v_total = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '결제할 콘텐츠가 없습니다.';
    END IF;

    -- payment 기록
    INSERT INTO payment (members_id, items_id, payment_method, total_price)
    VALUES (p_members_id, NULL, p_payment_method, v_total);

    SET v_payment_id = LAST_INSERT_ID();

    -- payment_detail + owned 등록
    INSERT INTO payment_detail (contents_id, payment_id, purchase_type, price)
    SELECT
        c.contents_id, v_payment_id, '콘텐츠 구매', c.price
    FROM cart ca
    JOIN contents c ON ca.contents_id = c.contents_id
    WHERE ca.members_id = p_members_id;

    INSERT INTO owned (members_id, contents_id, payment_detail_id, source_type)
    SELECT 
        p_members_id, c.contents_id, pd.payment_detail_id, '결제'
    FROM payment_detail pd
    JOIN contents c ON pd.contents_id = c.contents_id
    WHERE pd.payment_id = v_payment_id;

    -- 장바구니 비우기
    DELETE FROM cart
    WHERE members_id = p_members_id;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_03_주문_목록_조회 (
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        p.payment_id,
        p.payment_method,
        p.total_price,
        p.payment_date,
        p.refund_require,
        p.refund_date
    FROM payment p
    WHERE p.members_id = p_members_id
    ORDER BY p.payment_date DESC;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_04_주문_상세_조회 (
    IN p_payment_id BIGINT
)
BEGIN
    SELECT 
        pd.payment_detail_id,
        pd.purchase_type,
        pd.price,
        c.name AS contents_name
    FROM payment_detail pd
    LEFT JOIN contents c ON pd.contents_id = c.contents_id
    WHERE pd.payment_id = p_payment_id;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_05_환불_요청 (
    IN p_payment_id BIGINT
)
BEGIN
    UPDATE payment
    SET refund_require = TRUE
    WHERE payment_id = p_payment_id AND refund_require = FALSE;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_06_환불_조회_관리자()
BEGIN
    SELECT 
        p.payment_id,
        m.nickname,
        p.total_price,
        p.payment_date,
        p.refund_require,
        p.refund_date
    FROM payment p
    JOIN members m ON p.members_id = m.members_id
    WHERE p.refund_require = TRUE
    ORDER BY p.payment_date DESC;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_07_환불_처리_관리자 (
    IN p_payment_id BIGINT,
    IN p_action ENUM('승인', '거절')
)
BEGIN
    IF p_action = '승인' THEN
        UPDATE payment
        SET refund_date = CURRENT_TIMESTAMP,
            refund_require = FALSE
        WHERE payment_id = p_payment_id;

        -- 필요 시: 포인트 복구, owned 삭제 등 추가 가능

    ELSEIF p_action = '거절' THEN
        UPDATE payment
        SET refund_require = FALSE
        WHERE payment_id = p_payment_id;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 민형_08_클래스_개설_및_상태설정 (
    IN p_members_id BIGINT,
    IN p_title VARCHAR(50),
    IN p_category VARCHAR(20),
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_limit INT
)
BEGIN
    DECLARE v_now DATETIME;
    DECLARE v_status ENUM('개강전','모집중','정원초과','모집완료');

    SET v_now = NOW();

    IF p_start_time > v_now THEN
        SET v_status = '모집중';
    ELSE
        SET v_status = '개강전';
    END IF;

    INSERT INTO meditation_class (
        members_id, title, category,
        start_time, end_time, `limit`, status
    ) VALUES (
        p_members_id, p_title, p_category,
        p_start_time, p_end_time, p_limit, v_status
    );
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_09_클래스_조회()
BEGIN
    SELECT 
        mc.meditation_class_id,
        mc.title,
        mc.category,
        mc.start_time,
        mc.end_time,
        mc.limit,
        mc.status,
        m.nickname AS teacher
    FROM meditation_class mc
    JOIN members m ON mc.members_id = m.members_id
    ORDER BY mc.start_time DESC;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_10_클래스_신청 (
    IN p_members_id BIGINT,
    IN p_meditation_class_id BIGINT
)
BEGIN
    DECLARE v_count INT;

    -- 현재 예약 인원 수 확인
    SELECT COUNT(*) INTO v_count
    FROM class_reservation
    WHERE meditation_class_id = p_meditation_class_id;

    -- 중복 예약 여부 확인
    IF EXISTS (
        SELECT 1 FROM class_reservation
        WHERE members_id = p_members_id
          AND meditation_class_id = p_meditation_class_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 해당 클래스를 신청하셨습니다.';
    END IF;

    -- 정원 초과 여부 확인 (limit 예약어 처리)
    IF v_count >= (
        SELECT `limit` FROM meditation_class
        WHERE meditation_class_id = p_meditation_class_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '정원이 초과되었습니다.';
    END IF;

    -- 예약 등록
    INSERT INTO class_reservation (meditation_class_id, members_id)
    VALUES (p_meditation_class_id, p_members_id);
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_11_클래스_후기_등록 (
    IN p_class_reservation_id BIGINT,
    IN p_meditation_class_id BIGINT,
    IN p_rating INT,
    IN p_comment VARCHAR(255)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM class_feedback
        WHERE class_reservation_id = p_class_reservation_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 후기를 작성하셨습니다.';
    END IF;

    INSERT INTO class_feedback (
        meditation_class_id,
        class_reservation_id,
        comment,
        rating
    ) VALUES (
        p_meditation_class_id,
        p_class_reservation_id,
        p_comment,
        p_rating
    );
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE 민형_12_클래스_후기_조회 (
    IN p_meditation_class_id BIGINT
)
BEGIN
    SELECT 
        cf.comment,
        cf.rating,
        cf.created_at,
        m.nickname
    FROM class_feedback cf
    JOIN class_reservation cr ON cf.class_reservation_id = cr.class_reservation_id
    JOIN members m ON cr.members_id = m.members_id
    WHERE cf.meditation_class_id = p_meditation_class_id
    ORDER BY cf.created_at DESC;
END $$

DELIMITER ;


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
  DECLARE v_member_count INT;
  DECLARE v_initial_point INT DEFAULT 0;

  START TRANSACTION;

  -- 중복 확인
  IF EXISTS (
    SELECT 1 FROM members 
    WHERE phone_number = p_phone_number OR email = p_email
  ) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '이미 등록된 이메일 또는 전화번호입니다.';
  ELSE
    -- 회원 수 확인
    SELECT COUNT(*) INTO v_member_count FROM members;
    IF v_member_count = 0 THEN
      SET v_initial_point = 100;
    END IF;

    -- 회원 등록
    INSERT INTO members (
      name, password, phone_number, nickname, birthday, email,
      role, signup_type, created_at, updated_at, point
    )
    VALUES (
      p_name, p_password, p_phone_number, p_nickname, p_birthday, p_email,
      p_role, p_signup_type, NOW(), NOW(), v_initial_point
    );

    SET v_members_id = LAST_INSERT_ID();

    -- 기본 아바타 생성
    INSERT INTO avatar (
      members_id,
      avatar_name,
      is_default
    ) VALUES (
      v_members_id,
      '기본 아바타',
      TRUE
    );

    -- 최초 가입자라면 포인트 이력 남기기 (선택사항)
    IF v_initial_point = 100 THEN
      INSERT INTO point_reward (members_id, point_reward, reason)
      VALUES (v_members_id, 100, '최초 가입자 보상');
    END IF;
  END IF;

  COMMIT;
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
  WHERE post_id = p_post_id;
END;
//
DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_01_콘텐츠_등록(
    IN p_members_id BIGINT,
    IN p_emotion_id BIGINT,
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_thumbnail TEXT,
    IN p_duration INT,
    IN p_is_premium ENUM('일반', '프리미엄'),
    IN p_video_url TEXT,
    IN p_price INT UNSIGNED
)
BEGIN
    IF p_is_premium = '프리미엄' AND p_price = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '프리미엄 콘텐츠는 가격이 0원이 될 수 없습니다.';
    END IF;

    IF p_is_premium = '일반' AND p_price != 0 THEN
        SET p_price = 0;
    END IF;

    INSERT INTO contents (
        members_id,
        emotion_id,
        name,
        description,
        thumbnail,
        duration,
        is_premium,
        views,
        price,
        video_url
    ) VALUES (
        p_members_id,
        p_emotion_id,
        p_name,
        p_description,
        p_thumbnail,
        p_duration,
        p_is_premium,
        0,
        p_price,
        p_video_url
    );
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_02_콘텐츠_수정(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT,
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_thumbnail TEXT,
    IN p_duration INT,
    IN p_is_premium ENUM('일반', '프리미엄'),
    IN p_video_url TEXT,
    IN p_price INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM contents
        WHERE contents_id = p_contents_id AND members_id = p_members_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '해당 콘텐츠에 대한 수정 권한이 없습니다.';
    END IF;

    IF p_is_premium = '프리미엄' AND p_price = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '프리미엄 콘텐츠는 가격이 0원이 될 수 없습니다.';
    END IF;

    IF p_is_premium = '일반' THEN
        SET p_price = 0;
    END IF;

    UPDATE contents
    SET
        name = p_name,
        description = p_description,
        thumbnail = p_thumbnail,
        duration = p_duration,
        is_premium = p_is_premium,
        price = p_price,
        video_url = p_video_url,
        updated_at = CURRENT_TIMESTAMP
    WHERE contents_id = p_contents_id AND members_id = p_members_id;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_03_콘텐츠_삭제(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE v_role ENUM('Admin', 'Teacher', 'User');

    SELECT role INTO v_role
    FROM members
    WHERE members_id = p_members_id;

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '존재하지 않는 사용자입니다.';
    END IF;

    IF v_role != 'Admin' AND NOT EXISTS (
        SELECT 1 FROM contents 
        WHERE contents_id = p_contents_id AND members_id = p_members_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '해당 콘텐츠에 대한 삭제 권한이 없습니다.';
    END IF;

    DELETE FROM contents 
    WHERE contents_id = p_contents_id;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_04_콘텐츠_조회(
    IN p_contents_id BIGINT
)
BEGIN
    IF p_contents_id IS NULL THEN
        SELECT 
            c.contents_id,
            c.name AS title,
            c.description,
            c.thumbnail,
            c.duration,
            c.is_premium,
            c.price,
            c.views,
            c.upload_at,
            m.nickname AS creator_nickname,
            e.emotion_name
        FROM contents c
        JOIN members m ON c.members_id = m.members_id
        JOIN emotion e ON c.emotion_id = e.emotion_id
        ORDER BY c.upload_at DESC;
    ELSE
        SELECT 
            c.contents_id,
            c.name AS title,
            c.description,
            c.thumbnail,
            c.duration,
            c.is_premium,
            c.price,
            c.views,
            c.upload_at,
            m.nickname AS creator_nickname,
            e.emotion_name
        FROM contents c
        JOIN members m ON c.members_id = m.members_id
        JOIN emotion e ON c.emotion_id = e.emotion_id
        WHERE c.contents_id = p_contents_id;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_05_좋아요_등록(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '좋아요 등록 중 오류 발생(롤백 수행됨)';
    END;

    START TRANSACTION;

    -- 중복 좋아요 방지: 트랜잭션 내에서도 확인
    IF EXISTS (
        SELECT 1 FROM likes
        WHERE members_id = p_members_id AND contents_id = p_contents_id
        FOR UPDATE
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 좋아요를 누르셨습니다.';
    END IF;

    INSERT INTO likes (members_id, contents_id)
    VALUES (p_members_id, p_contents_id);

    COMMIT;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_06_좋아요_취소(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '좋아요 취소 중 오류 발생(롤백 수행됨)';
    END;

    START TRANSACTION;

    -- 좋아요 눌렀는지 확인 및 잠금
    IF NOT EXISTS (
        SELECT 1 FROM likes
        WHERE members_id = p_members_id AND contents_id = p_contents_id
        FOR UPDATE
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '좋아요를 누른 기록이 없습니다.';
    END IF;

    DELETE FROM likes
    WHERE members_id = p_members_id AND contents_id = p_contents_id;

    COMMIT;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_07_콘텐츠_정렬조회(
    IN p_sort_column VARCHAR(20),
    IN p_sort_order VARCHAR(4)
)
BEGIN
    DECLARE v_order_column VARCHAR(30);

    IF p_sort_column = 'likes' THEN
        SET v_order_column = 'like_count';
    ELSE
        SET v_order_column = 'c.views';
    END IF;

    SET @sql = CONCAT(
        'SELECT ',
            'c.contents_id, c.name AS title, c.description, c.thumbnail, ',
            'c.duration, c.is_premium, c.price, c.views, c.upload_at, ',
            'm.nickname AS creator_nickname, ',
            'e.emotion_name, ',
            'COUNT(l.members_id) AS like_count ',
        'FROM contents c ',
        'JOIN members m ON c.members_id = m.members_id ',
        'JOIN emotion e ON c.emotion_id = e.emotion_id ',
        'LEFT JOIN likes l ON c.contents_id = l.contents_id ',
        'GROUP BY c.contents_id ',
        'ORDER BY ', v_order_column, ' ', p_sort_order
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_08_콘텐츠_조회_다운로드(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE v_views BIGINT;
    DECLARE v_likes BIGINT;

    SELECT views INTO v_views
    FROM contents
    WHERE contents_id = p_contents_id;

    SELECT COUNT(*) INTO v_likes
    FROM likes
    WHERE contents_id = p_contents_id;

    INSERT INTO download (members_id, contents_id)
    VALUES (p_members_id, p_contents_id);

    SELECT 
        p_contents_id AS contents_id,
        v_views AS current_views,
        v_likes AS current_likes,
        '다운로드 완료' AS download_status;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_09_카테고리별_콘텐츠_조회(
    IN p_category VARCHAR(20)
)
BEGIN
    SELECT 
        c.contents_id,
        c.name,
        c.description,
        c.thumbnail,
        c.duration,
        c.price,
        c.is_premium,
        c.upload_at,
        e.emotion_name,
        m.nickname AS creator
    FROM contents c
    JOIN emotion e ON c.emotion_id = e.emotion_id
    JOIN members m ON c.members_id = m.members_id
    WHERE e.emotion_name = p_category;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_10_보유_콘텐츠_아이템_조회(
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        o.owned_id,
        o.contents_id,
        c.name AS contents_name,
        NULL AS items_name,
        o.acquired_at,
        o.source_type,
        o.is_equipped
    FROM owned o
    JOIN contents c ON o.contents_id = c.contents_id
    WHERE o.members_id = p_members_id AND o.contents_id IS NOT NULL

    UNION ALL

    SELECT 
        o.owned_id,
        NULL,
        NULL,
        i.items_name,
        o.acquired_at,
        o.source_type,
        o.is_equipped
    FROM owned o
    JOIN items i ON o.items_id = i.items_id
    WHERE o.members_id = p_members_id AND o.items_id IS NOT NULL;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_11_콘텐츠_신고 (
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT,
    IN p_reason TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM reports
        WHERE members_id = p_members_id AND contents_id = p_contents_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 신고한 콘텐츠입니다.';
    END IF;

    INSERT INTO reports (members_id, contents_id, reason, reported_at, status)
    VALUES (p_members_id, p_contents_id, p_reason, NOW(), '검토 중');
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_12_신고_조회_유저 (
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        r.contents_id,
        c.name AS contents_name,
        r.reason,
        r.reported_at,
        r.status
    FROM reports r
    JOIN contents c ON r.contents_id = c.contents_id
    WHERE r.members_id = p_members_id
    ORDER BY r.reported_at DESC;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_13_신고_조회_관리자 ()
BEGIN
    SELECT 
        r.members_id,
        m.nickname AS 신고자,
        r.contents_id,
        c.name AS contents_name,
        r.reason,
        r.reported_at,
        r.status
    FROM reports r
    JOIN contents c ON r.contents_id = c.contents_id
    JOIN members m ON r.members_id = m.members_id
    ORDER BY r.reported_at DESC;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_14_장바구니_아이템추가 (
    IN p_members_id BIGINT,
    IN p_items_id BIGINT
)
BEGIN
    START TRANSACTION;
    IF EXISTS (
        SELECT 1 FROM owned WHERE members_id = p_members_id AND items_id = p_items_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 소유한 아이템은 장바구니에 담을 수 없습니다.';
    ELSE
        INSERT INTO cart (members_id, items_id, total)
        VALUES (p_members_id, p_items_id, (SELECT items_price FROM items WHERE items_id = p_items_id));
    END IF;
    COMMIT;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_15_아이템구매 (
    IN p_members_id BIGINT,
    IN p_items_id BIGINT
)
BEGIN
    DECLARE v_price INT;
    DECLARE v_point INT;

    START TRANSACTION;

    -- 1. 중복 소유 방지
    IF EXISTS (
        SELECT 1
        FROM owned
        WHERE members_id = p_members_id AND items_id = p_items_id
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 소유한 아이템입니다. 중복 구매할 수 없습니다.';
    END IF;

    -- 2. 가격 및 포인트 확인
    SELECT items_price INTO v_price FROM items WHERE items_id = p_items_id;
    SELECT point INTO v_point FROM members WHERE members_id = p_members_id;

    -- 3. 포인트 부족 시 에러
    IF v_point < v_price THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '포인트가 부족합니다.';
    END IF;

    -- 4. 포인트 차감
    UPDATE members SET point = point - v_price WHERE members_id = p_members_id;

    -- 5. 결제 내역 추가
    INSERT INTO payment (members_id, items_id, payment_method, total_price)
    VALUES (p_members_id, p_items_id, '아이템', v_price);
    SET @payment_id = LAST_INSERT_ID();

    -- 6. 결제 상세 추가
    INSERT INTO payment_detail (payment_id, items_id, purchase_type, price)
    VALUES (@payment_id, p_items_id, '아이템 구매', v_price);
    SET @payment_detail_id = LAST_INSERT_ID();

    -- 7. 소유 테이블 추가
    INSERT INTO owned (members_id, items_id, payment_detail_id)
    VALUES (p_members_id, p_items_id, @payment_detail_id);

    COMMIT;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_16_보유내역조회 (
    IN p_members_id BIGINT
)
BEGIN
    SELECT o.items_id, i.items_name, pd.price, p.payment_date
    FROM owned o
    JOIN items i ON o.items_id = i.items_id
    JOIN payment_detail pd ON o.payment_detail_id = pd.payment_detail_id
    JOIN payment p ON pd.payment_id = p.payment_id
    WHERE o.members_id = p_members_id;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE 성후_17_아바타_조회_수정_등록 (
    IN p_members_id BIGINT,
    IN p_avatar_name VARCHAR(50),
    IN p_is_default BOOLEAN
)
BEGIN
    DECLARE v_exists INT;

    START TRANSACTION;

    -- 존재 여부 확인
    SELECT COUNT(*) INTO v_exists
    FROM avatar
    WHERE members_id = p_members_id;

    -- 수정 또는 등록
    IF v_exists > 0 THEN
        UPDATE avatar
        SET avatar_name = p_avatar_name,
            is_default = p_is_default
        WHERE members_id = p_members_id;
    ELSE
        INSERT INTO avatar (members_id, avatar_name, is_default)
        VALUES (p_members_id, p_avatar_name, p_is_default);
    END IF;

    -- 조회 결과 반환
    SELECT *
    FROM avatar
    WHERE members_id = p_members_id;

    COMMIT;
END$$

DELIMITER ;
