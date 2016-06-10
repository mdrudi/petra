program seaoverland_double_ncf
    ! Update Paolo Oliveri April 22, 2016
    use netcdf       
    INTEGER :: i, j, t, d, ni, nj, nt, loop, nloop
    INTEGER :: ncid, status, varID
    DOUBLE PRECISION, DIMENSION (:,:), ALLOCATABLE :: A, mask, out
    REAL, DIMENSION (:, :, :), ALLOCATABLE :: Field, OutField, mask3d
    CHARACTER (len = 200) :: InFile, OutFile, InVar, loopstr, nloopstr, copy, arg1, arg2, arg3, arg4
    CHARACTER (len = 200) :: MaskFile, MaskName
    REAL :: NaN
    
    NaN = 0.
    NaN = NaN / NaN
    
    indx = iargc( )
    if (indx.ne.8) then
        print *, ' 8 arguments must be provided:'
        print *, ' 1) filename input field in netcdf format'
        print *, ' 2) field name'
        print *, ' 3) number LON dimension'
        print *, ' 4) number LAT dimension'
        print *, ' 5) number TIME dimension'
        print *, ' 6) number LOOP of fooding'
        print *, ' 7) mask filename'
        print *, ' 8) variable mask name'
        stop
    end if
    
    CALL getarg(1, InFile)
    CALL getarg(2, InVar)
    CALL getarg(3, arg1)
    CALL getarg(4, arg2)
    CALL getarg(5, arg3)
    CALL getarg(6, arg4)
    CALL getarg(7,MaskFile)
    CALL getarg(8,MaskName)
    
    read(arg1, *)ni
    read(arg2, *)nj
    read(arg3, *)nt
    read(arg4, *)nloop
    
    print *, trim(InFile),' ',trim(InVar),' ',ni,' ',nj, ' ',nt,' ',nloop,' ',trim(MaskFile),' ',trim(MaskName)
    
    ALLOCATE ( A(ni, nj) )
    ALLOCATE ( OUT(ni, nj) )
    ALLOCATE ( OutField(ni, nj, nt) )
    ALLOCATE ( Field(ni, nj, nt) )
    ALLOCATE ( mask3d(ni, nj, nt) )
    ALLOCATE ( mask(ni, nj) )
    
     print *, 'Opening NetCDF File...'
    !  READ FIELD
    status = nf90_open(trim(InFile), nf90_nowrite, ncid)
    if (status /= nf90_noerr) call handle_err(status)
    
    !  ---  Get the ID of the variable  ----
    status = nf90_inq_varid(ncid, trim(InVar), varID)
    if (status /= nf90_noerr) call handle_err(status)
    
    !  ----------   Get the  values  -------------------------
    status = nf90_get_var(ncid, varID, Field)
    if (status /= nf90_noerr) call handle_err(status) 
    
    !  ---  Close netCDF file
    status = nf90_close(ncid)
    if (status /= nf90_noerr) call handle_err(status)
    print *,'Read Field done.'       

    !  READ MASK 
    status = nf90_open(trim(MaskFile), nf90_nowrite, ncid)                      
    if (status /= nf90_noerr) call handle_err(status)
        
    !---  Get the ID of the variable  ----
    status = nf90_inq_varid(ncid,trim(MaskName), varID)            
    if (status /= nf90_noerr) call handle_err(status)

    !----------   Get the  values  -------------------------
    status = nf90_get_var(ncid, varID, mask3d)
    if (status /= nf90_noerr) call handle_err(status)

    !---  Close netCDF file
    status = nf90_close(ncid)                              
    if (status /= nf90_noerr) call handle_err(status)
    print *,'Read Mask done'
    


    do i = 1, ni
        do j = 1, nj
            mask(i, j) = 1.
            if (mask3d(i, j, 1) .eq. 1.) then
                mask(i, j) = NaN
            end if
        end do
    end do


    do t = 1, nt
        ! Original Field
        A = dble(Field (:, :, t))
        ! New Field With NaNs in land points
        A = A * mask
        do loop = 1, nloop
           ! write( loopstr, * ) loop
           ! loopstr = adjustl(loopstr)
           ! print *, '-------------------------'
           ! print *, 'loop '//trim(loopstr)
           ! print *, '-------------------------'
           CALL seaoverland_double(A, ni, nj, out)
           A = OUT
        end do


!        ! Replace NaNs with FillValue in output
!        do i = 1, ni
!            do j = 1, nj
!                if (isNaN(out(i, j))) then
!                    out(i, j) = 1.e20
!                end if
!            end do
!        end do


        OutField(:,:,t) = sngl(OUT(:,:))
    end do
    
    ! Write SeaOverLanded File
    print *, '-------------------------'
    print *, 'Writing Output File...'

!!!!!! In this section the output file is different from input file

!    ! Create Output File name
!    write( nloopstr, * ) nloop
!    nloopstr = adjustl(nloopstr)
!    if ( nloop == 1) then
!        OutFile = trim(InFile(1: len_trim(InFile) - 3))//'_SoLf90_on_'//trim(InVar)//'_'//trim(nloopstr)//'_loop.nc'
!    else
!        OutFile = trim(InFile(1: len_trim(InFile) - 3))//'_SoLf90_on_'//trim(InVar)//'_'//trim(nloopstr)//'_loops.nc'
!    end if
!    
!    ! Copy original File
!    copy = 'cp '//trim(InFile)//' '//trim(OutFile)
!    status = system(copy)
!
!    ! Open Output File
!    status = nf90_open(trim(OutFile), nf90_write, ncid)
!    if (status /= nf90_noerr) call handle_err(status)
!
!    ! Update SoL Field
!    status = nf90_put_var(ncid, varID, OutField)
!    if (status /= nf90_noerr) call handle_err(status)
!    
!    ! Close Output file
!    status = nf90_close(ncid) 
!    if (status /= nf90_noerr) call handle_err(status)
!    print *, 'Finished.'


!!!!!! In this section the output file is the input file itself

    print *, 'Open work file...'
    status=NF90_CREATE(trim(InFile),NF90_NOCLOBBER,ncid)
    if(status==NF90_EEXIST) then
    print *, 'File already existing. Data will be updated'
    status=NF90_OPEN(trim(InFile),NF90_WRITE,ncid)
    endif
    call handle_err(status)

    ! Get the ID of the variable
    status = nf90_inq_varid(ncid,trim(InVar), varID)               
    if (status /= nf90_noerr) call handle_err(status)

    ! Write netCDF file
    status = nf90_put_var(ncid, varID, OutField)
    if (status /= nf90_noerr) call handle_err(status)

    ! Close netCDF file
    status = nf90_close(ncid)
    if (status /= nf90_noerr) call handle_err(status)
    print *, 'Finished.'



end program seaoverland_double_ncf


!!!!!!!!!!!!!!!!!!!!!!! 
subroutine seaoverland_double(input_matrix, ncols, nrows, output_matrix)
!!!!!!!!!!!!!!!!!!!!!!!
  ! Update, Fixed border mean errors, Paolo Oliveri and Damiano Delrosso, April 14, 2016
  ! Updated subroutine precision, Paolo Oliveri, April 19, 2016
    
    INTEGER, INTENT(IN) :: ncols, nrows
    DOUBLE PRECISION, DIMENSION (ncols, nrows) :: input_matrix, output_matrix, mean_matrix
    DOUBLE PRECISION, DIMENSION (ncols, nrows, 8)  :: shift_matrix
    LOGICAL, DIMENSION (ncols, nrows)  :: mask_logic
    LOGICAL, DIMENSION (ncols, nrows, 8) :: mask_logic_3d
    REAL :: NaN
    
    NaN = 0.
    NaN = NaN / NaN

    ! do j = 1, nrows
    !     print *, input_matrix(:, j)
    ! end do
    ! print *, '-------------------------'
    ! Create shift Matrix
    shift_matrix(:, :, :) = NaN
    ! right-down shift
    shift_matrix(2 : ncols, 2 : nrows, 1) = input_matrix(1: ncols - 1, 1: nrows - 1)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 1)
    !  end do
    ! print *, '-------------------------' 
    ! down shift
    shift_matrix(:, 2 : nrows, 2) = input_matrix(:, 1 : nrows - 1)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 2)
    !  end do
    ! print *, '-------------------------' 
    ! left-down shift
    shift_matrix(1: ncols - 1, 2 : nrows, 3) = input_matrix(2: ncols, 1 : nrows - 1)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 3)
    !  end do
    ! print *, '-------------------------' 
    ! right shift
    shift_matrix(2: ncols, : , 4) = input_matrix(1 : ncols - 1, :)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 4)
    !  end do
    ! print *, '-------------------------' 
    ! left shift
    shift_matrix(1: ncols - 1, :, 5) = input_matrix(2 : ncols, :)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 5)
    !  end do
    ! print *, '-------------------------' 
    ! up-right shift
    shift_matrix(2 : ncols, 1 : nrows - 1, 6) = input_matrix(1: ncols - 1, 2: nrows)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 6)
    ! end do
    ! print *, '-------------------------' 
    ! up shift
    shift_matrix(:, 1 : nrows - 1, 7) = input_matrix(:, 2 : nrows)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 7)
    !  end do
    ! print *, '-------------------------' 
    ! up-left shift
    shift_matrix(1: ncols - 1, 1 : nrows - 1, 8) = input_matrix(2: ncols, 2 : nrows)
    ! do j = 1, nrows
    !     print *, shift_matrix(:, j, 8)
    !  end do
    ! print *, '-------------------------'  
    ! FALSE where is NaN (land points)
    mask_logic_3d = .not.isNaN(shift_matrix)
    mask_logic = .not.isNaN(input_matrix)
    ! Create Matrix that NaN-averages each point with 3x3 Cell surrounding it 
    mean_matrix = (SUM ( shift_matrix, 3 , mask_logic_3d ) )/(  COUNT( mask_logic_3d , 3 )   )
    ! Write only water-land contiguous averaged points to output
    output_matrix = MERGE (input_matrix, mean_matrix, mask_logic)
    ! do j = 1, nrows
    !     print *, output_matrix(:, j)
    ! end do
    return
end subroutine seaoverland_double

! ----subroutine handle_err -------------
SUBROUTINE handle_err(status)
    use netcdf
    INTEGER, intent (in) :: status
    CHARACTER (len = 80) :: nf_90_strerror
    if (status /= nf90_noerr) then
        write (*,*) nf90_strerror(status)
        stop 'Stopped'
    end if
end subroutine handle_err
