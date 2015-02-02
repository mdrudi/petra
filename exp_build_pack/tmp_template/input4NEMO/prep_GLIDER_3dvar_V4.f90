      include './netcdf.inc'

!INPUT:
! 1-file name 2-Date

      character*256 :: indir, outdir, infile, listfile
      character*28 :: oufile
      integer ::  ist, ncid,  prof, lev, N, cln, start(2), count(2)
      integer :: yyyy, mm, dd, longitude, latitude, posit
      double precision,dimension(:), allocatable :: jul, lat, lon
      double precision,dimension(:), allocatable :: jul_qc,pos_qc
      character,dimension(:), allocatable :: dir
      character*5 ::  pln
      integer::  iihour, iimin, A, B, M, P, Q, ag
      double precision,dimension(:,:), allocatable:: tem_qc, sal_qc, pre_qc
      real,dimension(:,:), allocatable :: pres, tem, sal
      real,dimension(:,:), allocatable :: dpt
      real,dimension(:), allocatable :: bfrq, xx
      real,dimension(:,:), allocatable :: X, PRO, PROH
      real :: DATA(2500,3), DAT(2500,3),  limit, mean
      character*2 :: cmon, cday,chr,cmin
      character*4 cyear
      character*8 date
      character(len=10)::odate
      character(len=5)::  otime
!!!!! DICHIARAZIONE VARIABILE 2 PROGRAMMA
      parameter(nlns=1000*1000,nprofs=10000)
      parameter(km=46,kmt=72,km2=2*km,kms=10000)
      real,dimension(:), allocatable ::  deps, targ, sarg
! real,dimension(:) ::  deps, targ, sarg
      dimension lnprf(nprofs),lnpre(nprofs)
      integer inoa(nlns), para(nlns)
      integer platn, rr
      integer indx, counts
      real lona(nlns), lata(nlns), dpta(nlns), tima(nlns), vala(nlns), erra(nlns)
      character*1 CHAR1
      character*4 CHAR4
      character*10 CDATE
      character*5 CHOUR
      character*3 datatype
      character*2 cinm, cind, chrs, cdys, cdya
      character*4 ciny , cwin
      character*1 indxx
      integer kline, inoaii, parai
      real lonai,latai, dptai,timai,valai,errai, tsp, tspa, tspb
      logical :: file_exists      
      real pot_tem

      call getarg(1,indir)
      call getarg(2,outdir)
      call getarg(3,infile)
      call getarg(4,date)
      if(iargc().ne.4)stop 'Stop wrong number of arguments'
      print*,infile
      INQUIRE(file=trim(outdir)//'/'//date//'.GLIDER.dat',EXIST=file_exists)
      if (file_exists) then
      open(12,file=trim(outdir)//'/'//date//'.GLIDER.dat',form='formatted')
      do rr=1,100000
      read(12,10,end=1111) inoai,parai,lonai,latai,dptai,timai,valai,errai
      enddo
      close(12)
      open(12,file=trim(outdir)//'/'//date//'.GLIDER.dat',form='formatted',position='append')
 1111 continue
         print*,"yes"
      
         nprf=inoai
      else
         open(12,file=trim(outdir)//'/'//date//'.GLIDER.dat',form='formatted',position='append')
         print*,"no"
         nprf  = 0
      endif
      read(date(1:4),'(i4)')yyyy
      read(date(5:6),'(i2)')mm
      read(date(7:8),'(i2)')dd
      datatype=infile(14:15)
      if ( datatype == "GL" ) then
         indx = 1
      else
         indx = 2
      end if
      pln=infile(17:21)
      call conv_date_jul(dd,mm,yyyy,ijln)
      rinday = real(ijln) + 0.5
      obdy1  = rinday
      obdy2  = rinday +2

      open(12,file=trim(outdir)//'/'//date//'.GLIDER.dat', &
            form='formatted',position='append')
      nvals = 0

! open input nc file
      ist = nf_open(trim(indir)//'/'//infile,nf_read, ncid)
      call handle_err(ist)
! open error asci file
      open(99,file=trim(outdir)//'/error_ascii.txt', &
           form='formatted',position='append')
      write(99,'(a30)') '#########################################'
      write(99,'(a35)') infile
      
      ! get id variable
      
      !!!! PLATFORM NUMBER !!!!
!      ist = nf_get_att_text (ncid,n_global,"id",pln)
!      call handle_err(ist)
!      print*,pln      
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
  
      !!!! DIRECTION !!!!
      ist = nf_inq_varid (ncid,'DIRECTION',iddir)
      call handle_err(ist)

      !!!! POSITION_QC !!!!
      ist = nf_inq_varid (ncid,'POSITION_QC',idpos)
      call handle_err(ist)
 
      !!!! PRES !!!!
      ist = nf_inq_varid (ncid,'PRES',idpre)
      call handle_err(ist)

      !!!! PRES_QC !!!!
      ist = nf_inq_varid (ncid,'PRES_QC',idpre_qc)
      call handle_err(ist)

      !!!! TEMP !!!!
      ist = nf_inq_varid (ncid,'TEMP',idtem)
      call handle_err(ist)

      !!!! TEMP_QC !!!!
      ist = nf_inq_varid (ncid,'TEMP_QC',idtem_qc)
      call handle_err(ist)

      !!!! PSAL !!!!
      ist = nf_inq_varid (ncid,'PSAL',idsal)
      call handle_err(ist)

      !!!! PSAL_QC !!!!
      ist = nf_inq_varid (ncid,'PSAL_QC',idsal_qc)
      call handle_err(ist)

!get dimension and length of variable PRES

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

      !!!! DIRECTION !!!!
      allocate ( dir(prof) )
      ist = nf_get_var_text(ncid,iddir,dir)
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

      !!!! PRES !!!!
      allocate ( pres(lev,prof) )
      ist = nf_get_vara_real(ncid,idpre,start,count,pres)
      call handle_err(ist)
     
      !!!! PRES_QC !!!!
      allocate ( pre_qc(lev,prof) )
      ist = nf_get_vara_double(ncid,idpre_qc,start,count,pre_qc)
      call handle_err(ist)

      !!!! TEM !!!!
      allocate ( tem(lev,prof) )
      ist = nf_get_vara_real(ncid,idtem,start,count,tem)
      call handle_err(ist)

      !!!! TEM_QC !!!!
      allocate ( tem_qc(lev,prof) )
      ist = nf_get_vara_double(ncid,idtem_qc,start,count,tem_qc)
      call handle_err(ist)

      !!!! PSAL !!!!
      Allocate ( sal(lev,prof) )
      ist = nf_get_vara_real(ncid,idsal,start,count,sal)
      call handle_err(ist)

      !!!! PSAL_QC !!!!
      allocate ( sal_qc(lev,prof) )
      ist = nf_get_vara_double(ncid,idsal_qc,start,count,sal_qc)
      call handle_err(ist)

          !!!!!!!!! Code Meaning !!!!!!!!!
          !!                            !!
          !! 0 No QC was performed      !!
          !! 1 Good data                !!
          !! 2 Probably good data       !!
          !! 3 Bad data that are        !!
          !!   potentially correctable  !!
          !! 4 Bad data                 !!
          !! 5 Value changed            !!
          !! 6 Not used                 !!
          !! 7 Not used                 !!
          !! 8 Interpolated value       !!
          !! 9 Missing value            !!
          !!                            !!
          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!!!! CONTROL ON TIME AND LONGITUDE VALUE
     
      allocate( dpt(lev,prof) )
      do np=1,prof
         do n = 1, lev
            if ( pres(n,np) .ge. 0 ) then
               dpt(n,np) = depth(pres(n,np),lat(np))
            endif
         enddo
      enddo
!      np=1
      do np=1,prof
      call conv_jul_date(iiday,iimon,iiyear,iihour,iimin,jul(np))
      call conv_date_jul(iiday,iimon,iiyear,ijln)
      iihour=ijln*24+ iihour
      rday = (real(iihour)+real(iimin)/60.)/24.
      print*,rday
      if (.not.(rday.ge.obdy1 .and. rday.lt.obdy2 )) then
         print*,'Profile is not in the time window'
!         stop
      else
         print*,'Profile is in the time window'
         if ( lon(np).ne.99999 .and. lon(np).gt.-3 ) then

!!!! CONVERSION PRESSION TO DEPTH

!            allocate( dpt(lev) )
!            print*,pres(:,np)
!            do n = 1, lev
!               print*,pres(np,n)
!               if ( pres(n,np) .ge. 0 ) then 
!               dpt(n,np) = depth(pres(n,np),lat(np))
!               print*,dpt(n,np)
!               endif
!            enddo
!            print*,dpt(:) 
!!!! CHECK of QUALITY CONTROL on JULD and POSITION
            print*,dir(np)
            if ((jul_qc(np) .eq. 1 ) .and. ( pos_qc(np) .eq. 1 ) &
                .and. ( dir(np) .eq. "A" )) then
!             if ((jul_qc(np) .eq. 1 ) .and. ( pos_qc(np) .eq. 1 )) then     
               j = 0
!!!! CHECK of QUALITY CONTROL for P, T and S

               do n = 1, lev
              if (( pre_qc(n,np) .eq. 1 ) .and. (tem_qc(n,np) .eq. 1 ) .and. ( sal_qc(n,np) .eq. 1 )) then
                     j = j + 1
                     DAT(j,1) = dpt(n,np)
                     DAT(j,2) = tem(n,np)
                     DAT(j,3) = sal(n,np)
                  else
                     write(99,1) n
                  end if
               enddo
!!! SPIKES
               counts=1
               do while (counts .le. 20) 
!                  if (counts .eq. 1) then
                     jj = j
                     if (( jj .eq. 0 )) then
                        j = 0
                     else
                        j = 1
                     endif
!                  else 
!                     jj=size(DATA,DIM=1)
!                     print*,jj
!                     if (( jj .eq. 0 )) then
!                        j = 0
!                     else
!                        j = 1
!                     endif
!                  endif
!               counts=0
!                  do while (counts .eq. 10)
               do nn = 1, jj
!                  counts=0
!                  do while (counts .eq. 10)
                  if (nn.eq.1) then ! the first point of the profile
                     DATA(j,1) = DAT(nn,1)
                     DATA(j,2) = DAT(nn,2)
                     DATA(j,3) = DAT(nn,3)
                  else if (nn.eq.jj) then ! the last point of the profile
                     j = j + 1
                     DATA(j,1) = DAT(nn,1)
                     DATA(j,2) = DAT(nn,2)
                     DATA(j,3) = DAT(nn,3)
                  else
                     tspa=(DAT(nn,2)-DAT(nn-1,2))/(DAT(nn,1)-DAT(nn-1,1))
                     tpsb=(DAT(nn+1,2)-DAT(nn-1,2))/(DAT(nn+1,1)-DAT(nn-1,1))
                     tps=abs(abs(tspa-tpsb)-abs(tpsb))
                     if (tps .le. 0.005) then
                        j = j + 1
                        DATA(j,1) = DAT(nn,1)
                        DATA(j,2) = DAT(nn,2)
                        DATA(j,3) = DAT(nn,3)
                     endif
                  endif
!                  counts=counts+1
!                  enddo
               enddo
               if (counts.lt.20) then
                  DAT=DATA
                  DATA=0.
               end if            
               counts=counts+1
               end do
!!!! STABILITY CHECK
               if (( j .eq. 0 )) then
                  write(99,'(a20)') 'no good data in the profile'
               else if ( j .eq. 1 ) then
                  write(99,'(a24)') 'there is only one datum '
               else
                  allocate( bfrq(j) )
                  call bn2g ( j, DATA(1,2), DATA(1,3), DATA(1,1), bfrq)
                  allocate( xx(j) )
                  i = 0
                  do n= 1, j
                     if ( DATA(n,1) .ge. 150 ) then
                        i = i + 1
                        xx(i) = n
                     end if
                  enddo
                  if ( i .gt. 0 ) then
                     A=(xx(1))
                     B=(xx(i))
                     mean=sum(bfrq(A:B))/i
                     limit=sqrt(sum((bfrq(A:B)-mean)**2)/i)
                  else
                     limit=1e-5
                  endif

                  write(99,4) limit

                  do n = 1, j
                     if (bfrq (n) .lt. (-limit)) then
                        write(99,5) n
                     endif
                  enddo
                  M=0
                  do n = 1, j
                     if (bfrq (n) .ge. (-limit)) then
                        M=M+1
                     end if
                  enddo

                  allocate( X(M,3) )

                  i=0
                  do n = 1, j
                     if (bfrq (n) .ge. (-limit)) then
                        i=i+1
                        X(i,:)=DATA(n,:)
                     end if
                  enddo

                  P=0
                  if ( M .ne. 0 .and. M .ne. 1 ) then
                     do i=1, M
                        if (X(i,1).le.150 ) then
                           P=P+1
                        end if
                     enddo
                  end if

                  allocate ( PRO(P,3) )

                  p=0
                  if ( M .ne. 0 .and. M .ne. 1 ) then
                     do i=1, M
                        if ( X(i,1).le.150 ) then
                           p=p+1
                           PRO(p,:)=X(i,:)
                        end if
                     enddo
                  end if

                  Q=0
                  if ( M .ne. 0 .and. M .ne. 1 ) then
                     do i=1, P-1
                        if ( PRO(i+1,1)-PRO(i,1) .ge. 40 ) then
                           Q=Q+1
                        end if
                     enddo
                  end if

                  allocate( PROH(Q,3) )
                  holes=0 
!                  print*,holes 
                  q=0
                  if ( M .ne. 0 .and. M .ne. 1 ) then
                     do i=1, P-1
                        if ( PRO(i+1,1)-PRO(i,1) .ge. 40 ) then
                           holes=1
!                          if (holes .gt. 0) exit
                           q=q+1
                           PROH(q,:)=X(i,:)
                        end if
                     enddo
                  end if
                  print*,holes
!                  print*,X(:,1)
!                  deallocate ( bfrq, xx, X, PRO, PROH )
!                  holess=0
!                  do ag=1,M
!                  do while (holess .eq. 1)
!                  if(X(ag,1).lt.100. .and. (X(ag+1,1)-X(ag,1)).gt.40.) then
!                       holess=1
!                  else
!                       holess=0
!                  endif
!                  enddo
!                  enddo
!                   if (holes .gt. 0.) then
!                     X=9999.
!                  endif 
                  if (holes.lt.1) then
!                     print*,'data lack in the thermocline, &
!                        profile has been deleted'
!                  else
!                     print*,"ok"
                     kmss=M !M invece di Q e X al posto di PROH
                     kmss1=kmss
                     do k=kmss,1,-1
                        if(X(k,2).gt.35. .or. X(k,2).lt.0.0 .or. &
                          X(k,3).gt.45. .or. X(k,3).lt.0.0)then
                           kmss1 = k-1
                        endif
                     enddo
                     if(kmss1.lt.kmss) print*,'The profile is shorter. &
                       New levels are: ', kmss1 
                     kmss=kmss1
                     if(kmss.lt.1) then
                       print*,'Profile rejected: one parameter missing.'
!                        stop
                     endif
!                     do k=1,kmss-1
!                    if(X(k,1).lt.100. .and. (X(k+1,1)-X(k,1)).gt.40.) then
!             print*,'Profile rejected: levels ',X(k,1),'-',X(k+1,1),&
!                    ' missing.'
!                           stop
!                        endif
!                     enddo
                     kkk = 0
! convert into potential temperature
                     hcx=0
                     do k=1,kmss-1
                      if (X(k+1,1)-X(k,1).ge.40) then
                      hcx=1
!                      else
!                      hcx=1
!                      exit 
                      endif
                     enddo
                     print*,hcx
                     do k=1,kmss
                        theta = pot_tem(X(k,2),X(k,3),X(k,1))
                        X(k,2) = theta
                     enddo
!                     read(pln,'(i5)') platn
                     nprf = nprf +1
                     if ( hcx .lt. 1) then
                     print*,"write"
                     if ((X(1,1).lt.40) .and. (kmss.ge.2)) then  
                     do k=1,kmss
                        if ((X(k,1).gt.4.) .and. (X(k,1).lt.1000)) then
                           nvals = nvals + 1
                           inoa(nvals) = 1 
                           para(nvals) = 1
                           lona(nvals) = lon(np)
                           lata(nvals) = lat(np)
                           dpta(nvals) = X(k,1)
                           tima(nvals) = rday - rinday
                           vala(nvals) = X(k,2)
                           erra(nvals) = 0.1
                           erra(nvals) = 0.05
                        endif
                     enddo
                     do k=1,kmss
                        if ((X(k,1).gt.4.) .and. (X(k,1).lt.1000)) then
                           nvals = nvals + 1
                           inoa(nvals) = 1 
                           para(nvals) = 2
                           lona(nvals) = lon(np)
                           lata(nvals) = lat(np)
                           dpta(nvals) = X(k,1)
                           tima(nvals) = rday - rinday
                           vala(nvals) = X(k,3)
                           erra(nvals) = 0.03
                           erra(nvals) = 0.02
                        endif
                    enddo
                  endif
                 endif
                  end if !(continuare da prima di questo endif)
                  deallocate ( bfrq, xx, X, PRO, PROH )
               end if  !(fine stability check)
!               deallocate ( bfrq, xx, X, PRO, PROH )
            else
           write(99,'(a70)') 'no quality control on date or position, &
                    profile skipped ',infile
            end if !(fine check sul JUL e POS QC)
         else
            write(99,'(a70)') 'no good lon, profile ',infile,' skipped'
         end if !(fine check sulla LON )
      end if !(fine check sulla time windows)
!      if (nvals .gt. 0)then
!         do k=1,nvals
!            if (dpta(k).lt.1000) then
!               write(12,"(I5,I4,6f10.5,I8)")       &
!      indx, para(k), lona(k), lata(k), dpta(k), tima(k), vala(k), &
!              erra(k), inoa(k)
!            endif
!         enddo
!      endif
!      deallocate ( bfrq, xx, X, PRO, PROH )
      enddo
!       print*,nvals
      if (nvals .gt. 0)then
         do k=1,nvals
            if (dpta(k).lt.1000) then
               write(12,"(I8,I8,6f10.5)")       &
      inoa(k), para(k), lona(k), lata(k), dpta(k), tima(k), vala(k), &
              erra(k)
            endif
         enddo
      endif
      close(12)
      close(10)
      close(99)
1 format('bad P, T or S quality flag at level' i3)
2 format(a10,1x,a5,1x,f8.4,1x,f8.4,1x,a7,1x,i3)
3 format(f6.2,1x,f12.8,1x,f12.8)
4 format('Stability check: tollerance ',f14.7)
5 format('density instability at level ' i3)
6 format(f7.2,1x,f12.8,1x,f12.8)
7 format('quality control done on file ',a73)
8 format('error at depth ',f7.2)
9 format(i8)
10 format(i8,i8,f10.5,f10.5,f10.5,f10.5,f10.5,f10.5)
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
!----------------------------------------------------------------------
      SUBROUTINE bn2g ( km, tem, sal, dep, bn2)


      INTEGER jj
      REAL zgde3w, zt, zs, zh, zalbet, zbeta
      REAL fsalbt, fsbeta
      REAL pft, pfh
      REAL tem(km), sal(km), dep(km), bn2(km), dz(km)

!---
      fsalbt( pft, pfs, pfh ) =                                           &
        ( ( ( -0.255019e-07 * pft + 0.298357e-05 ) * pft                  &
                                  - 0.203814e-03 ) * pft                  &
                                  + 0.170907e-01 ) * pft                  &
                                  + 0.665157e-01                          &
       +(-0.678662e-05 * pfs - 0.846960e-04 * pft + 0.378110e-02 ) * pfs  &
       +  ( ( - 0.302285e-13 * pfh                                        &
              - 0.251520e-11 * pfs                                        &
              + 0.512857e-12 * pft * pft          ) * pfh                 &
                                   - 0.164759e-06   * pfs                 &
           +(   0.791325e-08 * pft - 0.933746e-06 ) * pft                 &
                                   + 0.380374e-04 ) * pfh

      fsbeta( pft, pfs, pfh ) =                                           &
        ( ( -0.415613e-09 * pft + 0.555579e-07 ) * pft                    &
                                - 0.301985e-05 ) * pft                    &
                                + 0.785567e-03                            &
       +( 0.515032e-08 * pfs + 0.788212e-08 * pft - 0.356603e-06 ) * pfs  &
       +(  (   0.121551e-17 * pfh                                         &
             - 0.602281e-15 * pfs                                         &
             - 0.175379e-14 * pft + 0.176621e-12 ) * pfh                  &
                                  + 0.408195e-10   * pfs                  &
          +( - 0.213127e-11 * pft + 0.192867e-09 ) * pft                  &
                                  - 0.121555e-07 ) * pfh
!---
       do k=1,km-1
          dz(k) = dep(k+1)-dep(k)
          zgde3w = 9.81/dz(k)
          zt = 0.5*( tem(k) + tem(k+1) )
          zs = 0.5*( sal(k) + sal(k+1) ) - 35.0
          zh = 0.5*( dep(k) + dep(k+1) )
          zalbet = fsalbt( zt, zs, zh )
          zbeta  = fsbeta( zt, zs, zh )
          bn2(k) = zgde3w * zbeta                                   &
              * ( zalbet * ( tem(k) - tem(k+1) ) - ( sal(k) - sal(k+1) ) )
       enddo


       END
      real function depth(p,l)
       !! This is to calculate depth in metres from pressure in dbars.
       !! The input data are
       !!       p = Pressure [db]
       !!       l = Latitude in decimal degrees north [-90..+90]
       !! The output is
       !!       depth = depth [metres]

       !! REFERENCES :
       !! Unesco 1983. Algorithms for computation of fundamental properties of
       !! seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.

       real :: pi
       real :: DEG2RAD
       real,parameter:: c1 = +9.72659
       real,parameter:: c2 = -2.2512E-5
       real,parameter:: c3 = +2.279E-10
       real,parameter:: c4 = -1.82E-15
       real,parameter:: gam_dash = 2.184e-6
       real:: X, bot_line, top_line
       real:: p
       double precision:: l, LAT
       pi =  3.1416
       DEG2RAD = pi/180
       LAT = abs(l)
       X = sin(LAT*DEG2RAD) !! convert to radians
       X = X*X
       bot_line = 9.780318*(1.0+(5.2788E-3+2.36E-5*X)*X) + gam_dash*0.5*p
       top_line = (((c4*p+c3)*p+c2)*p+c1)*p
       depth = top_line/bot_line

      return
      end function depth

      real function pressure(d,l)
      !! This is to calculate pressure in dbars in metres.
      !! The input data are
      !!       d = depth [metres]
      !!       l = Latitude in decimal degrees north [-90..+90]
      !! The output is
      !!       pressure = Pressure [db]

      !! REFERENCES :
      !! Saunders, P.M. 1981
      !! "Practical conversion of Pressure to Depth"
      !! Journal of Physical Oceanography, 11, 573-574

      real :: pi
      real :: DEG2RAD
      real :: X,C1
      double precision::l
!!       real :: pressure


      pi =  3.1416
      DEG2RAD = pi/180
      X       = sin(abs(l)*DEG2RAD)  ! convert to radians
      C1      = 5.92E-3+(X**2)*5.25E-3
      pressure = ((1-C1)-sqrt(((1-C1)**2)-(8.84E-6*d)))/4.42E-6

      return
      end function pressure
