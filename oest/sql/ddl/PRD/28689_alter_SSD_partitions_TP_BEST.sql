/****************************************************
Script           : 28689_alter_SSD_partitions_TP02_BEST.sql
Database         : BEST
Version          : 1.0
Author           : Shiva
Creation Date    : 04/17/2015
Description      : Adds the SSD_CF = 27 to the existing partition list

-----------------
Spot             :  28689
*********************************************************/

use BEST
go

set nocount on
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Alter Partitions for Subsidiary 27 '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
go

-- Temp table to maintain the list of tables and its partition to which the SS_CF needs to be added
create TABLE #TTABLES
  (
  table_name varchar(50) NOT null, -- Table Name.
  partition_name varchar(50) NOT null, -- Partition Name
  ssd_cf ussd_cf not null
  )
go

-- Data population
insert #TTABLES values('TACCSTAT', 'PACCSTAT_UBAM', 27)
insert #TTABLES values('TACCSUP', 'PACCSUP_UBAM', 27)
insert #TTABLES values('TCTREST', 'PCTREST_UBAM', 27)
insert #TTABLES values('TRATTACHEVOL', 'PRATTACHEVOL_UBAM', 27)
go

-- Temp table used to check the count of temporary partition 
-- Since we are doing a dynamic SQL, using this table to insert the count.
create TABLE #TCOUNT
  (
   partition_count int null
  )
go

-- Cursor to iterate through the Subsidiary list.
declare curs_tables Cursor For
    select  tsrc.table_name,      
            tsrc.partition_name,      
            tsrc.ssd_cf    
    from  #TTABLES tsrc
go


declare 
  @sql_line varchar(300),
  @msg varchar(200),
  @v_table_name varchar(50),
  @v_partition_name varchar(50),
  @v_erreur int,
  @v_ssd_cf int,
  @v_temp_partition_name varchar(50),
  @v_count int,
  @v_start_time Datetime,
  @v_end_time Datetime,
  @v_duration int

BEGIN
  -- Initialize Temp. Partition Name for use.
  select @v_temp_partition_name = 'PTEMP_XYZ_123'

  -- Open cursor for the table list
  Open curs_tables 
  
  FETCH curs_tables INTO  @v_table_name, @v_partition_name, @v_ssd_cf
  
  -- Loop through the list.
  WHILE (@@sqlstatus = 0)
  BEGIN

    select @v_start_time = getdate()  
    select @msg = '< ' + 'BEGIN PROCESSING TABLE = ' + @v_table_name + ' @ ' +   convert(char(27),@v_start_time,20) + ' > '
    print @msg
    
    select @msg = '<# Dropping the temporary partition ' + @v_temp_partition_name + ' if it exists. #> '
    print @msg
    
    -- Truncate the count table.
    truncate table #TCOUNT
    
    -- Check if we already haven an existing partition with the Temp. Partition name.
    select @sql_line= "insert #TCOUNT(partition_count) select count(1) from  syspartitions where object_name(id) = '" + @v_table_name + "' and name = '" + @v_temp_partition_name + "'"
    select @msg = '< ' + 'Executing SQL= ' +  @sql_line + ' @ ' + convert(varchar(27),getDate(),20 ) + ' > '
    print @msg    
    
    exec (@sql_line)
    select @v_erreur = @@error
    if @v_erreur!=0 goto fin_proc
   
    -- Check on the count from the #TCOUNT temp table.    
    select @v_count = partition_count from #TCOUNT
    select @msg = '< Temporary Partition Count = ' + Convert(Varchar(10), @v_count) +  ' > '
    print @msg
    
    -- If the partition exists.
    if (@v_count = 1)
    BEGIN
         -- Drop the temporary partition  
        select @sql_line="ALTER TABLE " + @v_table_name +  " DROP PARTITION " + @v_temp_partition_name 
        select @msg = '< ' + 'Executing SQL= ' + ' @ ' + convert(varchar(27),getDate(),20 ) + ' > '
        print @msg
          
        exec (@sql_line)
        select @v_erreur = @@error          
        
        if @v_erreur!=0  -- Error in Drop partition 
          begin 
           select @msg = '<*** ' + 'Encountered error = ' + Convert(Varchar(10), @v_erreur) + ' when running SQL = ' + @sql_line  + ' ***> '
           print @msg        
          end    
    END 
    
    select @msg = '<# Creating the temporary partition ' + @v_temp_partition_name + ' with SSD_CF = ' +  Convert(Varchar(10), @v_ssd_cf) + ' #> '
    print @msg
   
    -- Add a Temporary Partition using the new subsidiary.
    select @sql_line='ALTER TABLE '  + @v_table_name + ' ADD PARTITION ( ' + @v_temp_partition_name + ' values (' + Convert(Varchar(10), @v_ssd_cf)  + ') )' 
    select @msg = '< ' + 'Executing SQL= ' +  @sql_line + ' @ ' + convert(varchar(27),getDate(),20 ) + ' > '
    print @msg
    exec (@sql_line)
    select @v_erreur = @@error
    
    if (@v_erreur = 14312)  -- indicates SSD_CF already exists
      begin 
        select @msg = '<< SSD_CF = ' + Convert(Varchar(10), @v_ssd_cf) + ' ALREADY EXISTS FOR ' +  @v_table_name   + ' >> '
        print @msg        
        goto next_table
      end
    if (@v_erreur != 0 AND @v_erreur != 12841)   -- 12841 indicates PY partition already exists.
      begin 
        select @msg = '<*** ' + 'Encountered error = ' + Convert(Varchar(10), @v_erreur) + ' when running SQL = ' + @sql_line  + ' ***> '
        print @msg                
        goto next_table
      end
      
    -- Merge the Temporary Partition into the main Partition.
    select @msg = '<# Merging the temporary partition ' + @v_temp_partition_name + ' into ' + @v_partition_name  + ' #> '
    print @msg
    
    select @sql_line="ALTER TABLE " + @v_table_name +  " MERGE PARTITION " + @v_partition_name + "," + @v_temp_partition_name + " INTO " + @v_partition_name 
    select @msg = '< ' + 'Executing SQL= ' +  @sql_line + ' @ ' + convert(varchar(27),getDate(),20 ) + ' > '
    print @msg
    exec (@sql_line)

    select @v_erreur = @@error
    if @v_erreur!=0  -- Error in Merge partition
      begin 
           select @msg = '<*** ' + 'Encountered error = ' + Convert(Varchar(10), @v_erreur) + ' when running SQL = ' + @sql_line  + ' ***> '
           print @msg        
           
           -- Drop the temporary partition  
          select @sql_line="ALTER TABLE " + @v_table_name +  " DROP PARTITION " + @v_temp_partition_name 
          select @msg = '< ' + 'Executing SQL= ' +  @sql_line + ' @ ' + convert(varchar(27),getDate(),20 ) + ' > '
          print @msg
          
          exec (@sql_line)
          select @v_erreur = @@error          
          
          if @v_erreur!=0  -- Error in Drop partition 
            begin 
             select @msg = '<*** ' + 'Encountered error = ' + Convert(Varchar(10), @v_erreur) + ' when running SQL = ' + @sql_line  + ' ***> '
             print @msg        
            end
            
          select @msg = '<< ' + 'FAILED TO ADD SSD_CF = ' + Convert(Varchar(10), @v_ssd_cf) + ' TO ' + @v_partition_name + ' FOR ' + @v_table_name + ' >> '            
          print @msg
          goto next_table
      end
    

    -- Re-executing to check if the subsidiary got added to the partition list    
    select @msg = '<# Verifying SSD_CF = ' + Convert(Varchar(10), @v_ssd_cf) + ' addition to ' + @v_partition_name  + '#>'
    print @msg
    
    select @sql_line='ALTER TABLE '  + @v_table_name + ' ADD PARTITION ( ' + @v_temp_partition_name + ' values (' + Convert(Varchar(10), @v_ssd_cf)  + ') )' 
    select @msg = '< ' + 'Executing SQL= ' +  @sql_line + ' @ ' + convert(varchar(27),getDate(),20 ) + ' > '
    print @msg
    exec (@sql_line)
    select @v_erreur = @@error              
    if (@v_erreur = 14312) -- Indicates the partition exists.
       begin
        select @msg = '<<  SUCCESSFULLY ADDED SSD_CF = ' + Convert(Varchar(10), @v_ssd_cf) + '  TO ' + @v_partition_name + ' FOR ' + @v_table_name + ' >> '
        print @msg
       end
    else
        goto fin_proc
    
next_table:     

    select @v_end_time = getdate()  
    select @v_duration = datediff( Second, @v_start_time, @v_end_time )    
    select @msg = '< ' + 'END PROCESSING TABLE = ' + @v_table_name + ' @ ' +   convert(varchar(27),@v_end_time,20) + ', Time Taken : ' +  Convert(Varchar(10), @v_duration) + ' sec(s). > '
    print @msg
    select @msg = ' '    
    print @msg

    FETCH curs_tables INTO  @v_table_name, @v_partition_name, @v_ssd_cf

  END

  CLOSE curs_tables
  
  DEALLOCATE curs_tables  
  
return

fin_proc: 
   select @msg = '<*** ' + 'Encountered error = ' + Convert(Varchar(10), @v_erreur) + ' when running SQL = ' + @sql_line  + ' ***> '
   print @msg
END
go

set nocount on
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Finish  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
