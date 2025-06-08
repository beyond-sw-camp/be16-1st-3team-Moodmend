create table playlist_detail (
  pd_id bigint primary key auto_increment,
  playlist_id bigint not null,
  contents_id bigint not null,
  foreign key (playlist_id) references playlist(playlist_id),
  foreign key (contents_id) references contents(contents_id)
);