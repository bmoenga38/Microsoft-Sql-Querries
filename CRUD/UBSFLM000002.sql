

drop table UBSFLM000002
GO
CREATE TABLE UBSFLM000002 
(
 FileCategoryID int identity(1,1) primary key not null,
 FileCategoryCode varchar(max),
 FileCategoryName varchar(max),


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
drop procedure CreateFileCategories
go
create procedure CreateFileCategories(
 @FileCategoryID int,
 @FileCategoryCode varchar(max),
 @FileCategoryName varchar(max),

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
		if(@IsUpdate = 0)
		begin
			if(@Valid = 1)
			begin
				set @Deleted = 1
				set @DeletedBy = @UserName
				set @DateDeleted = @InterfaceDateTime
			end
			update UBSFLM000002 set
			FileCategoryCode = @FileCategoryCode,
			FileCategoryName = @FileCategoryName,
			UserName =@UserName,
			IpAddress =@IpAddress,
			TransactionCode =@TransactionCode,
			Deleted =@Deleted,
			DeletedBy =@DeletedBy,
			DateDeleted =@DateDeleted,
			Valid =@Valid where FileCategoryID = @FileCategoryID  and CompanyId = @CompanyId and BranchID = @BranchID
			set  @ResponseCode  ='000'
		end
		else
		begin
			if not exists(select 1 from UBSFLM000002 where Valid =1 and CompanyId = @CompanyId and (FileCategoryCode =@FileCategoryCode or FileCategoryName = @FileCategoryName))
			begin
				insert into UBSFLM000002(FileCategoryCode,FileCategoryName,InterfaceDateTime,DatabaseDateTime,UserName,IpAddress,TransactionCode,Deleted,DeletedBy,DateDeleted,Valid,CompanyId,BranchID)
				 values(@FileCategoryCode,@FileCategoryName,@InterfaceDateTime,@DatabaseDateTime,@UserName,@IpAddress,@TransactionCode,@Deleted,@DeletedBy,@DateDeleted,@Valid,@CompanyId,@BranchID)
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
drop procedure GlobalGetFileCategories
go
create procedure GlobalGetFileCategories (@Code int, @reference varchar(max),@companyId varchar(max), @branch varchar(max), @ipaddress varchar(max), @username varchar(max)) as
 begin
	if(@Code = 0)
	begin
		select * from UBSFLM000002 where valid  = 1 and CompanyId =@companyId
	end
	if(@Code = 1)
	begin
		select * from UBSFLM000002 where valid  = 1 and CompanyId =@companyId and FileCategoryID = @reference
	end
 end