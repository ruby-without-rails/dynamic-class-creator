create table configurations(
	key varchar(255) not null,
	value varchar(255) not null
);

create unique index configurations_key_uindex
	on configurations (key);

alter table configurations
	add constraint configurations_pk
		primary key (key);

