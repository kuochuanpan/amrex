
module amrex_mlebabeclap_2d_module

  use amrex_error_module
  use amrex_constants_module, only : zero, one
  use amrex_fort_module, only : amrex_real
  use amrex_ebcellflag_module, only : is_regular_cell, is_covered_cell, is_single_valued_cell, &
       get_neighbor_cells_int_single
  implicit none

  private
  public :: amrex_mlebabeclap_adotx, amrex_mlebabeclap_gsrb, amrex_mlebabeclap_normalize, &
       amrex_eb_mg_interp

contains

  subroutine amrex_mlebabeclap_adotx(lo, hi, y, ylo, yhi, x, xlo, xhi, a, alo, ahi, &
       bx, bxlo, bxhi, by, bylo, byhi, ccm, cmlo, cmhi, flag, flo, fhi, vfrc, vlo, vhi, &
       apx, axlo, axhi, apy, aylo, ayhi, fcx, cxlo, cxhi, fcy, cylo, cyhi, &
       dxinv, alpha, beta) &
       bind(c,name='amrex_mlebabeclap_adotx')
    integer, dimension(2), intent(in) :: lo, hi, ylo, yhi, xlo, xhi, alo, ahi, bxlo, bxhi, bylo, byhi, &
         cmlo, cmhi, flo, fhi, vlo, vhi, axlo, axhi, aylo, ayhi, cxlo, cxhi, cylo, cyhi
    real(amrex_real), intent(in) :: dxinv(2)
    real(amrex_real), value, intent(in) :: alpha, beta
    real(amrex_real), intent(inout) ::    y( ylo(1): yhi(1), ylo(2): yhi(2))
    real(amrex_real), intent(in   ) ::    x( xlo(1): xhi(1), xlo(2): xhi(2))
    real(amrex_real), intent(in   ) ::    a( alo(1): ahi(1), alo(2): ahi(2))
    real(amrex_real), intent(in   ) ::   bx(bxlo(1):bxhi(1),bxlo(2):bxhi(2))
    real(amrex_real), intent(in   ) ::   by(bylo(1):byhi(1),bylo(2):byhi(2))
    integer         , intent(in   ) ::  ccm(cmlo(1):cmhi(1),cmlo(2):cmhi(2))
    integer         , intent(in   ) :: flag( flo(1): fhi(1), flo(2): fhi(2))
    real(amrex_real), intent(in   ) :: vfrc( vlo(1): vhi(1), vlo(2): vhi(2))
    real(amrex_real), intent(in   ) ::  apx(axlo(1):axhi(1),axlo(2):axhi(2))
    real(amrex_real), intent(in   ) ::  apy(aylo(1):ayhi(1),aylo(2):ayhi(2))
    real(amrex_real), intent(in   ) ::  fcx(cxlo(1):cxhi(1),cxlo(2):cxhi(2))
    real(amrex_real), intent(in   ) ::  fcy(cylo(1):cyhi(1),cylo(2):cyhi(2))
    integer :: i,j, ii, jj
    real(amrex_real) :: dhx, dhy, fxm, fxp, fym, fyp, fracx, fracy

    dhx = beta*dxinv(1)*dxinv(1)
    dhy = beta*dxinv(2)*dxinv(2)
    
    do    j = lo(2), hi(2)
       do i = lo(1), hi(1)
          if (is_covered_cell(flag(i,j))) then
             y(i,j) = zero
          else if (is_regular_cell(flag(i,j))) then
             y(i,j) = alpha*a(i,j)*x(i,j) &
                  - dhx * (bX(i+1,j)*(x(i+1,j) - x(i  ,j))  &
                  &      - bX(i  ,j)*(x(i  ,j) - x(i-1,j))) &
                  - dhy * (bY(i,j+1)*(x(i,j+1) - x(i,j  ))  &
                  &      - bY(i,j  )*(x(i,j  ) - x(i,j-1)))
          else
             fxm = bX(i,j)*(x(i,j)-x(i-1,j))
             if (apx(i,j).ne.zero .and. apx(i,j).ne.one) then
                jj = j + int(sign(one,fcx(i,j)))
                fracy = abs(fcx(i,j))*real(ior(ccm(i-1,jj),ccm(i,jj)),amrex_real)
                fxm = (one-fracy)*fxm + fracy*bX(i,jj)*(x(i,jj)-x(i-1,jj))
             end if

             fxp = bX(i+1,j)*(x(i+1,j)-x(i,j))
             if (apx(i+1,j).ne.zero .and. apx(i+1,j).ne.one) then
                jj = j + int(sign(one,fcx(i+1,j)))
                fracy = abs(fcx(i+1,j))*real(ior(ccm(i,jj),ccm(i+1,jj)),amrex_real)
                fxp = (one-fracy)*fxp + fracy*bX(i+1,jj)*(x(i+1,jj)-x(i,jj))
             end if

             fym = bY(i,j)*(x(i,j)-x(i,j-1))
             if (apy(i,j).ne.zero .and. apy(i,j).ne.one) then
                ii = i + int(sign(one,fcy(i,j)))
                fracx = abs(fcy(i,j))*real(ior(ccm(ii,j-1),ccm(ii,j)),amrex_real)
                fym = (one-fracx)*fym + fracx*bY(ii,j)*(x(ii,j)-x(ii,j-1))
             end if

             fyp = bY(i,j+1)*(x(i,j+1)-x(i,j))
             if (apy(i,j+1).ne.zero .and. apy(i,j+1).ne.one) then
                ii = i + int(sign(one,fcy(i,j+1)))
                fracx = abs(fcy(i,j+1))*real(ior(ccm(ii,j),ccm(ii,j+1)),amrex_real)
                fyp = (one-fracx)*fyp + fracx*bY(ii,j+1)*(x(ii,j+1)-x(ii,j))
             end if

             y(i,j) = alpha*a(i,j)*x(i,j) + (one/vfrc(i,j)) * &
                  (dhx*(apx(i,j)*fxm-apx(i+1,j)*fxp) + dhy*(apy(i,j)*fym-apy(i,j+1)*fyp))
          end if
       end do
    end do
  end subroutine amrex_mlebabeclap_adotx


  subroutine amrex_mlebabeclap_gsrb(lo, hi, phi, hlo, hhi, rhs, rlo, rhi, a, alo, ahi, &
       bx, bxlo, bxhi, by, bylo, byhi, &
       ccm, cmlo, cmhi, &
       m0, m0lo, m0hi, m2, m2lo, m2hi, &
       m1, m1lo, m1hi, m3, m3lo, m3hi, &
       f0, f0lo, f0hi, f2, f2lo, f2hi, &
       f1, f1lo, f1hi, f3, f3lo, f3hi, &
       flag, flo, fhi, vfrc, vlo, vhi, &
       apx, axlo, axhi, apy, aylo, ayhi, fcx, cxlo, cxhi, fcy, cylo, cyhi, &
       dxinv, alpha, beta, redblack) &
       bind(c,name='amrex_mlebabeclap_gsrb')
    integer, dimension(2), intent(in) :: lo, hi, hlo, hhi, rlo, rhi, alo, ahi, bxlo, bxhi, bylo, byhi, &
         cmlo, cmhi, m0lo, m0hi, m1lo, m1hi, m2lo, m2hi, m3lo, m3hi, &
         f0lo, f0hi, f1lo, f1hi, f2lo, f2hi, f3lo, f3hi, &
         flo, fhi, vlo, vhi, axlo, axhi, aylo, ayhi, cxlo, cxhi, cylo, cyhi
    real(amrex_real), intent(in) :: dxinv(2)
    real(amrex_real), value, intent(in) :: alpha, beta
    integer, value, intent(in) :: redblack
    real(amrex_real), intent(inout) ::  phi( hlo(1): hhi(1), hlo(2): hhi(2))
    real(amrex_real), intent(in   ) ::  rhs( rlo(1): rhi(1), rlo(2): rhi(2))
    real(amrex_real), intent(in   ) ::    a( alo(1): ahi(1), alo(2): ahi(2))
    real(amrex_real), intent(in   ) ::   bx(bxlo(1):bxhi(1),bxlo(2):bxhi(2))
    real(amrex_real), intent(in   ) ::   by(bylo(1):byhi(1),bylo(2):byhi(2))
    integer         , intent(in   ) ::  ccm(cmlo(1):cmhi(1),cmlo(2):cmhi(2))
    integer         , intent(in   ) ::   m0(m0lo(1):m0hi(1),m0lo(2):m0hi(2))
    integer         , intent(in   ) ::   m1(m1lo(1):m1hi(1),m1lo(2):m1hi(2))
    integer         , intent(in   ) ::   m2(m2lo(1):m2hi(1),m2lo(2):m2hi(2))
    integer         , intent(in   ) ::   m3(m3lo(1):m3hi(1),m3lo(2):m3hi(2))
    real(amrex_real), intent(in   ) ::   f0(f0lo(1):f0hi(1),f0lo(2):f0hi(2))
    real(amrex_real), intent(in   ) ::   f1(f1lo(1):f1hi(1),f1lo(2):f1hi(2))
    real(amrex_real), intent(in   ) ::   f2(f2lo(1):f2hi(1),f2lo(2):f2hi(2))
    real(amrex_real), intent(in   ) ::   f3(f3lo(1):f3hi(1),f3lo(2):f3hi(2))
    integer         , intent(in   ) :: flag( flo(1): fhi(1), flo(2): fhi(2))
    real(amrex_real), intent(in   ) :: vfrc( vlo(1): vhi(1), vlo(2): vhi(2))
    real(amrex_real), intent(in   ) ::  apx(axlo(1):axhi(1),axlo(2):axhi(2))
    real(amrex_real), intent(in   ) ::  apy(aylo(1):ayhi(1),aylo(2):ayhi(2))
    real(amrex_real), intent(in   ) ::  fcx(cxlo(1):cxhi(1),cxlo(2):cxhi(2))
    real(amrex_real), intent(in   ) ::  fcy(cylo(1):cyhi(1),cylo(2):cyhi(2))

    integer :: i,j,ioff,ii,jj
    real(amrex_real) :: cf0, cf1, cf2, cf3, delta, gamma, rho, res
    real(amrex_real) :: dhx, dhy, fxm, fxp, fym, fyp, fracx, fracy
    real(amrex_real) :: sxm, sxp, sym, syp, oxm, oxp, oym, oyp
    real(amrex_real), parameter :: omega = 1._amrex_real

    dhx = beta*dxinv(1)*dxinv(1)
    dhy = beta*dxinv(2)*dxinv(2)

    do j = lo(2), hi(2)
       ioff = mod(lo(1)+j+redblack,2)
       do i = lo(1)+ioff, hi(1), 2

          if (is_covered_cell(flag(i,j))) then
             phi(i,j) = zero
          else
             cf0 = merge(f0(lo(1),j), 0.0D0, &
                  (i .eq. lo(1)) .and. (m0(lo(1)-1,j).gt.0))
             cf1 = merge(f1(i,lo(2)), 0.0D0, &
                  (j .eq. lo(2)) .and. (m1(i,lo(2)-1).gt.0))
             cf2 = merge(f2(hi(1),j), 0.0D0, &
                  (i .eq. hi(1)) .and. (m2(hi(1)+1,j).gt.0))
             cf3 = merge(f3(i,hi(2)), 0.0D0, &
                  (j .eq. hi(2)) .and. (m3(i,hi(2)+1).gt.0))
             
             if (is_regular_cell(flag(i,j))) then
                
                gamma = alpha*a(i,j) &
                     + dhx * (bX(i+1,j) + bX(i,j)) &
                     + dhy * (bY(i,j+1) + bY(i,j))
                
                rho =  dhx * (bX(i+1,j)*phi(i+1,j) + bX(i,j)*phi(i-1,j)) &
                     + dhy * (bY(i,j+1)*phi(i,j+1) + bY(i,j)*phi(i,j-1))

                delta = dhx*(bX(i,j)*cf0 + bX(i+1,j)*cf2) &
                     +  dhy*(bY(i,j)*cf1 + bY(i,j+1)*cf3)
             
             else
                fxm = -bX(i,j)*phi(i-1,j)
                oxm = -bX(i,j)*cf0
                sxm =  bX(i,j)
                if (apx(i,j).ne.zero .and. apx(i,j).ne.one) then
                   jj = j + int(sign(one,fcx(i,j)))
                   fracy = abs(fcx(i,j))*real(ior(ccm(i-1,jj),ccm(i,jj)),amrex_real)
                   fxm = (one-fracy)*fxm + fracy*bX(i,jj)*(phi(i,jj)-phi(i-1,jj))
                   ! oxm = (one-fracy)*oxm
                   oxm = zero
                   sxm = (one-fracy)*sxm
                end if
                
                fxp =  bX(i+1,j)*phi(i+1,j)
                oxp =  bX(i+1,j)*cf2
                sxp = -bX(i+1,j)
                if (apx(i+1,j).ne.zero .and. apx(i+1,j).ne.one) then
                   jj = j + int(sign(one,fcx(i+1,j)))
                   fracy = abs(fcx(i+1,j))*real(ior(ccm(i,jj),ccm(i+1,jj)),amrex_real)
                   fxp = (one-fracy)*fxp + fracy*bX(i+1,jj)*(phi(i+1,jj)-phi(i,jj))
                   ! oxp = (one-fracy)*oxp
                   oxp = zero
                   sxp = (one-fracy)*sxp
                end if
                
                fym = -bY(i,j)*phi(i,j-1)
                oym = -bY(i,j)*cf1
                sym =  bY(i,j)
                if (apy(i,j).ne.zero .and. apy(i,j).ne.one) then
                   ii = i + int(sign(one,fcy(i,j)))
                   fracx = abs(fcy(i,j))*real(ior(ccm(ii,j-1),ccm(ii,j)),amrex_real)
                   fym = (one-fracx)*fym + fracx*bY(ii,j)*(phi(ii,j)-phi(ii,j-1))
                   ! oym = (one-fracx)*oym
                   oym = zero
                   sym = (one-fracx)*sym
                end if
                
                fyp =  bY(i,j+1)*phi(i,j+1)
                oyp =  bY(i,j+1)*cf3
                syp = -bY(i,j+1)
                if (apy(i,j+1).ne.zero .and. apy(i,j+1).ne.one) then
                   ii = i + int(sign(one,fcy(i,j+1)))
                   fracx = abs(fcy(i,j+1))*real(ior(ccm(ii,j),ccm(ii,j+1)),amrex_real)
                   fyp = (one-fracx)*fyp + fracx*bY(ii,j+1)*(phi(ii,j+1)-phi(ii,j))
                   ! oyp = (one-fracx)*fyp
                   oyp = zero
                   syp = (one-fracx)*syp
                end if
                
                gamma = alpha*a(i,j) + (one/vfrc(i,j)) * &
                     (dhx*(apx(i,j)*sxm-apx(i+1,j)*sxp) + dhy*(apy(i,j)*sym-apy(i,j+1)*syp))
                rho = -(one/vfrc(i,j)) * &
                     (dhx*(apx(i,j)*fxm-apx(i+1,j)*fxp) + dhy*(apy(i,j)*fym-apy(i,j+1)*fyp))

                delta = -(one/vfrc(i,j)) * &
                     (dhx*(apx(i,j)*oxm-apx(i+1,j)*oxp) + dhy*(apy(i,j)*oym-apy(i,j+1)*oyp))
             end if

             res = rhs(i,j) - (gamma*phi(i,j) - rho)
             phi(i,j) = phi(i,j) + omega*res/(gamma-delta)
          end if
       end do
    end do

  end subroutine amrex_mlebabeclap_gsrb


  subroutine amrex_mlebabeclap_normalize (lo, hi, x, xlo, xhi, a, alo, ahi, &
       bx, bxlo, bxhi, by, bylo, byhi, ccm, cmlo, cmhi, flag, flo, fhi, vfrc, vlo, vhi, &
       apx, axlo, axhi, apy, aylo, ayhi, fcx, cxlo, cxhi, fcy, cylo, cyhi, &
       dxinv, alpha, beta) &
       bind(c,name='amrex_mlebabeclap_normalize')
    integer, dimension(2), intent(in) :: lo, hi, xlo, xhi, alo, ahi, bxlo, bxhi, bylo, byhi, &
         cmlo, cmhi, flo, fhi, vlo, vhi, axlo, axhi, aylo, ayhi, cxlo, cxhi, cylo, cyhi
    real(amrex_real), intent(in) :: dxinv(2)
    real(amrex_real), value, intent(in) :: alpha, beta
    real(amrex_real), intent(inout) ::    x( xlo(1): xhi(1), xlo(2): xhi(2))
    real(amrex_real), intent(in   ) ::    a( alo(1): ahi(1), alo(2): ahi(2))
    real(amrex_real), intent(in   ) ::   bx(bxlo(1):bxhi(1),bxlo(2):bxhi(2))
    real(amrex_real), intent(in   ) ::   by(bylo(1):byhi(1),bylo(2):byhi(2))
    integer         , intent(in   ) ::  ccm(cmlo(1):cmhi(1),cmlo(2):cmhi(2))
    integer         , intent(in   ) :: flag( flo(1): fhi(1), flo(2): fhi(2))
    real(amrex_real), intent(in   ) :: vfrc( vlo(1): vhi(1), vlo(2): vhi(2))
    real(amrex_real), intent(in   ) ::  apx(axlo(1):axhi(1),axlo(2):axhi(2))
    real(amrex_real), intent(in   ) ::  apy(aylo(1):ayhi(1),aylo(2):ayhi(2))
    real(amrex_real), intent(in   ) ::  fcx(cxlo(1):cxhi(1),cxlo(2):cxhi(2))
    real(amrex_real), intent(in   ) ::  fcy(cylo(1):cyhi(1),cylo(2):cyhi(2))

    integer :: i,j,ii,jj
    real(amrex_real) :: dhx, dhy, sxm, sxp, sym, syp, gamma, fracx, fracy

    dhx = beta*dxinv(1)*dxinv(1)
    dhy = beta*dxinv(2)*dxinv(2)

    do    j = lo(2), hi(2)
       do i = lo(1), hi(1)
          if (is_regular_cell(flag(i,j))) then
             x(i,j) = x(i,j) / (alpha*a(i,j) + dhx*(bX(i,j)+bX(i+1,j)) &
                  &                          + dhy*(bY(i,j)+bY(i,j+1)))
          else if (is_single_valued_cell(flag(i,j))) then

             sxm =  bX(i,j)
             if (apx(i,j).ne.zero .and. apx(i,j).ne.one) then
                jj = j + int(sign(one,fcx(i,j)))
                fracy = abs(fcx(i,j))*real(ior(ccm(i-1,jj),ccm(i,jj)),amrex_real)
                sxm = (one-fracy)*sxm
             end if
                
             sxp = -bX(i+1,j)
             if (apx(i+1,j).ne.zero .and. apx(i+1,j).ne.one) then
                jj = j + int(sign(one,fcx(i+1,j)))
                fracy = abs(fcx(i+1,j))*real(ior(ccm(i,jj),ccm(i+1,jj)),amrex_real)
                sxp = (one-fracy)*sxp
             end if
                
             sym =  bY(i,j)
             if (apy(i,j).ne.zero .and. apy(i,j).ne.one) then
                ii = i + int(sign(one,fcy(i,j)))
                fracx = abs(fcy(i,j))*real(ior(ccm(ii,j-1),ccm(ii,j)),amrex_real)
                sym = (one-fracx)*sym
             end if
                
             syp = -bY(i,j+1)
             if (apy(i,j+1).ne.zero .and. apy(i,j+1).ne.one) then
                ii = i + int(sign(one,fcy(i,j+1)))
                fracx = abs(fcy(i,j+1))*real(ior(ccm(ii,j),ccm(ii,j+1)),amrex_real)
                syp = (one-fracx)*syp
             end if

             gamma = alpha*a(i,j) + (one/vfrc(i,j)) * &
                  (dhx*(apx(i,j)*sxm-apx(i+1,j)*sxp) + dhy*(apy(i,j)*sym-apy(i,j+1)*syp))

             x(i,j) = x(i,j) / gamma
          end if
       end do
    end do
  end subroutine amrex_mlebabeclap_normalize


  subroutine amrex_eb_mg_interp (lo, hi, fine, flo, fhi, crse, clo, chi, flag, glo, ghi, ncomp) &
       bind(c,name='amrex_eb_mg_interp')
    integer, dimension(2), intent(in) :: lo, hi, flo, fhi, clo, chi, glo, ghi
    integer, intent(in) :: ncomp
    real(amrex_real), intent(inout) :: fine(flo(1):fhi(1),flo(2):fhi(2),ncomp)
    real(amrex_real), intent(in   ) :: crse(clo(1):chi(1),clo(2):chi(2),ncomp)
    integer         , intent(in   ) :: flag(glo(1):ghi(1),glo(2):ghi(2))

    integer :: i,j,ii,jj,n

    do n = 1, ncomp
       do j = lo(2), hi(2)
          do i = lo(1), hi(1)

             ii = 2*i
             jj = 2*j
             if (.not.is_covered_cell(flag(ii,jj))) then
                fine(ii,jj,n) = fine(ii,jj,n) + crse(i,j,n)
             end if

             ii = 2*i+1
             jj = 2*j
             if (.not.is_covered_cell(flag(ii,jj))) then
                fine(ii,jj,n) = fine(ii,jj,n) + crse(i,j,n)
             end if

             ii = 2*i
             jj = 2*j+1
             if (.not.is_covered_cell(flag(ii,jj))) then
                fine(ii,jj,n) = fine(ii,jj,n) + crse(i,j,n)
             end if

             ii = 2*i+1
             jj = 2*j+1
             if (.not.is_covered_cell(flag(ii,jj))) then
                fine(ii,jj,n) = fine(ii,jj,n) + crse(i,j,n)
             end if

          end do
       end do
    end do

  end subroutine amrex_eb_mg_interp

end module amrex_mlebabeclap_2d_module