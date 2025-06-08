CREATE TABLE playlist (
  playlist_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  title VARCHAR(20) NOT NULL,
  description TEXT,
  is_public BOOLEAN NOT NULL,
  total_play_time TIME NOT NULL DEFAULT '00:00:00',
  playlist_share VARCHAR(255),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);
