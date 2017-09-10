use sql_circular_references
go

/*
CREATE table tblCustomer
	(CustNo		integer identity(1,1)	primary key,
	 CustName	varchar(50) not null,
	 CustDiscount	decimal(5,3) null,
	 SiteNo		integer null,
	 CustWebSite	varchar(100) null )
GO

CREATE table tblCustLocation
	(SiteNo		integer identity(1,1)	primary key,
	 CustNo		integer not null,
	 SiteName	varchar(40) not null,
	 SiteAddrLine1	varchar(80) not null,
	 SiteAddrLine2	varchar(80) null,
	 SiteCity	varchar(40) not null,
	 SiteState	varchar(40) null,
	 SitePostalCode	char(10) null,
	 SiteCountry	varchar(30) null,
	 SiteType	varchar(20) null,
	 ContactNo	integer null)
GO

CREATE table tblCustContact
	(ContactNo	integer identity(1,1)	primary key,
	 SiteNo		integer not null,
	 CustNo		integer not null,
	 FirstName	varchar(20) not null,
	 LastName	varchar(20) null,
	 CountryCode	char(3) null,
	 ContactPhone	varchar(15) null,
	 ContactExt	char(4) null,
	 ContactEmail	varchar(50) null   )
GO

ALTER table tblCustLocation
 ADD constraint fk_CustLoc2Cust foreign key (CustNo) references tblCustomer(CustNo)
GO
ALTER table tblCustomer
 ADD constraint fk_Cust2CustLoc foreign key (SiteNo) references tblCustLocation(SiteNo)
GO

ALTER table tblCustContact
 ADD constraint fk_CustContact2CustLoc foreign key (SiteNo) references tblCustLocation(SiteNo)
GO
ALTER table tblCustLocation
 ADD constraint fk_CustLoc2CustConstact foreign key (ContactNo) references tblCustContact(ContactNo)
GO
*/