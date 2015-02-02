!INPUT:
! 1-file name 2-Date
 
      parameter(nlns=10000000)
      character*256 :: indir, outdir,infile, listfile
      character*1 cindexsat
      character*2 cinm, cind, chrs,cwin
      character*4 ciny
      character*8 date
      real rdy(nlns), aln(nlns), alt(nlns), numv(nlns), rvl(nlns), err(nlns)
     ! dimension rdy(nlns), aln(nlns), alt(nlns), numv(nlns), rvl(nlns), err(nlns)
      integer   ino(nlns)
      integer   indexsat, nam
      integer yyyy, mm, dd
      character*2 sat
!-----------------------------------------------------
      if(iargc().ne.4)stop 'Stop wrong number of arguments'
      call getarg(1,indir)
      call getarg(2,outdir)
      call getarg(3,infile)
      call getarg(4,date)
      read(date(1:4),'(i4)')yyyy
      read(date(5:6),'(i2)')mm
      read(date(7:8),'(i2)')dd
      call conv_date_jul(dd,mm,yyyy,ijln)

      rinday = real(ijln) + 0.5
      obdy1  = rinday - 1 
      obdy2  = rinday + 1 
      nobs = 0

      print*,'read_data'
      !!!!!!!!!Cambiare riga dopo dipende da path del file
      sat=infile(12:13)
      print*,sat
      if(sat=="en") then
         indexsat=1
      else if(sat=="c2") then
         indexsat=2
      else if(sat=="g2") then
         indexsat=3
      else if(sat=="j1") then
         indexsat=4
      else if(sat=="j2") then
         indexsat=5
      else if(sat=="al") then
         indexsat=6
      else
         indexsat=7
      endif
      print*,trim(indir)//trim(infile),len(trim(indir)//trim(infile))
!-----------------------------------------------------
      call read_data(trim(indir)//'/'//trim(infile),rinday,obdy1,obdy2,indexsat, nobs,   &
                     rdy, aln, alt, numv, rvl, err, ino)
!-----------------------------------------------------

      print*,'number of observations is: ',nobs
      !write(*,'(f10.5)')err 
      open(12,file=trim(outdir)//'/'//date//'.SLA.dat',form='formatted',position='append')
!      write(12,"(i8)") nobs
      if(nobs.ne.0)then
         do k=1,nobs
           write(12,"(5f10.5,i5)") aln(k), alt(k), rdy(k)-rinday, rvl(k), err(k), ino(k)
         enddo
      endif
      close(12)

      stop
      end

!-----------------------------------------------------

      subroutine read_data(file_i,rinday,obdy1,obdy2,indexsat,nobs,  &
                     rdy, aln, alt, numv, rvl, erro, ino)

      include './netcdf.inc'
      parameter(nlns=10000000)
      integer :: start(1),count(1)
      integer :: lend 
      integer ::  l, ld, np
      real, dimension (:), allocatable :: sla
      double precision, dimension (:), allocatable :: data
      integer, dimension(:), allocatable :: lat, lon
!      character*200 file_i
!      character, dimension (:), allocatable :: fileobs
      real rdy(nlns), aln(nlns), alt(nlns), numv(nlns), rvl(nlns), erro(nlns)
!      dimension rdy(nlns), aln(nlns), alt(nlns), numv(nlns), rvl(nlns), err(nlns)
      integer   ino(nlns),indexsat
!      real ino(nlns),indexsat
      character*100 infile
      logical nosub
!      character*2 sat 
      ! CAMBIARE QUANDO CI SONO PIU' SATELLITI

!      open(10,file=file_i,form='formatted')

 !     do kfiles=1,500

!         read(10,"(27a)",end=1212)infile
         print*,file_i
!         nnome=len(trim(file_i))
!         allocate ( fileobs(nam) )
!         fileobs=file_i(1:nam)
!         print*,fileobs
!         print*,len(file_i),len(fileobs) 
         ist = nf_open(file_i,nf_read, ncid)
         call handle_err(ist)

! get variable ID for Latitudes,Longitudes,Data

         ist = nf_inq_varid (ncid,'SLA', idsla)
         call handle_err(ist)
         ist = nf_inq_varid (ncid,'time', idbd)
         call handle_err(ist)
         ist = nf_inq_varid (ncid,'latitude', idlat)
         call handle_err(ist)
         ist = nf_inq_varid (ncid,'longitude', idlon)
         call handle_err(ist)
         
         ! get dimension ID and dimension length

         ! First we keep all the information about number of TIME

         ist = nf_inq_dimid(ncid,'time',dimidp)
         call handle_err(ist)
         ist = nf_inq_dimlen(ncid,dimidp,lend)
         call handle_err(ist)
         ! get contents of dimension variable

         !!! SLA data
         allocate ( sla(lend) ) !! For each cycle the number of point
         start(1)=1
         count(1)=lend
         ist = nf_get_vara_real (ncid,idsla,start,count,sla)
         call handle_err(ist)
         !!! DATA data
         allocate ( data(lend) ) !! For each cycle the number of point
         start(1)=1
         count(1)=lend
         ist = nf_get_vara_double (ncid,idbd,start,count,data)
         call handle_err(ist)
         !!! Latitude and Longitude data
         allocate ( lat(lend) )
         allocate ( lon(lend) )
         start(1)=1
         count(1)=lend
         ist = nf_get_vara_int (ncid,idlat,start,count,lat)
         call handle_err(ist)
         ist = nf_get_vara_int (ncid,idlon,start,count,lon)
         call handle_err(ist)
         !!! MISSING VALUE

         stat = nf_get_att_real (ncid,idsla,'_FillValue',slamis)
         stat = nf_get_att_int (ncid,idlat,'_FillValue',latmis)
         stat = nf_get_att_int (ncid,idlon,'_FillValue',lonmis)
         stat = nf_get_att_real (ncid,idbd,'_FillValue',timmis)

         !!! Scale factor for lat,lon,sla

         stat = nf_get_att_real (ncid,idlat,'scale_factor',sclat)
         stat = nf_get_att_real (ncid,idlon,'scale_factor',sclon)
         stat = nf_get_att_real (ncid,idsla,'scale_factor',scsla)
         do ld=1,lend
            if((sla(ld).eq.slamis).or.(data(ld).eq.timmis).or.(lon(ld).eq.lonmis)&
              .or.(lat(ld).eq.latmis))then
            else
               if (lon(ld)*sclon.gt.50) then
                  lon(ld)=lon(ld)-(360*1000000)
               endif
               call conv_jul_date(iiday,iimon,iiyear,iihour,iimin,data(ld)) 
               call conv_date_jul(iiday,iimon,iiyear,ijul)
               iihour=ijul*24+ iihour
               rday = (real(iihour)+real(iimin)/60.)/24.
               alon=lon(ld)*sclon
               alat=lat(ld)*sclat
               rval=sla(ld)*scsla
               if(rday.ge.obdy1 .and. rday.lt.obdy2 .and. alon.ge.-3 .and. &
 (.not. (alon.gt.-6 .and. alon.lt.0 .and. alat.gt.43)) ) then
               nosub = .true.
                  do k=1,nobs
                     if(abs(rday-rdy(k)).lt.0.011  .and. alon.eq.aln(k) .and. alat.eq.alt(k) ) then
                        numv(k) = 1
                        rvl(k) = rval
                        nosub = .false.
                     endif
                  enddo 
                  if(nosub)then
                     nobs = nobs+1
                     rdy(nobs) = rday
                     aln(nobs) = alon
                     alt(nobs) = alat
                     numv(nobs) = 1
                     rvl(nobs) = rval
                     erro(nobs) = 0.02 
                     ino(nobs) = indexsat
                    ! write(*,'(f10.5)')err(nobs)
                  endif 
               endif
            endif
         enddo
         err=nf_close(ncid) 
      deallocate ( sla, data, lon, lat )
!      enddo

!1212 continue

!      close(10)
      return
      end
!----------------------------------------------------------------------
      SUBROUTINE HANDLE_ERR(stat)
      include './netcdf.inc'
      INTEGER stat
      IF (stat .NE. NF_NOERR) THEN
      PRINT *, NF_STRERROR(stat)
      STOP 'Stopped'
      ENDIF
      END SUBROUTINE HANDLE_ERR
!----------------------------------------------------------------------
       subroutine conv_date_jul(iiday,iimon,iiyear,iijul)

       dimension idmn(12)
       data idmn/ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/

         iijul = 0

       if(iiyear.lt.1950) stop 'wrong input year'

         do k=1950,iiyear-1
           iijul = iijul + 365
          if(mod(k,4).eq.0)  iijul = iijul + 1
         enddo

       if(iimon.gt.1)then
         do k=1,iimon-1
          iijul = iijul + idmn(k)
          if(k.eq.2 .and. mod(iiyear,4).eq.0)  iijul = iijul + 1
         enddo
       endif

          iijul = iijul + iiday -1

       return
       end
!----------------------------------------------------------------------
      subroutine conv_jul_date(iiday,iimon,iiyear,hour,minutes,iijul)

      dimension idmn(12)
      data idmn/ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/
      double precision  iijul,iijuld
      real  restday, resthour
      integer hour, minutes

      iiyear = 1950
      if(iijul.gt.365)then
         do while(iijul.gt.365.or.iijul.eq.365)
            iijul=iijul-365
            if(mod(iiyear,4).eq.0) iijul=iijul-1
            iiyear=iiyear+1
        enddo
     endif

     if(iijul.lt.0) then
        iiyear=iiyear-1
        iijul=iijul+366
     endif
        iijuld = iijul
        iijul=ceiling(iijul)
        iimon = 1
     if((iijul).gt.idmn(iimon))then
        mond = idmn(iimon)
        do while((iijul).gt.mond)
           iijul = iijul - mond
           iijuld = iijuld - mond
           iimon=iimon+1
           mond = idmn(iimon)
           if(iimon.eq.2 .and. mod(iiyear,4).eq.0) mond = 29
        enddo
     endif

     iiday = int(iijul)
     restday = iijuld-int(iijuld)
     hour = int(restday * 24)
     resthour = (restday * 24) - hour
     minutes = int(resthour * 60)

!!      return

      end
!----------------------------------------------------------------------

