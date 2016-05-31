program new_seaoverland

! Giacomo Girardi, 03.07.2012
! verificato con la funzione change.m ﻿(M.tonani 04/10/01)
           
      use netcdf
      
      INTEGER	 							:: i,j,t,ni,nj,nt
      INTEGER	 							:: ncid,status,varID,lonID,latID,timeID
      REAL,DIMENSION (:,:)  ,ALLOCATABLE    :: A, slmec,OUT
      REAL,DIMENSION (:,:,:),ALLOCATABLE    :: Field,OutField
      REAL,DIMENSION (:,:,:),ALLOCATABLE    :: slmec1
      CHARACTER (len=100) 					:: InFile, InVar,MaskFile,MaskName,arg1,arg2,arg3
      REAL									:: NaN
      
 
      NaN= 0.
	  NaN = NaN / NaN
     
            
      indx = iargc( )
      if(indx.ne.7)then
        print*,' 7 arguments must be provided: '
        print*,' 1) filename input field in netcdf format '
        print*,' 2) field name'
        print*,' 3) number LONG dimension      '
        print*,' 4) number LAT dimension       '
        print*,' 5) number TIME dimension       '
        print*,' 6) mask filename '
        print*,' 7) variable mask name'  
        stop
      endif
      
      CALL getarg(1,InFile)
      CALL getarg(2,InVar)
      CALL getarg(3,arg1)
      CALL getarg(4,arg2)
      CALL getarg(5,arg3)
      CALL getarg(6,MaskFile)
      CALL getarg(7,MaskName)
 

      read(arg1,*)ni
      read(arg2,*)nj
      read(arg3,*)nt
       
print*, trim(InFile),' ',trim(InVar),' ',ni,' ',nj, ' ',nt,' ',trim(MaskFile),' ',trim(MaskName)
      
      ALLOCATE ( A(ni,nj) )
      ALLOCATE ( OUT(ni,nj) )
      ALLOCATE ( OutField(ni,nj,nt) )
      ALLOCATE ( Field(ni,nj,nt) )
      ALLOCATE ( slmec1(ni,nj,nt) )
      ALLOCATE ( slmec(ni,nj) )



!!!! READ FIELD !!!!!    
     status = nf90_open(trim(InFile), nf90_nowrite, ncid)   			
	 if (status /= nf90_noerr) call handle_err(status)
	 
!---  Get the ID of the variable  ----
	 status = nf90_inq_varid(ncid,trim(InVar), varID) 		
	 if (status /= nf90_noerr) call handle_err(status) 

!----------   Get the  values  -------------------------
	 status = nf90_get_var(ncid, varID, Field)
	 if (status /= nf90_noerr) call handle_err(status) 

!---  Close netCDF file
	 status = nf90_close(ncid)   				
	 if (status /= nf90_noerr) call handle_err(status)
     PRINT*,'read Field done'

!!!! READ MASK !!!!! 
    status = nf90_open(trim(MaskFile), nf90_nowrite, ncid)   			
	 if (status /= nf90_noerr) call handle_err(status)
	 
!---  Get the ID of the variable  ----
	 status = nf90_inq_varid(ncid,trim(MaskName), varID) 		
	 if (status /= nf90_noerr) call handle_err(status) 

!----------   Get the  values  -------------------------
	 status = nf90_get_var(ncid, varID, slmec1)
	 if (status /= nf90_noerr) call handle_err(status) 

!---  Close netCDF file
	 status = nf90_close(ncid)   				
	 if (status /= nf90_noerr) call handle_err(status)
     PRINT*,'read Mask done'
  
            
   
   do i=1,ni 
 		do j=1,nj
 		      slmec(i,j)=1.
    		if ( slmec1(i,j,1) .eq. 1. ) then
   		       slmec(i,j) = NaN         
 			 end if
 	     	end do
		end do 
   
do t=1,nt
    A = Field (:,:,t) 	   !! forzante originario 
    A = A * slmec  		   !! forzante con NaN per i punti terra
    
      
    CALL seaoverland(A,ni,nj,out)
    
   
    	do i=1,60 
    		 CALL seaoverland(out,ni,nj,out)
    	end do 
    	OutField(:,:,t)=OUT(:,:)
end do
    
    
!!!! Aggiorno file esistente
print *,'Apertura file di lavoro...'
status=NF90_CREATE(trim(InFile),NF90_NOCLOBBER,ncid)
if(status==NF90_EEXIST) then
   print *, "File gia' esistente: verranno aggiornati i campi dati"
   status=NF90_OPEN(trim(InFile),NF90_WRITE,ncid)
   endif
call handle_err(status)

!---  Get the ID of the variable  ----
	 status = nf90_inq_varid(ncid,trim(InVar), varID) 		
	 if (status /= nf90_noerr) call handle_err(status) 
       
!Write netCDF file
       status = nf90_put_var(ncid, varID, OutField)
       if (status /= nf90_noerr) call handle_err(status)
              
!Close netCDF file
       status = nf90_close(ncid) 
       if (status /= nf90_noerr) call handle_err(status)

end program new_seaoverland


!!!!!!!!!!!!!!!!!!!!!!! 
subroutine seaoverland(A,ni,nj,out)
!!!!!!!!!!!!!!!!!!!!!!!
      
      INTEGER,INTENT(IN)				:: ni,nj
      REAL,DIMENSION (ni,nj),INTENT(IN)  :: A
      REAL,DIMENSION (ni,nj),INTENT(OUT) :: OUT
      
      INTEGER	 				:: i,j
      REAL,DIMENSION (ni,nj)    :: mat1,mat2,mat3,mat4,mat5,mat6,mat7,mat8,SS
      REAL,DIMENSION (ni,nj,8)  :: S
      LOGICAL,DIMENSION (ni,nj,8)  :: mask1
      LOGICAL,DIMENSION (ni,nj) :: mask_logic 
    
    
      mat8 = eoshift(a   , SHIFT=-1, BOUNDARY = (/a(:,1)/)    ,DIM=2)
             
      mat1 = eoshift(mat8, SHIFT=-1, BOUNDARY = (/mat8(1,:)/) ,DIM=1)

	  mat2 = eoshift(a   , SHIFT=-1, BOUNDARY = (/a(1,:)/)    ,DIM=1)

	  mat4 = eoshift(a   , SHIFT= 1, BOUNDARY = (/a(:,nj)/)   ,DIM=2)

      mat3 = eoshift(mat4, SHIFT=-1, BOUNDARY = (/mat4(1,:)/) ,DIM=1)

      mat5 = eoshift(mat4, SHIFT= 1, BOUNDARY = (/mat4(ni,:)/),DIM=1)

	  mat6 = eoshift(a   , SHIFT= 1, BOUNDARY = (/a(ni,:)/)   ,DIM=1)
   
      mat7 = eoshift(mat8, SHIFT= 1, BOUNDARY = (/mat8(ni,:)/),DIM=1)



            
 S  = RESHAPE( (/ mat1, mat2, mat3, mat4, mat5, mat6, mat7, mat8 /), (/ ni, nj, 8 /))
 
 mask1 = .not.isNaN(S)
 mask_logic = .not.isNaN(A)                 ! FALSE dove c'e' NaN (terra)
  
 ss = (SUM ( S, 3 , mask1 ) )/(  COUNT( mask1 , 3 )   )

 out = MERGE (A,SS,mask_logic) 

return
end 


!----subroutine handle_err -------------
       SUBROUTINE handle_err(status)
       use netcdf 
	   integer, intent (in) :: status    
	   character (len = 80) :: nf_90_strerror
	   if (status /= nf90_noerr) then
	    write (*,*) nf90_strerror(status) 
	    stop 'Stopped'
	    end if
	   end subroutine handle_err
