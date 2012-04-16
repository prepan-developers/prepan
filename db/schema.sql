drop table if exists sessions;
create table sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

drop table if exists user;
create table user (
  id           bigint(20) unsigned not null,
  name         varchar(255) not null default '',
  url          varchar(255) not null default '',
  description  varchar(255) not null default '',
  pause_id     varchar(255) not null default '',
  bitbucket    varchar(255) not null default '',
  info         blob not null,
  session_id   varchar(255) not null default '',
  unread_count int(10) unsigned not null default 0,
  unread_from  timestamp not null default '0000-00-00 00:00:00',
  created      timestamp not null default '0000-00-00 00:00:00',
  modified     timestamp not null default current_timestamp on update current_timestamp,

  primary key (id),
  key (session_id),
  unique (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists oauth;
create table oauth (
  id                  bigint(20) unsigned not null,
  external_user_id    bigint(20) not null,
  service             enum('twitter', 'github', 'facebook') not null default 'twitter',
  user_id             bigint(20) unsigned not null default 0,
  info                blob not null,
  access_token        varchar(255) not null default '',
  access_token_secret varchar(255) not null default '',
  created             timestamp not null default '0000-00-00 00:00:00',
  modified            timestamp not null default current_timestamp on update current_timestamp,

  primary key (id),
  key (user_id),
  key (external_user_id, service),
  unique (external_user_id, service)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists module;
create table module (
  id            bigint(20) unsigned not null,
  user_id       bigint(20) unsigned not null,
  name          varchar(255) not null default '',
  url           varchar(255) not null default '',
  summary       varchar(255) not null default '',
  synopsis      text not null default '',
  description   text not null default '',
  status        enum('in review', 'shipped', 'finished') not null default 'in review',
  review_count  int(10) unsigned not null default 0,
  created       timestamp not null default '0000-00-00 00:00:00',
  modified      timestamp not null default current_timestamp on update current_timestamp,

  primary key (id),
  key (user_id, modified),
  key (status, created)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists review;
create table review (
  id         bigint(20) unsigned not null,
  module_id  bigint(20) unsigned not null,
  user_id    bigint(20) unsigned not null,
  comment    text not null default '',
  anonymouse boolean not null default 0,
  created    timestamp not null default '0000-00-00 00:00:00',
  modified   timestamp not null default current_timestamp on update current_timestamp,

  primary key (id),
  key (module_id, created),
  key (user_id, modified)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists vote;
create table vote (
  id         bigint(20) unsigned not null,
  module_id  bigint(20) unsigned not null,
  user_id    bigint(20) unsigned not null,
  created    timestamp not null default '0000-00-00 00:00:00',
  modified   timestamp not null default current_timestamp on update current_timestamp,

  primary key (id),
  key (module_id, created)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
