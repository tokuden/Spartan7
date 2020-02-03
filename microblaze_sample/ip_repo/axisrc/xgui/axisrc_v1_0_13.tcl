# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  set USE_BLOGANA [ipgui::add_param $IPINST -name "USE_BLOGANA"]
  set_property tooltip {MITOUJTAG用ロジアナIPを有効にします} ${USE_BLOGANA}

}

proc update_PARAM_VALUE.USE_BLOGANA { PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to update USE_BLOGANA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_BLOGANA { PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to validate USE_BLOGANA
	return true
}


proc update_MODELPARAM_VALUE.USE_BLOGANA { MODELPARAM_VALUE.USE_BLOGANA PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_BLOGANA}] ${MODELPARAM_VALUE.USE_BLOGANA}
}

