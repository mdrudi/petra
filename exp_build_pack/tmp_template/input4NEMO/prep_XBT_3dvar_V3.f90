      include './netcdf.inc'

!INPUT:
! 1-file name 2-Date

      character*256 :: indir, outdir, infile,listfile
      character*28 :: oufile
      integer ::  ist, ncid,  prof, lev, N, start(2), count(2)
      double precision,dimension(:), allocatable :: jul, lat, lon
      double precision,dimension(:), allocatable :: jul_qc,pos_qc
      integer::  iihour, iimini, yyyy, mm, dd
!     integer::  iiday, iimon, iiyear
!      real::  rday, ijul
      integer::  kkk, kk, rr
      integer, parameter:: t=3001
      integer,dimension(t):: idepth
      integer, dimension(:), allocatable:: v
      real,dimension(t):: r, temp
      real,dimension(:,:), allocatable:: tem_qc
      real,dimension(:,:), allocatable :: dpt_qc
      real,dimension(:,:), allocatable :: tem
      real,dimension(:,:), allocatable :: dpt
      real,dimension(:,:,:), allocatable :: matr
 !     real,dimension(:), allocatable:: rday, ijul 
     ! integer,dimension(:), allocatable:: iiday, iimon, iiyear, iihour, iimin 
      character*2 :: cmon, cday,chr,cmin
      character*4 cyear
      character(len=10)::odate
      character(len=5)::  otime
      character*8 date
      parameter(nlns=1000*1000, nprofs=10000)
      parameter(km=37,kms=10000)

      dimension depw(km),valw(km),deps(kms),vals(kms)
      dimension iw(km),tw(km), ts(kms)
      dimension lnprf(nprofs),lnpre(nprofs)
      dimension errxbt(146)
      integer inoa(nlns), para(nlns)
      real    lona(nlns), lata(nlns), dpta(nlns), tima(nlns), vala(nlns), erra(nlns)
      integer kline, inoaii, parai
      real lonai,latai, dptai,timai,valai,errai
      character*1 CHAR1
      character*4 CHAR4
      character*10 CDATE
      character*5 CHOUR

      character*2 cinm, cind, chrs, cdys, cdya
      character*4 ciny , cwin
      logical :: file_exists 
      real pot_tem

!-----------------------------------------------------
      call getarg(1,indir)
      call getarg(2,outdir)
      call getarg(3,infile)
      call getarg(4,date)
      read(date(1:4),'(i4)')yyyy
      read(date(5:6),'(i2)')mm
      read(date(7:8),'(i2)')dd
  
      call conv_date_jul(dd,mm,yyyy,ijln)
      rinday = real(ijln) + 0.5
      obdy1  = rinday
      obdy2  = rinday +2 
      if(iargc().ne.4)stop 'Stop wrong number of arguments'
      nvals = 0 
      INQUIRE(file=trim(outdir)//'/'//date//'.XBT.dat', EXIST=file_exists)
      if (file_exists) then
         open(12,file=trim(outdir)//'/'//date//'.XBT.dat',form='formatted')
         do rr=1,100000
       read(12,1,end=1111) inoai, parai, lonai, latai, dptai,timai,valai,errai
         enddo
         close(12)
         open(12,file=trim(outdir)//'/'//date//'.XBT.dat',form='formatted',position='append')
 1111 continue
         print*,"yes"
      
         nprf=inoai
      else
         open(12,file=trim(outdir)//'/'//date//'.XBT.dat',form='formatted',position='append')
         print*,"no"
         nprf  = 0
      endif
 
      print*,infile
         
      do i=0,3000,1
         idepth(i)=i
      enddo
      temp=-999  
      
      ist = nf_open(trim(indir)//'/'//infile,nf_read, ncid)
      call handle_err(ist)

! get id variable
      !!!! TIME !!!!
      ist = nf_inq_varid (ncid,'TIME',idjul)
      call handle_err(ist)

      !!!! TIME_QC !!!!
      ist = nf_inq_varid (ncid,'TIME_QC',idjul_qc)
      call handle_err(ist)

      !!!! LATITUDE !!!!
      ist = nf_inq_varid (ncid,'LATITUDE',idlat)
      call handle_err(ist)

      !!!! LONGITUDE !!!!
      ist = nf_inq_varid (ncid,'LONGITUDE',idlon)
      call handle_err(ist)

      !!!! POSITION_QC !!!!
      ist = nf_inq_varid (ncid,'POSITION_QC',idpos)
      call handle_err(ist)

      !!!! DEPTH !!!!
      ist = nf_inq_varid (ncid,'DEPH',idpre)
      IF (ist .NE. NF_NOERR) THEN
         PRINT *,"DEPH doesn't exist"
         ist = nf_inq_varid (ncid,'DEPTH',idpre)
         call handle_err(ist)
      ENDIF

      !!!! DEPTH_QC !!!!
      ist = nf_inq_varid (ncid,'DEPH_QC',idpre_qc)
      IF (ist .NE. NF_NOERR) THEN
         PRINT *,"DEPH_QC doesn't exist"
         ist = nf_inq_varid (ncid,'DEPTH_QC',idpre_qc)
         call handle_err(ist)
      ENDIF
       
      !!!! TEMP !!!!
      ist = nf_inq_varid (ncid,'TEMP',idtem)
      call handle_err(ist)

      !!!! TEMP_QC !!!!
      ist = nf_inq_varid (ncid,'TEMP_QC',idtem_qc)
      call handle_err(ist)

!get dimension and length of variables TIME, DEPTH

      ist = nf_inq_dimid(ncid,'TIME',dimidp)
      call handle_err(ist)
      ist = nf_inq_dimlen(ncid,dimidp,prof)
      call handle_err(ist)
      ist = nf_inq_dimid(ncid,'DEPTH',dimidl)
      call handle_err(ist)
      ist = nf_inq_dimlen(ncid,dimidl,lev)
      call handle_err(ist) 
         
      !get value of variable

      !!!! TIME !!!!
      allocate ( jul(prof) )
      ist = nf_get_var_double(ncid,idjul,jul)
      call handle_err(ist)
         
      !!!! TIME_QC !!!!
      allocate ( jul_qc(prof) )
      ist = nf_get_var_double(ncid,idjul_qc,jul_qc)
      call handle_err(ist)

      !!!! LATITUDE !!!!
      allocate ( lat(prof) )
      ist = nf_get_var_double(ncid,idlat,lat)
      call handle_err(ist)

      !!!! LONGITUDE !!!!
      allocate ( lon(prof) )
      ist = nf_get_var_double(ncid,idlon,lon)
      call handle_err(ist)

      !!!! POSITION_QC !!!!
      allocate ( pos_qc(prof) )
      ist = nf_get_var_double(ncid,idpos,pos_qc)
      call handle_err(ist)


      !! INDEXES OF ARRAY
      start(1)=1
      start(2)=1
      count(1)=lev
      count(2)=prof

      !!!! DEPTH !!!!
      allocate ( dpt(lev,prof) )
      ist = nf_get_vara_real(ncid,idpre,start,count,dpt)
      call handle_err(ist)

      !!!! DEPTH_QC !!!!
      allocate ( dpt_qc(lev,prof) )
      ist = nf_get_vara_real(ncid,idpre_qc,start,count,dpt_qc)
      call handle_err(ist)

      !!!! TEM !!!!
      allocate ( tem(lev,prof) )
      ist = nf_get_vara_real(ncid,idtem,start,count,tem)
      call handle_err(ist)

      !!!! TEM_QC !!!!
      allocate ( tem_qc(lev,prof) )
      ist = nf_get_vara_real(ncid,idtem_qc,start,count,tem_qc)
      call handle_err(ist)

!      ist = nf_close (ncid)

!      call conv_date_jul(iiday,iimon,iiyear,jul) 

      allocate ( matr(lev,prof,2) )
      allocate ( v(prof) )
 !        allocate ( iiday(prof), iimon(prof), iiyear(prof) )
 !        allocate ( iihour(prof), iimin(prof) ) 
 !        allocate ( ijul(prof) )
      do np=1,prof
         kkk = 0
         do kk=1,lev
            if ((dpt_qc(kk,np).eq.1).and.(tem_qc(kk,np).eq.1)) then
               kkk=kkk+1
               matr(kkk,np,1) = dpt(kk,np)
               matr(kkk,np,2) = tem(kk,np)
            endif
         enddo
         v(np)=kkk
!       enddo
!      do np= 1,prof  
      call conv_jul_date(iiday,iimon,iiyear,iihour,iimin,jul(np))
      call conv_date_jul(iiday,iimon,iiyear,ijul)
      iihour=ijul*24+ iihour
      rday = (real(iihour)+real(iimin)/60.)/24.
      print*,obdy1,rday,obdy2
      if(rday.ge.obdy1 .and. rday.lt.obdy2) then
      if(lon(np).gt.-3) then
        if ((jul_qc(np) .eq. 1 ) .and. ( pos_qc(np) .eq. 1 ) .or. ( pos_qc(np) .eq. 0 )) then
          int: do n=1,t
                  do nn=1,v(np)
                     if (idepth(n).eq.matr(nn,np,1)) then
                        temp(n)=matr(nn,np,2)
                     endif
                     if ((idepth(n).ge.matr(nn,np,1)).and.(idepth(n).le.matr(nn+1,np,1))) then
                        r(n)=(idepth(n)-matr(nn,np,1))/(matr(nn+1,np,1)-matr(nn,np,1))
                        temp(n)=matr(nn,np,2)+r(n)*(matr(nn+1,np,2)-matr(nn,np,2))
                     endif
                     if ((idepth(n).gt.matr(nn,np,1)).and.(idepth(n).eq.99999)) then
                        temp(n)=matr(nn,np,2)
                        exit int
                     endif
                  enddo
               enddo int
!               call conv_date_jul(iiday,iimon,iiyear,jul(np))
!               print*,jul(np) 
!               print*,iiday(np),iimon(np),iiyear(np)
!               iihour=jul(np)*24+ iihour
!               print*,iihour
!               rday = (real(iihour)+real(iimin)/60.)/24.
!               print*,obdy1,rday,obdy2
!--------------------------------------------------------------------------

                nprf = nprf +1
                do n=1,t
                   if ((idepth(n).ge.4).and.(idepth(n).lt.1000)) then
                      nvals = nvals + 1
                      inoa(nvals) = nprf
                      para(nvals) = 1
                      lona(nvals) = lon(np)
                      lata(nvals) = lat(np)
                      dpta(nvals) = idepth(n)
                      tima(nvals) = rday - rinday
                      theta = pot_tem(temp(n),38.75,idepth(n))
                      vala(nvals) = theta
                      erra(nvals) = 0.5
                   endif
                enddo
!                  deallocate ( jul, jul_qc, lat, lon, pos_qc )
!                  deallocate ( dpt, dpt_qc, tem, tem_qc)
!                  deallocate ( matr, v )
        else
                  print*,'no quality control on date or position, profile skipped'
!                  deallocate ( jul, jul_qc, lat, lon, pos_qc )
!                  deallocate ( dpt, dpt_qc, tem, tem_qc, matr)
!                  deallocate ( matr, v )
!                  go to 1235 
        endif
           
!--------------------------------------------------------------------------
            else
                print*,'out of range of latitude'
            endif 
            else
                print*,'profile out of time-windows'
!               deallocate ( jul, jul_qc, lat, lon, pos_qc )
!               deallocate ( dpt, dpt_qc, tem, tem_qc )
!               deallocate ( matr, v )
!               go to 1235 
            endif
            temp=-999 
!             deallocate ( matr, v )
!1235 continue
         enddo
         deallocate ( jul, jul_qc, lat, lon, pos_qc )
         deallocate ( dpt, dpt_qc, tem, tem_qc, matr)
         deallocate ( v ) 
!1212 continue

!      write(12,"(i8)") nvals
      if (nvals .gt.0 ) then
         do k=1,nvals
            if (vala(k).gt.0) then
            write(12,"(2I4,6f10.5)")       &
               inoa(k), para(k), lona(k), lata(k), dpta(k), tima(k), vala(k), erra(k)
            endif
         enddo
      endif
      close(12)
1 format(i4,i4,f10.5,f10.5,f10.5,f10.5,f10.5,f10.5)
      stop
      end
!*************************************************
      SUBROUTINE HANDLE_ERR(stat)
      include './netcdf.inc'
      INTEGER stat
      IF (stat .NE. NF_NOERR) THEN
         PRINT *, NF_STRERROR(stat)
         STOP 'Stopped'
      ENDIF
      END SUBROUTINE HANDLE_ERR
!*************************************************
!----------------------------------------------------------------------
       subroutine conv_date_jul(iiday,iimon,iiyear,iijul)

       dimension idmn(12)
       data idmn/ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/

       njear = iiyear-1990

         iijul = 0

       if(iiyear.gt.1990)then
         do k=1998,iiyear-1
           iijul = iijul + 365
          if(mod(k,4).eq.0)  iijul = iijul + 1
         enddo
       endif

       if(iimon.gt.1)then
         do k=1,iimon-1
          iijul = iijul + idmn(k)
          if(k.eq.2 .and. mod(iiyear,4).eq.0)  iijul = iijul + 1
         enddo
       endif

          iijul = iijul + iiday

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
      real function pot_tem(tem1,sal1,pres1)

      real*8 tem,sal,pres
      real   tem1,sal1,pres1

      tem=tem1
      sal=sal1
      pres=pres1*0.1

      pot_tem = tem -   &
                pres * ( 3.6504e-4 + 8.3198e-5*tem - 5.4065e-7*tem**2  &
                       + 4.0274e-9*tem**3 ) -                          &
                pres * ( sal - 35.) * (1.7439e-5 - 2.9778e-7*tem)  -   &
                pres**2 * ( 8.9309e-7 - 3.1628e-8*tem + 2.1987e-10*tem**2 ) &
               + 4.1057e-9 * (sal-35.) * pres**2 -                          &
                 pres**3 * ( -1.6056e-10 + 5.0484e-12*tem)
      end

!----------------------------------------------------------------------
