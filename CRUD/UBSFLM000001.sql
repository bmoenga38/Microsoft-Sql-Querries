drop TABLE UBSADM10005
go
CREATE TABLE UBSADM10005(
	ResponseID int IDENTITY(1,1) NOT NULL,
	ResponseCode nvarchar(50) NULL,
	ResponseDescription nvarchar(max) NULL)
go
insert into UBSADM10005 (ResponseCode,ResponseDescription) values('000','Operation Succeeded'),('001','Data Already Exists'),('005','Operation Failed. Check System Logs for More Information')
go
drop procedure GlobalGetResponseDescription
go
create procedure [dbo].[GlobalGetResponseDescription](@responsecode nvarchar(50),@responsedescription nvarchar(max) output)
as
begin
	select @responsedescription=ResponseDescription from UBSADM10005 WITH (nolock) where ResponseCode=@responsecode
	if(@responsedescription is null)
	begin
		set @responsedescription = 'Uknown Response'
	end
end
go
--table
drop table UBSFLM000001
GO
CREATE TABLE UBSFLM000001 
(FileTypeID int identity(1,1) primary key,
 FileTypeCode varchar(max),
 FileTypeName varchar(max),
 InterfaceDateTime datetime,
 DatabaseDateTime datetime,
 UserName varchar(max),
 IpAddress varchar(max),
 TransactionCode varchar(max),
 Deleted bit,
 DeletedBy varchar(max),
 DateDeleted date,
 Valid bit,
 CompanyId varchar(max),
 BranchID varchar(max))
GO
--procedure
drop procedure CreateFileTypes
go
create procedure CreateFileTypes(
 @FileTypeID int,
 @FileTypeCode varchar(max),
 @FileTypeName varchar(max),
 @InterfaceDateTime datetime,
 @UserName varchar(max),
 @IpAddress varchar(max),
 @TransactionCode varchar(max),
 @Valid bit,
 @IsUpdate bit,
 @CompanyId varchar(max),
 @BranchID varchar(max)
)as
begin

	declare  @Deleted bit,@DeletedBy varchar(max),@DateDeleted date
	declare @ResponseTable table(ResponseCode varchar(max),ResponseDescription varchar(max))
	declare @ResponseCode varchar(max),@ResponseDescription varchar(max), @DatabaseDateTime datetime = getdate()
    BEGIN TRY
		if(@IsUpdate = 1)
		begin
			if(@Valid = 0)
			begin
				set @Deleted = 1
				set @DeletedBy = @UserName
				set @DateDeleted = @InterfaceDateTime
			end
			update UBSFLM000001 set
			FileTypeCode = @FileTypeCode,
			FileTypeName = @FileTypeName,
			UserName =@UserName,
			IpAddress =@IpAddress,
			TransactionCode =@TransactionCode,
			Deleted =@Deleted,
			DeletedBy =@DeletedBy,
			DateDeleted =@DateDeleted,
			Valid =@Valid where FileTypeID = @FileTypeID  and CompanyId = @CompanyId and BranchID = @BranchID
			set  @ResponseCode  ='000'
		end
		else
		begin
			if not exists(select 1 from UBSFLM000001 where Valid =1 and CompanyId = @CompanyId and (FileTypeCode =@FileTypeCode or FileTypeName = @FileTypeName))
			begin
				insert into UBSFLM000001(FileTypeCode,FileTypeName,InterfaceDateTime,DatabaseDateTime,UserName,IpAddress,TransactionCode,Deleted,DeletedBy,DateDeleted,Valid,CompanyId,BranchID)
				 values(@FileTypeCode,@FileTypeName,@InterfaceDateTime,@DatabaseDateTime,@UserName,@IpAddress,@TransactionCode,@Deleted,@DeletedBy,@DateDeleted,@Valid,@CompanyId,@BranchID)
				 set  @ResponseCode  ='000'
			 end
			 else
			  begin
				set  @ResponseCode  ='001'
			  end
		end
	END TRY 
	BEGIN CATCH 
		set  @ResponseCode  ='005'
	END CATCH

	execute GlobalGetResponseDescription @ResponseCode, @ResponseDescription out 
	insert into @ResponseTable (ResponseCode,ResponseDescription) values (@ResponseCode,@ResponseDescription)
	select * from @ResponseTable
end
go
--get 
drop procedure GlobalGetFileTypes
go
create procedure GlobalGetFileTypes (@Code int, @reference varchar(max),@companyId varchar(max), @branch varchar(max), @ipaddress varchar(max), @username varchar(max)) as
 begin
	if(@Code = 0)
	begin
		select * from UBSFLM000001 where valid  = 1 and CompanyId =@companyId
	end
	if(@Code = 1)
	begin
		select * from UBSFLM000001 where valid  = 1 and CompanyId =@companyId and FileTypeID = @reference
	end
 end