-- 주문 상세 조회 프로시저

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


-- members_id = 3인 성후라는 일반 유저가 주문의 상세 정보를 조회
call moodmend.민형_03_주문_목록_조회(3);