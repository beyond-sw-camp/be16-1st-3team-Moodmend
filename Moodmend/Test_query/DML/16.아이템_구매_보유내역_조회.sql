-- 아이템 구매 프로시저

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


-- 아이템 구매 프로시저 호출 예시
call moodmend.성후_15_아이템구매(3, 2);


-- 아이템 구매 후 소유 내역 조회
SELECT * FROM moodmend.owned;

-- 또는
call moodmend.성후_16_보유내역조회(3);
