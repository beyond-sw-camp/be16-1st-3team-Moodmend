DELIMITER $$

CREATE PROCEDURE 민형_02_결제_진행 (
    IN p_members_id BIGINT,
    IN p_payment_method ENUM('신용카드', '휴대폰', '계좌이체')
)
BEGIN
    DECLARE v_total INT UNSIGNED;
    DECLARE v_payment_id BIGINT;
    DECLARE v_cart_contents_id BIGINT;
    DECLARE v_cart_items_id BIGINT;

    -- [1] 유효한 결제 대상이 하나만 존재하는지 확인
    IF NOT EXISTS (
        SELECT 1 FROM cart
        WHERE members_id = p_members_id
          AND ((contents_id IS NOT NULL AND items_id IS NULL) OR (contents_id IS NULL AND items_id IS NOT NULL))
          AND total IS NOT NULL AND total > 0
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '결제할 항목이 없습니다.';
    END IF;

    -- [2] 유효한 데이터 1개를 가져옴 (정확한 조건 포함)
    SELECT contents_id, items_id, total
    INTO v_cart_contents_id, v_cart_items_id, v_total
    FROM cart
    WHERE members_id = p_members_id
      AND ((contents_id IS NOT NULL AND items_id IS NULL) OR (contents_id IS NULL AND items_id IS NOT NULL))
      AND total IS NOT NULL AND total > 0
    LIMIT 1;

    -- [3] payment 테이블 기록
    INSERT INTO payment (
        members_id, items_id, payment_method, total_price
    )
    VALUES (
        p_members_id, v_cart_items_id, p_payment_method, v_total
    );

    SET v_payment_id = LAST_INSERT_ID();

    -- [4] 콘텐츠 결제 처리
    IF v_cart_contents_id IS NOT NULL THEN
        INSERT INTO payment_detail (
            contents_id, payment_id, purchase_type, price
        )
        VALUES (
            v_cart_contents_id, v_payment_id, '콘텐츠 구매', v_total
        );

        INSERT INTO owned (
            members_id, contents_id, payment_detail_id, source_type
        )
        VALUES (
            p_members_id, v_cart_contents_id, LAST_INSERT_ID(), '결제'
        );
    END IF;

    -- [5] 아이템 결제 처리
    IF v_cart_items_id IS NOT NULL THEN
        INSERT INTO payment_detail (
            items_id, payment_id, purchase_type, price
        )
        VALUES (
            v_cart_items_id, v_payment_id, '아이템 구매', v_total
        );

        INSERT INTO owned (
            members_id, items_id, payment_detail_id, source_type
        )
        VALUES (
            p_members_id, v_cart_items_id, LAST_INSERT_ID(), '결제'
        );
    END IF;

    -- [6] 장바구니 비우기
    DELETE FROM cart 
    WHERE members_id = p_members_id;
END $$

DELIMITER ;


-- 성후라는 일반 유저가 장바구니에 담긴 콘텐츠를 신용카드로 결제
call moodmend.민형_02_결제_진행(3, '신용카드');

-- 결제 결과 확인
select * from payment;
select * from payment_detail;
select * from owned;