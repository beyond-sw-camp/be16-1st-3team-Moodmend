create table attendance (
  attendance_id bigint primary key auto_increment,
  members_id bigint not null,
  attendance_date datetime not null default current_timestamp,
  foreign key (members_id) references members(members_id),
  unique key unique_members_attendance_date (members_id, attendance_date)
);