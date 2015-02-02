!INPUT:
! 1-file name 2-Date
      include './netcdf.inc' 
      parameter(nlns=10000000)
      character*256 :: indir, outdir,infile, listfile
      character*1 cindexsat
      character*2 cinm, cind, chrs,cwin
      character*4 ciny
      character*8 date
      real rdy(nlns), aln(nlns), alt(nlns), numv(nlns), rvl(nlns), err(nlns)
      integer   ino(nlns)
      integer   indexsat, nam
      integer yyyy, mm, dd
      character*2 sat
      integer :: start(1),count(1)
      integer :: lend
      integer ::  l, ld, np
      integer, parameter:: zzr=345, ttr=129
      real, dimension (:), allocatable :: sla
      double precision, dimension (:), allocatable :: data
      integer, dimension(:), allocatable :: lat, lon
      logical nosub
      integer   idrefr, ncir
      real, dimension(zzr,ttr) :: navlonr, navlatr, ref
      integer refs(zzr,ttr)
      real, dimension(zzr) :: lonr
      real, dimension(ttr) :: latr
      integer  tt, zz
      INTEGER, DIMENSION(1) :: ar
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
      sat=infile(9:10)
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

      print*,"OPEN med_ref20yto7y.nc"
      ist = nf_open("med_ref20yto7y.nc", nf_nowrite, ncir)
      call handle_err(ist)
     
      ist = nf_inq_varid (ncir,'ref20yto7y', idrefr)
      call handle_err(ist)
      print*,"OK ref"
      ist = nf_get_var_int (ncir,idrefr,refs)
      call handle_err(ist)
      print*,"OK ref1"
      ist = nf_get_att_real (ncir,idrefr,'_FillValue',refmis)
      ist = nf_get_att_real (ncir,idrefr,'scale_factor',scref)
      print*,"OK fillva scal"
      ist = nf_inq_varid (ncir,'lat', idlatr)
      call handle_err(ist)
      ist = nf_get_var_real (ncir,idlatr,latr)
      call handle_err(ist)
      print*,"lat"
      ist = nf_inq_varid (ncir,'lon', idlonr)
      call handle_err(ist)
      ist = nf_get_var_real (ncir,idlonr,lonr)
      call handle_err(ist)
      print*,"lon"
      err=nf_close(ncir)
      print*,"OK" 
      do zz=1,345
         do tt=1,129
            if (refs(zz,tt).ne.refmis) then
               ref(zz,tt)=refs(zz,tt)*scref
            else
               ref(zz,tt)=0.
            endif
         enddo
      enddo
      do tt=1,129
         navlonr(:,tt)=lonr(:)-360
      enddo
      do zz=1,345
         navlatr(zz,:)=latr(:)
      enddo

      print*,trim(indir)//trim(infile),len(trim(indir)//trim(infile))
!-----------------------------------------------------
!      call read_data(trim(indir)//'/'//trim(infile),rinday,obdy1,obdy2,indexsat, nobs,   &
!                     rdy, aln, alt, numv, rvl, err, ino)
!-----------------------------------------------------
         ist = nf_open(trim(indir)//"/"//trim(infile),nf_write, ncid)
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
               call ref_inter(ref,navlonr,navlatr,alon,alat,refsub)
               if (refsub.ne.-99999) then
                  rval=(sla(ld)*scsla)-refsub
               else
                  print*,"strange value"
               endif
               if(rday.ge.obdy1 .and. rday.lt.obdy2 .and. alon.ge.-3 .and. &
        (.not. (alon.gt.-6 .and. alon.lt.0 .and. alat.gt.43)) ) then
               nosub = .true.
                  do k=1,nobs
                     if(abs(rday-rdy(k)).lt.0.011  .and. alon.eq.aln(k) .and. &
                       alat.eq.alt(k) ) then
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
                     err(nobs) = 0.02
                     ino(nobs) = indexsat
                    ! write(*,'(f10.5)')err(nobs)
                  endif
               endif
            endif
         enddo

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
      SUBROUTINE HANDLE_ERR(stat)
      include './netcdf.inc'
      INTEGER stat
      IF (stat .NE. NF_NOERR) THEN
      PRINT *, NF_STRERROR(stat)
      STOP 'Stopped'
      ENDIF
      END SUBROUTINE HANDLE_ERR
!----------------------------------------------------------------------
      SUBROUTINE ref_inter(refld,navlon,navlat,longitude,latitude,tosub)
      real*4 :: latitude, longitude
      integer, parameter::imt=345, jmt=129, nc=2
      integer :: idnla, idnlo, iddt, idtempv,idsalv
      real*4 ::refldso, refldno,refldse, refldne
      real*4, dimension (imt,jmt):: navlon, navlat, lonm,latm,diff
      real*4, dimension (nc,nc):: refldvt, c
      real*4, dimension (imt,jmt):: refld
      real*4 :: dx, dy, xx, yy, lonv, lonl, latv, latl, p, q
      integer :: ii, jj, nx, ny, nni, i, j, z
      integer ist, nlonv, nlonl, nlatv, nlatl, cc, t
      lonm(:,:)=navlon(:,:)-longitude
      latm(:,:)=navlat(:,:)-latitude
      diff(:,:)=abs(lonm(:,:)) + abs(latm(:,:))
      do ii=2,imt-1
         do jj=2,jmt-1
            if (diff(ii,jj).lt.diff(ii,jj+1).and.diff(ii,jj).lt.diff(ii,jj-1)) then
              if (diff(ii,jj).lt.diff(ii+1,jj).and.diff(ii,jj).lt.diff(ii-1,jj)) then
               nx=ii
               ny=jj
            endif
           endif
        enddo
      enddo
      xx=345-(37-longitude)/0.125
      dx=xx-nx
      if (dx.lt.0) then
         nlonv=nx-1
         nlonl=nx
      else if (dx.eq.0) then
         nlonv=nx
         nlonl=nx+1
      else
         nlonv=nx
         nlonl=nx+1
      endif
      yy=129-(46-latitude)/0.125
      dy=yy-ny
      if (dy.lt.0) then
         nlatv=ny-1
         nlatl=ny
      else if (dy.eq.0) then
         nlatv=ny
         nlatl=ny+1
      else
         nlatv=ny
         nlatl=ny+1
      endif
      lonv=navlon(nlonv,nlatv)
      lonl=navlon(nlonl,nlatl)
      latv=navlat(nlonv,nlatv)
      latl=navlat(nlonl,nlatl)
      refldvt=refld(nlonv:nlonl,nlatv:nlatl)
      refldso=refld(nlonv,nlatv)
      refldno=refld(nlonv,nlatl)
      refldse=refld(nlonl,nlatv)
      refldne=refld(nlonl,nlatl)
      p=(longitude-lonv)/(lonl-lonv)
      q=(latitude-latv)/(latl-latv)
      c=refldvt
      do i=1,2
         do j=1,2
            if (c(i,j).eq.0.) then
               c(i,j)=0
            else
               c(i,j)=1
            endif
        enddo
      enddo
      if ((c(1,1)+c(1,2)+c(2,1)+c(2,2)).gt.0.) then
         if (c(1,1).eq.0.) then
            cc=(1-c(2,1))*(1-c(1,2))
            refldso=(refldse*c(2,1)+refldno*c(1,2)+refldne*cc)/(c(2,1)+c(1,2)+cc)
         endif
         if (c(1,2).eq.0.) then
            cc=(1-c(1,1))*(1-c(2,2))
            refldno=(refldso*c(1,1)+refldne*c(2,2)+refldse*cc)/(c(1,1)+c(2,2)+cc)
         endif
         if (c(2,1).eq.0.) then
            cc=(1-c(1,1))*(1-c(2,2))
            refldse=(refldso*c(1,1)+refldne*c(2,2)+refldno*cc)/(c(1,1)+c(2,2)+cc)
         endif
         if (c(2,2).eq.0.) then
            cc=(1-c(2,1))*(1-c(1,2))
            refldne=(refldse*c(2,1)+refldno*c(1,2)+refldso*cc)/(c(2,1)+c(1,2)+cc)
         endif
         tosub=(1-q)*((1-p)*refldso+p*refldse)+q*((1-p)*refldno+p*refldne)
      else
         tosub=-99999
      endif
      return
      end
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

