create table point_reward (
  point_reward_id bigint primary key auto_increment,
  members_id bigint not null,
  point_reward bigint not null default 0,
  reward_date datetime not null default current_timestamp,
  reason varchar(20) not null,
  foreign key (members_id) references members(members_id),
  unique key unique_members_reward_date (members_id, reward_date)
);