-- 콘텐츠 등록 프로시저

--먼저 콘텐츠 등록에 필요한 감정 카테고리 (emotion 등록 필요), 감정 카테고리는 이후 나올 감정 다이어리에서도 사용됨
insert into emotion(emotion_name, intensity) values ('행복', 1);
insert into emotion(emotion_name, intensity) values ('행복', 2);
insert into emotion(emotion_name, intensity) values ('행복', 3);
insert into emotion(emotion_name, intensity) values ('행복', 4);
insert into emotion(emotion_name, intensity) values ('행복', 5);

insert into emotion(emotion_name, intensity) values ('슬픔', 1);
insert into emotion(emotion_name, intensity) values ('슬픔', 2);
insert into emotion(emotion_name, intensity) values ('슬픔', 3);
insert into emotion(emotion_name, intensity) values ('슬픔', 4);
insert into emotion(emotion_name, intensity) values ('슬픔', 5);


-- 이후 콘텐츠 등록 프로시저 실행

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


-- 콘텐츠 등록 (무료)
call moodmend.성후_01_콘텐츠_등록(2, 1, '홍길동의 명상', '홍길동 티처의 명상입니다.', 'url.com', 50, '일반', 'url.com', 0);


-- 콘텐츠 등록 (프리미엄)
call moodmend.성후_01_콘텐츠_등록(2, 6, '슬플때 듣는 명상', '홍길동의 슬플 때 듣는 명상', 'url.com', 90, '프리미엄', 'url.com', 10000);

-- 콘텐츠 조회
select * from contents;