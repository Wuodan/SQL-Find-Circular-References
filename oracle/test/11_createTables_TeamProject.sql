whenever sqlerror exit sql.sqlcode

create table TaskType(
    TaskTypeID number generated always as identity primary key,
    TypeName varchar2(255) not null
);

create table Users(
    UsersID number generated always as identity primary key,
    UsersName varchar2(255) not null
);

create table ProjectRole(
    ProjectRoleID number generated always as identity primary key,
    ProjectRoleName varchar2(255) not null
);

create table Project(
    ProjectID number generated always as identity primary key,
    ProjectName varchar2(255) not null,
    Description varchar2(255)
);

create table Task(
    TaskID number generated always as identity primary key,
    TypeID number not null references TaskType(TaskTypeID),
    ProjectID number not null references Project(ProjectID),
    TaskName varchar2(255) not null
);

create table ProjectTeam(
    ProjectTeamID number generated always as identity primary key,
    UsersID number not null references Users(UsersID),
    ProjectID number not null references Project(ProjectID)
);

create table ProjectAssignment(
    ProjectAssignmentID number generated always as identity primary key,
    ProjectTeamID number not null references ProjectTeam(ProjectTeamID),
    TaskID number not null references Task(TaskID),
    ProjectRoleID number not null references ProjectRole(ProjectRoleID)
);

exit
