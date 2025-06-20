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

