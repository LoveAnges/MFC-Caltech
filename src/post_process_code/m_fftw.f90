!!       __  _______________
!!      /  |/  / ____/ ____/
!!     / /|_/ / /_  / /     
!!    / /  / / __/ / /___   
!!   /_/  /_/_/    \____/   
!!                       
!!  This file is part of MFC.
!!
!!  MFC is the legal property of its developers, whose names 
!!  are listed in the copyright file included with this source 
!!  distribution.
!!
!!  MFC is free software: you can redistribute it and/or modify
!!  it under the terms of the GNU General Public License as published 
!!  by the Free Software Foundation, either version 3 of the license 
!!  or any later version.
!!
!!  MFC is distributed in the hope that it will be useful,
!!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!!  GNU General Public License for more details.
!!  
!!  You should have received a copy of the GNU General Public License
!!  along with MFC (LICENSE).  
!!  If not, see <http://www.gnu.org/licenses/>.

!>
!! @file m_fftw.f90
!! @brief Contains module m_fftw
!! @author S. Bryngelson, K. Schimdmayer, V. Coralic, J. Meng, K. Maeda, T. Colonius
!! @version 1.0
!! @date JUNE 06 2019

!> @brief The module contains the subroutines for the FFT routines
MODULE m_fftw

    ! Dependencies =============================================================
    USE, INTRINSIC :: ISO_C_BINDING

    USE m_derived_types        !< Definitions of the derived types
    
    USE m_global_parameters    !< Definitions of the global parameters

    USE m_mpi_proxy            !< Message passing interface (MPI) module proxy
    ! ==========================================================================

    IMPLICIT NONE

    PRIVATE; PUBLIC :: s_initialize_fftw_module,      &
                       s_apply_fourier_decomposition, &
                       s_finalize_fftw_module

    INCLUDE 'fftw3.f03'

    TYPE(C_PTR) :: fwd_plan, bwd_plan
    TYPE(C_PTR) :: fftw_real_data, fftw_cmplx_data, fftw_fltr_cmplx_data
    INTEGER :: real_size, cmplx_size
    ! Real data
    REAL(C_DOUBLE), POINTER :: data_real(:)
    ! Complex data in Fourier space
    COMPLEX(C_DOUBLE_COMPLEX), POINTER :: data_cmplx(:)
    ! Filtered complex data in Fourier space
    COMPLEX(C_DOUBLE_COMPLEX), POINTER :: data_fltr_cmplx(:)

    CONTAINS


        !>  The purpose of this subroutine is to create the fftw plan
        !!      that will be used in the forward and backward DFTs when
        !!      applying the Fourier filter in the azimuthal direction.
        SUBROUTINE s_initialize_fftw_module() ! ----------------------------------

            ! Size of input array going into DFT
            real_size = p+1
            ! Size of output array coming out of DFT
            cmplx_size = (p+1)/2+1

            ! Allocate input and output DFT data sizes
            fftw_real_data       = fftw_alloc_real   (int( real_size, C_SIZE_T))
            fftw_cmplx_data      = fftw_alloc_complex(int(cmplx_size, C_SIZE_T))
            fftw_fltr_cmplx_data = fftw_alloc_complex(int(cmplx_size, C_SIZE_T))
            ! Associate input and output data pointers with allocated memory
            CALL c_f_pointer(fftw_real_data ,      data_real ,      [ real_size])
            CALL c_f_pointer(fftw_cmplx_data,      data_cmplx,      [cmplx_size])
            CALL c_f_pointer(fftw_fltr_cmplx_data, data_fltr_cmplx, [cmplx_size])

            ! Generate plans for forward and backward DFTs
            fwd_plan = fftw_plan_dft_r2c_1d(real_size, data_real      , data_cmplx, FFTW_ESTIMATE)
            bwd_plan = fftw_plan_dft_c2r_1d(real_size, data_fltr_cmplx, data_real , FFTW_ESTIMATE)

        END SUBROUTINE s_initialize_fftw_module ! ------------------------------



        !>  The purpose of this subroutine is to Fourier decompose
        !!      the flow field. Not done in most efficient manner since 
        !!      subroutine is called for every mode, but can deal with 
        !!      efficiency later.
        !!  @param q_sf Scalar field to transform
        !!  @param i Fourier component 
        SUBROUTINE s_apply_fourier_decomposition(q_sf,i) ! -----------------------

            ! Variable to be Fourier decomposed
            REAL(KIND(0d0)), &
            DIMENSION( -offset_x%beg : m+offset_x%end  , &
                       -offset_y%beg : n+offset_y%end  , &
                       -offset_z%beg : p+offset_z%end ), &
            INTENT(INOUT) :: q_sf

            INTEGER, INTENT(IN) :: i

            INTEGER :: j,k

            DO j = -offset_x%beg, m+offset_x%end
                DO k = -offset_y%beg, n+offset_y%end
                    data_fltr_cmplx(:) = (0d0,0d0)
                    data_real(1:p+1) = q_sf(j,k,0:p)
                    CALL fftw_execute_dft_r2c(fwd_plan, data_real, data_cmplx)
                    data_fltr_cmplx(i) = data_cmplx(i)
                    CALL fftw_execute_dft_c2r(bwd_plan, data_fltr_cmplx, data_real)
                    data_real(:) = data_real(:)/REAL(real_size,KIND(0d0))
                    q_sf(j,k,0:p) = data_real(1:p+1)
                END DO
            END DO

            ! Populate offset regions given that domain is azimuthally periodic
            DO j = -offset_z%beg, -1
                q_sf(:,:,j) = q_sf(:,:,(p+1)+j)
            END DO
            DO j = 1, offset_z%end
                q_sf(:,:,p+j) = q_sf(:,:,j-1)
            END DO

        END SUBROUTINE s_apply_fourier_decomposition ! -------------------------




        !>  The purpose of this subroutine is to destroy the fftw plan
        !!      that will be used in the forward and backward DFTs when
        !!      applying the Fourier filter in the azimuthal direction.
        SUBROUTINE s_finalize_fftw_module() ! ------------------------------------

            CALL fftw_free(fftw_real_data)
            CALL fftw_free(fftw_cmplx_data)
            CALL fftw_free(fftw_fltr_cmplx_data)

            CALL fftw_destroy_plan(fwd_plan)
            CALL fftw_destroy_plan(bwd_plan)

        END SUBROUTINE s_finalize_fftw_module ! --------------------------------



END MODULE
