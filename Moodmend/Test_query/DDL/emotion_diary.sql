create table emotion_diary (
  emotion_diary_id bigint primary key auto_increment,
  members_id bigint,
  emotion_id bigint not null,
  title varchar(255) not null,
  contents TEXT not null,
  logged_at datetime not null default current_timestamp,
  foreign key (members_id) references members(members_id),
  foreign key (emotion_id) references emotion(emotion_id),
  unique key unique_members_logged_at (members_id, logged_at)
);