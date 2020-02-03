# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  set USE_BLOGANA [ipgui::add_param $IPINST -name "USE_BLOGANA"]
  set_property tooltip {MITOUJTAG用ロジアナIPを有効にします} ${USE_BLOGANA}
  ipgui::add_param $IPINST -name "AXI_ID_WIDTH"
  ipgui::add_param $IPINST -name "WR_START_ADDR"
  ipgui::add_param $IPINST -name "WR_LENGTH"
  set WR_TYPE [ipgui::add_param $IPINST -name "WR_TYPE" -widget comboBox]
  set_property tooltip {Write data type} ${WR_TYPE}

}

proc update_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to update AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to validate AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.USE_BLOGANA { PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to update USE_BLOGANA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_BLOGANA { PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to validate USE_BLOGANA
	return true
}

proc update_PARAM_VALUE.WR_LENGTH { PARAM_VALUE.WR_LENGTH } {
	# Procedure called to update WR_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WR_LENGTH { PARAM_VALUE.WR_LENGTH } {
	# Procedure called to validate WR_LENGTH
	return true
}

proc update_PARAM_VALUE.WR_START_ADDR { PARAM_VALUE.WR_START_ADDR } {
	# Procedure called to update WR_START_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WR_START_ADDR { PARAM_VALUE.WR_START_ADDR } {
	# Procedure called to validate WR_START_ADDR
	return true
}

proc update_PARAM_VALUE.WR_TYPE { PARAM_VALUE.WR_TYPE } {
	# Procedure called to update WR_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WR_TYPE { PARAM_VALUE.WR_TYPE } {
	# Procedure called to validate WR_TYPE
	return true
}


proc update_MODELPARAM_VALUE.USE_BLOGANA { MODELPARAM_VALUE.USE_BLOGANA PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_BLOGANA}] ${MODELPARAM_VALUE.USE_BLOGANA}
}

proc update_MODELPARAM_VALUE.AXI_ID_WIDTH { MODELPARAM_VALUE.AXI_ID_WIDTH PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ID_WIDTH}] ${MODELPARAM_VALUE.AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.WR_START_ADDR { MODELPARAM_VALUE.WR_START_ADDR PARAM_VALUE.WR_START_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WR_START_ADDR}] ${MODELPARAM_VALUE.WR_START_ADDR}
}

proc update_MODELPARAM_VALUE.WR_LENGTH { MODELPARAM_VALUE.WR_LENGTH PARAM_VALUE.WR_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WR_LENGTH}] ${MODELPARAM_VALUE.WR_LENGTH}
}

proc update_MODELPARAM_VALUE.WR_TYPE { MODELPARAM_VALUE.WR_TYPE PARAM_VALUE.WR_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WR_TYPE}] ${MODELPARAM_VALUE.WR_TYPE}
}

