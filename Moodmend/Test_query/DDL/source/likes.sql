CREATE TABLE likes (
    members_id     BIGINT NOT NULL,
    contents_id   BIGINT NOT NULL,

    -- 복합 기본키: 중복 좋아요 방지
    PRIMARY KEY (members_id, contents_id),

    -- 외래키 설정
    CONSTRAINT fk_likes_members FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_likes_contents FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);