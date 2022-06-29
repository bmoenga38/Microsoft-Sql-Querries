

drop table UBSFLM000003
GO
CREATE TABLE UBSFLM000003 
(
 File_SubCategoryID int identity(1,1) not null,
 File_SubCategoryCode varchar(max),
 File_SubCategoryName varchar(max),

	File_SubCategoryID  int not null, 
	
	PRIMARY KEY (File_SubCategoryID),

    CONSTRAINT FK_FileCategoryID FOREIGN KEY (FK_FileCategoryID)
    REFERENCES UBSFLM000002(FK_FileCategoryID),


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
 for
GO
--procedure
drop procedure CreateFile_SubCategories
go
create procedure CreateFile_SubCategories(
 @File_SubCategoryID int,
 @File_SubCategoryCode varchar(max),
 @File_SubCategoryName varchar(max),

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
			update UBSFLM000003 set
			File_SubCategoryCode = @File_SubCategoryCode,
			File_SubCategoryName = @File_SubCategoryName,
			UserName =@UserName,
			IpAddress =@IpAddress,
			TransactionCode =@TransactionCode,
			Deleted =@Deleted,
			DeletedBy =@DeletedBy,
			DateDeleted =@DateDeleted,
			Valid =@Valid where File_SubCategoryID = @File_SubCategoryID  and CompanyId = @CompanyId and BranchID = @BranchID
			set  @ResponseCode  ='000'
		end
		else
		begin
			if not exists(select 1 from UBSFLM000003 where Valid =1 and CompanyId = @CompanyId and (File_SubCategoryCode =@File_SubCategoryCode or File_SubCategoryName = @File_SubCategoryName))
			begin
				insert into UBSFLM000003(File_SubCategoryCode,File_SubCategoryName,InterfaceDateTime,DatabaseDateTime,UserName,IpAddress,TransactionCode,Deleted,DeletedBy,DateDeleted,Valid,CompanyId,BranchID)
				 values(@File_SubCategoryCode,@File_SubCategoryName,@InterfaceDateTime,@DatabaseDateTime,@UserName,@IpAddress,@TransactionCode,@Deleted,@DeletedBy,@DateDeleted,@Valid,@CompanyId,@BranchID)
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
drop procedure GlobalGetFile_SubCategories
go
create procedure GlobalGetFile_SubCategories (@Code int, @reference varchar(max),@companyId varchar(max), @branch varchar(max), @ipaddress varchar(max), @username varchar(max)) as
 begin
	if(@Code = 0)
	begin
		select * from UBSFLM000003 where valid  = 1 and CompanyId =@companyId
	end
	if(@Code = 1)
	begin
		select * from UBSFLM000003 where valid  = 1 and CompanyId =@companyId and File_SubCategoryID = @reference
	end
 end