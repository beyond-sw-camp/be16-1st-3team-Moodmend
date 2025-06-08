create table emotion (
  emotion_id bigint primary key auto_increment,
  emotion_name varchar(30) not null,
  intensity tinyint unsigned not null
);