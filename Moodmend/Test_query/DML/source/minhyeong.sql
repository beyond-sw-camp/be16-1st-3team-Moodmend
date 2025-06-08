DELIMITER $$

CREATE PROCEDURE 민형_01_장바구니_관리 (
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

