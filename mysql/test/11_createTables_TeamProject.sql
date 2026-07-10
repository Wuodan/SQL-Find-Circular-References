drop table if exists projectassignment;
drop table if exists projectteam;
drop table if exists task;
drop table if exists project;
drop table if exists projectrole;
drop table if exists users;
drop table if exists tasktype;

create table tasktype(
    tasktypeid int not null auto_increment primary key,
    typename varchar(255) not null
);

create table users(
    usersid int not null auto_increment primary key,
    usersname varchar(255) not null
);

create table projectrole(
    projectroleid int not null auto_increment primary key,
    projectrolename varchar(255) not null
);

create table project(
    projectid int not null auto_increment primary key,
    projectname varchar(255) not null,
    description varchar(255) null
);

create table task(
    taskid int not null auto_increment primary key,
    typeid int not null,
    projectid int not null,
    taskname varchar(255) not null,
    constraint fk_task_tasktype foreign key (typeid) references tasktype(tasktypeid),
    constraint fk_task_project foreign key (projectid) references project(projectid)
);

create table projectteam(
    projectteamid int not null auto_increment primary key,
    usersid int not null,
    projectid int not null,
    constraint fk_projectteam_users foreign key (usersid) references users(usersid),
    constraint fk_projectteam_project foreign key (projectid) references project(projectid)
);

create table projectassignment(
    projectassignmentid int not null auto_increment primary key,
    projectteamid int not null,
    taskid int not null,
    projectroleid int not null,
    constraint fk_projectassignment_projectteam foreign key (projectteamid) references projectteam(projectteamid),
    constraint fk_projectassignment_task foreign key (taskid) references task(taskid),
    constraint fk_projectassignment_projectrole foreign key (projectroleid) references projectrole(projectroleid)
);
