#! /bin/ksh

initSetup(){
  defaultFDCLM="/daten01/z4/database"
  defaultFDCOS="/daten01/z4/database/cosmo/int2lm_output"
  defaultFDOAS="/daten01/z4/database/oasis3/mapping_matrix_NRW"
  defaultFDPFL="/daten01/z4/database/ParFlow/Rur_NRW"


  defaultNLCLM=$rootdir/bldsva/setups/nrw/lnd.stdin 
  defaultNLCOS=$rootdir/bldsva/setups/nrw/lmrun_uc 
  defaultNLPFL=$rootdir/bldsva/setups/nrw/coup_oas.tcl


  defaultNppn=64
  defaultCLMProcX=4
  defaultCLMProcY=2
  defaultCOSProcX=10
  defaultCOSProcY=8
  defaultPFLProcX=6
  defaultPFLProcY=6

  defaultStartDate="2008-05-08 00"
  defaultRestDate=""
  defaultRunhours=3

  gx_clm=300
  gy_clm=300
  dt_clm=900
  res="0300x0300"

  gx_cos=150
  gy_cos=150
  dt_cos=10
  nbndlines=4

  gx_pfl=300
  gy_pfl=300
  dt_pfl=0.25
  pflrunname="rurlaf"

  cplfreq1=900
  cplfreq2=900


  if [[ $withPFL == "false" && $withCOS == "true" ]]; then
    defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_cos_clm
  fi	
  if [[ $withPFL == "true" && $withCOS == "false" ]]; then
    defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_pfl_clm
  fi
  if [[ $withPFL == "true" && $withCOS == "true" ]]; then
    defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_cos_clm_pfl
  fi

  fn_finidat="$WORK/tsmp/TSMPForecastNRW$restDate-00/run/clmoas.clm2.r.${yyyy}-${mm}-${dd}-00000.nc"
  pfbfilename="/work/slts/slts06/tsmp/TSMPForecastNRW$restDate-00/run/rurlaf.out.press.00024.pfb"

}

finalizeSetup(){
route "${cblue}>> finalizeSetup${cnormal}"
  comment "   copy clmgrid into rundir"
    cp $forcingdir_clm/clm3.5/Rur_NRW/grid* $rundir/clmgrid.nc >> $log_file 2>> $err_file
  check  
  if [[ $withOAS == "true" ]] then
    comment "   copy oasis remappingfiles into rundir"
      cp $forcingdir_oas/* $rundir >> $log_file 2>> $err_file
    check
    if [[ $withOASMCT == "true" ]] then
      for x in $rundir/*BILINEA* ;do 
        comment "   rename oasis3 remapping files" 
          mv $x $(echo $x | sed "s/BILINEA/BILINEAR/") >> $log_file 2>> $err_file
        check 
      done
    fi  
  fi  

  if [[ $withPFL == "true" ]] then


        comment "   cd to rundir"
          cd $rundir >> $log_file 2>> $err_file
        check

        comment "   copy slopes and slope script into rundir"
          cp $forcingdir_pfl/Rur_300X300_Slopes/ascii2pfb.tcl $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
          cp $forcingdir_pfl/Rur_300X300_Slopes/*slope.pfb $rundir >> $log_file 2>> $err_file
	check
          chmod u+w $rundir/*slope*  $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
        check
	comment "   sed procs into slopescript"
          sed "s,lappend auto_path.*,lappend auto_path $pfldir/bin," -i $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
          sed "s,pfset Process\.Topology\.P.*,pfset Process\.Topology\.P $px_pfl," -i $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
          sed "s,pfset Process\.Topology\.Q.*,pfset Process\.Topology\.Q $py_pfl," -i $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
	comment "   create sloap pfb with tclsh"
          tclsh ./ascii2pfb.tcl >> $log_file 2>> $err_file
	check		
	
	comment "   copy soilind and soilind script into rundir"
          cp $forcingdir_pfl/Rur_300X300_SoilInd/ascii2pfb.tcl $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
          cp $forcingdir_pfl/Rur_300X300_SoilInd/rurSoil.sa $rundir >> $log_file 2>> $err_file
	check
          chmod u+w $rundir/rurSoil.sa $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
        check
	comment "   sed procs into soilindscript"
          sed "s,lappend auto_path.*,lappend auto_path $pfldir/bin," -i $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
          sed "s,pfset Process\.Topology\.P.*,pfset Process\.Topology\.P $px_pfl," -i $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
          sed "s,pfset Process\.Topology\.Q.*,pfset Process\.Topology\.Q $px_pfl," -i $rundir/ascii2pfb.tcl >> $log_file 2>> $err_file
	check
	comment "   create soilInd pfb with tclsh"
        tclsh ./ascii2pfb.tcl >> $log_file 2>> $err_file
	check
  fi 
route "${cblue}<< finalizeSetup${cnormal}"
}
