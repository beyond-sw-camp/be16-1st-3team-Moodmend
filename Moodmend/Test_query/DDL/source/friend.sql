CREATE TABLE friend (
  friend_id BIGINT NOT NULL AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  status ENUM('friend', 'ignore') NOT NULL,
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  nickname VARCHAR(30) NOT NULL,
  PRIMARY KEY (friend_id),
  FOREIGN KEY (members_id) REFERENCES member(members_id)
);