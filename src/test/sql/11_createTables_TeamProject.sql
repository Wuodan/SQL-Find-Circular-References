use sql_circular_references
go

if object_id('ProjectAssignment', 'U') is not null
	drop table ProjectAssignment
if object_id('ProjectTeam', 'U') is not null
	drop table ProjectTeam
if object_id('Task', 'U') is not null
	drop table Task
if object_id('Project', 'U') is not null
	drop table Project
if object_id('Role', 'U') is not null
	drop table Role
if object_id('Users', 'U') is not null
	drop table Users
if object_id('TaskType', 'U') is not null
	drop table TaskType
go

create table TaskType(
	TaskTypeID int identity not null primary key,
	TypeName varchar(255) not null
)
go

create table Users(
	UsersID int identity not null primary key,
	UsersName varchar(255) not null
)
go

create table ProjectRole(
	ProjectRoleID int identity not null primary key,
	ProjectRoleName varchar(255) not null
)
go

create table Project(
	ProjectID int identity not null primary key,
	ProjectName varchar(255) not null,
	Description varchar(255) null
)
go

create table Task(
	TaskID int identity not null primary key,
	TypeID int not null foreign key references TaskType(TaskTypeID),
	ProjectID int not null foreign key references Project(ProjectID),
	TaskName varchar(255) not null
)
go

create table ProjectTeam(
	ProjectTeamID int identity not null primary key,
	UsersID int not null foreign key references Users(UsersID),
	ProjectID int not null foreign key references Project(ProjectID)
)
go

create table ProjectAssignment(
	ProjectAssignmentID int identity not null primary key,
	ProjectTeamID int not null foreign key references ProjectTeam(ProjectTeamID),
	TaskID int not null foreign key references Task(TaskID),
	ProjectRoleID int not null foreign key references ProjectRole(ProjectRoleID)
)
go
