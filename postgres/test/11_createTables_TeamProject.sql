drop table if exists projectassignment cascade;
drop table if exists projectteam cascade;
drop table if exists task cascade;
drop table if exists project cascade;
drop table if exists projectrole cascade;
drop table if exists users cascade;
drop table if exists tasktype cascade;

create table tasktype(
    tasktypeid integer generated always as identity primary key,
    typename varchar(255) not null
);

create table users(
    usersid integer generated always as identity primary key,
    usersname varchar(255) not null
);

create table projectrole(
    projectroleid integer generated always as identity primary key,
    projectrolename varchar(255) not null
);

create table project(
    projectid integer generated always as identity primary key,
    projectname varchar(255) not null,
    description varchar(255)
);

create table task(
    taskid integer generated always as identity primary key,
    typeid integer not null references tasktype(tasktypeid),
    projectid integer not null references project(projectid),
    taskname varchar(255) not null
);

create table projectteam(
    projectteamid integer generated always as identity primary key,
    usersid integer not null references users(usersid),
    projectid integer not null references project(projectid)
);

create table projectassignment(
    projectassignmentid integer generated always as identity primary key,
    projectteamid integer not null references projectteam(projectteamid),
    taskid integer not null references task(taskid),
    projectroleid integer not null references projectrole(projectroleid)
);
