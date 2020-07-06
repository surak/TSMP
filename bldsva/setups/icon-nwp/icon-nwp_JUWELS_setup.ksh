#! /bin/ksh

initSetup(){
  source /gpfs/software/juwels/lmod/lmod/init/ksh
#  module load GCC ParaStationMPI CDO NCO

  defaultFDICON="/p/scratch/cslts/ghasemi1/tsmp_icon205/shared_cunbo"
#  iconsrc=$rootdir/${mList[2]}_${platform}_${version}_${combination}
#  iconforcing=$defaultFDICON
#  mpiPath=$defaultMpiPath
#  defaultNLICON="$rootdir/bldsva/setups/icon-nwp"

#  gicon=$(find $defaultFDICON -name torus_\*.nc)

#  if [ "$gicon"x == "x" ]; then
#    echo "  ERROR: Please provide ICON grid torus_*.nc in $defaultFDICON."
#    exit 1
#  fi

#  comment "  copy icon run script to:: ${rundir} "
#    cp $iconsrc/run/exp.icon-lam_nwp1nest_20160606.run $rundir/ >> $log_file 2>> $err_file
#  check


  defaultNppn=24
  defaultICONProc=364

  defaultStartDate="2008-05-08 06"
  defaultInitDate="2008-05-08 06"
  defaultRunhours=1
  defaultEndDate="$(date -d "${defaultInitDate[0]} $defaultRunhours hours" "+%Y-%m-%d %H")"

}

finalizeSetup(){
route "${cblue}>> finalizeSetup${cnormal}"

route "${cblue}<< finalizeSetup${cnormal}"
}
