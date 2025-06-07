CREATE TABLE reports (
    members_id     BIGINT NOT NULL,
    contents_id   BIGINT NOT NULL,
    reason        TEXT NOT NULL,
    reported_at   DATETIME NOT NULL,
    status        ENUM('검토 중', '처리완료', '반려') NOT NULL,

    -- 복합 기본 키로 중복 신고 방지
    PRIMARY KEY (members_id, contents_id),

    -- 외래키 제약 (members와 contents 연결)
    CONSTRAINT fk_reports_members FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_reports_contents FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);
