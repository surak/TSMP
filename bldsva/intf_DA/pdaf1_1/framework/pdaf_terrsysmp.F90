!-------------------------------------------------------------------------------------------
!Copyright (c) 2013-2016 by Wolfgang Kurtz and Guowei He (Forschungszentrum Juelich GmbH)
!
!This file is part of TerrSysMP-PDAF
!
!TerrSysMP-PDAF is free software: you can redistribute it and/or modify
!it under the terms of the GNU Lesser General Public License as published by
!the Free Software Foundation, either version 3 of the License, or
!(at your option) any later version.
!
!TerrSysMP-PDAF is distributed in the hope that it will be useful,
!but WITHOUT ANY WARRANTY; without even the implied warranty of
!MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!GNU LesserGeneral Public License for more details.
!
!You should have received a copy of the GNU Lesser General Public License
!along with TerrSysMP-PDAF.  If not, see <http://www.gnu.org/licenses/>.
!-------------------------------------------------------------------------------------------
!
!
!-------------------------------------------------------------------------------------------
!pdaf_terrsysmp.F90: Driver program for TerrSysMP-PDAF
!-------------------------------------------------------------------------------------------

program pdaf_terrsysmp
    use mod_parallel_pdaf, only : task_id,COMM_couple
    use mod_parallel_model, &
        only : mype_model, npes_model, mype_world, &
        !da_interval, total_steps, npes_parflow, comm_model, &
        total_steps, npes_parflow, comm_model, &
        !mpi_comm_world, mpi_success, model, tcycle
        model, tcycle
    use mod_tsmp

#if (defined CLMSA)
    use enkf_clm_mod, only: da_comm, statcomm, update_clm, clmupdate_swc, clmprint_et
    use mod_clm_statistics
#elif (defined COUP_OAS_PFL || defined COUP_OAS_COS)
!#else
    use enkf_clm_mod,only: statcomm, clmprint_et
    use mod_clm_statistics
#endif

#if (defined COUP_OAS_COS)
    use data_parallel, only: cosmo_input_suffix
#endif

    implicit none

    integer :: ierror
    integer :: size

    ! initialize mpi
    call mpi_init(ierror)

    ! intitialize parallel pdaf (communicators et al.)
    call init_parallel_pdaf(0, 1)

    ! set certain variables in component models
#if (defined CLMSA)
    da_comm = comm_model 
#endif

#if (defined COUP_OAS_COS)
    if(mype_model.ge.(nprocpf+nprocclm)) then
        cosmo_input_suffix = task_id-1
    end if
#endif

    ! initialize TerrSysMP instances
    call initialize_tsmp()

    ! initialize pdaf variables
    call init_pdaf()

    ! barrier before model integration starts
    ! call MPI_BARRIER(MPI_COMM_WORLD, IERROR)
    ! if (ierror .ne. MPI_SUCCESS) then
    !     print *, "barrier failed"
    ! end if
    if (mype_world == 0) then
        !print *, "model init finished. nsteps", total_steps
    end if

    ! hand over comm_couple to clm
    if (model .eq. tag_model_clm) then 
      !call clm_statcomm
#if (defined CLMSA || defined COUP_OAS_PFL)
      !write(*,*) 'initialize statcomm (CLM) with COMM_couple'
      statcomm = COMM_couple
#endif
    end if 

    ! time loop
    !do tcycle = 0, total_steps / da_interval - 1
    do tcycle = 1, total_steps
        if (mype_world > -1) then
            !print *, "time loop", tcycle
        endif
        call integrate_tsmp()

        call assimilate_pdaf()
        
        !call MPI_BARRIER(MPI_COMM_WORLD, IERROR)
        !print *,"Finished assimilation", tcycle

        !call print_update_pfb()
#if defined CLMSA
        if((model.eq.tag_model_clm).and.(clmupdate_swc.ne.0)) then
          call update_clm()
          call print_update_clm(tcycle,total_steps)
        endif
        !print *,"Finished printing updated values"
#else
        call update_tsmp()
#endif

        ! print et statistics
#if !defined PARFLOW_STAND_ALONE
        if(model.eq.tag_model_clm .and. clmprint_et.eq.1) call write_clm_statistics(tcycle,total_steps)
#endif
        !print *,"Finished update_tsmp()"

        !call MPI_BARRIER(MPI_COMM_WORLD, IERROR)
        !print *,"Finished complete assimilation cycle", tcycle
    enddo

    ! barrier after model integrations
    !call MPI_BARRIER(MPI_COMM_WORLD, IERROR)
    !print *, "pdaf: advancing finished, rank ", mype_world

    ! close pdaf
    call finalize_pdaf()
    !print *, "pdaf: finalized, rank ", mype_world

    ! close model instances
    call finalize_tsmp()
    !call MPI_BARRIER(MPI_COMM_WORLD, IERROR)
    !print *, "model: finalized, rank ", mype_world

    ! close mpi
    call mpi_finalize(ierror)

end program pdaf_terrsysmp
