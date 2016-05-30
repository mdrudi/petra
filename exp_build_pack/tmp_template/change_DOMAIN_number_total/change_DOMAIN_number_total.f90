      use netcdf
      implicit none
      
      integer numb
      character*100 filename
      integer :: ncid, status
      character*4 nn 
      call getarg(1,nn)
      call getarg(2,filename)

      read(nn,'(I4)')numb

      status = nf90_open(trim(filename), nf90_write, ncid) 
      if (status /= nf90_noerr) call handle_err(status)  
 
      status = nf90_redef(ncid)
      if (status /= nf90_noerr) call handle_err(status)

      status=nf90_put_Att(ncid,nf90_global,"DOMAIN_number_total",numb)  
      if (status /= nf90_noerr) call handle_err(status)

      status = nf90_enddef(ncid)
      if (status /= nf90_noerr) call handle_err(status)
      
      stop
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
       
