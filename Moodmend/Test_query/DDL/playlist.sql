create table playlist (
  playlist_id bigint primary key auto_increment,
  members_id bigint not null,
  title varchar(20) not null,
  description text,
  is_public boolean not null,
  total_play_time time not null,
  playlist_share VARCHAR(255),
  foreign key (members_id) references members(members_id)
);