# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXI_ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BRAM_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FLAG_NUM_AXI" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FLAG_NUM_BRAM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FLAG_NUM_IREG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_IREGS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "USE_BLOGANA" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to update AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to validate AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.BRAM_ADDR_WIDTH { PARAM_VALUE.BRAM_ADDR_WIDTH } {
	# Procedure called to update BRAM_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRAM_ADDR_WIDTH { PARAM_VALUE.BRAM_ADDR_WIDTH } {
	# Procedure called to validate BRAM_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.FLAG_NUM_AXI { PARAM_VALUE.FLAG_NUM_AXI } {
	# Procedure called to update FLAG_NUM_AXI when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FLAG_NUM_AXI { PARAM_VALUE.FLAG_NUM_AXI } {
	# Procedure called to validate FLAG_NUM_AXI
	return true
}

proc update_PARAM_VALUE.FLAG_NUM_BRAM { PARAM_VALUE.FLAG_NUM_BRAM } {
	# Procedure called to update FLAG_NUM_BRAM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FLAG_NUM_BRAM { PARAM_VALUE.FLAG_NUM_BRAM } {
	# Procedure called to validate FLAG_NUM_BRAM
	return true
}

proc update_PARAM_VALUE.FLAG_NUM_IREG { PARAM_VALUE.FLAG_NUM_IREG } {
	# Procedure called to update FLAG_NUM_IREG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FLAG_NUM_IREG { PARAM_VALUE.FLAG_NUM_IREG } {
	# Procedure called to validate FLAG_NUM_IREG
	return true
}

proc update_PARAM_VALUE.MAX_IREGS { PARAM_VALUE.MAX_IREGS } {
	# Procedure called to update MAX_IREGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_IREGS { PARAM_VALUE.MAX_IREGS } {
	# Procedure called to validate MAX_IREGS
	return true
}

proc update_PARAM_VALUE.USE_BLOGANA { PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to update USE_BLOGANA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_BLOGANA { PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to validate USE_BLOGANA
	return true
}


proc update_MODELPARAM_VALUE.AXI_ID_WIDTH { MODELPARAM_VALUE.AXI_ID_WIDTH PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ID_WIDTH}] ${MODELPARAM_VALUE.AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.MAX_IREGS { MODELPARAM_VALUE.MAX_IREGS PARAM_VALUE.MAX_IREGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_IREGS}] ${MODELPARAM_VALUE.MAX_IREGS}
}

proc update_MODELPARAM_VALUE.FLAG_NUM_IREG { MODELPARAM_VALUE.FLAG_NUM_IREG PARAM_VALUE.FLAG_NUM_IREG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FLAG_NUM_IREG}] ${MODELPARAM_VALUE.FLAG_NUM_IREG}
}

proc update_MODELPARAM_VALUE.FLAG_NUM_BRAM { MODELPARAM_VALUE.FLAG_NUM_BRAM PARAM_VALUE.FLAG_NUM_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FLAG_NUM_BRAM}] ${MODELPARAM_VALUE.FLAG_NUM_BRAM}
}

proc update_MODELPARAM_VALUE.FLAG_NUM_AXI { MODELPARAM_VALUE.FLAG_NUM_AXI PARAM_VALUE.FLAG_NUM_AXI } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FLAG_NUM_AXI}] ${MODELPARAM_VALUE.FLAG_NUM_AXI}
}

proc update_MODELPARAM_VALUE.BRAM_ADDR_WIDTH { MODELPARAM_VALUE.BRAM_ADDR_WIDTH PARAM_VALUE.BRAM_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRAM_ADDR_WIDTH}] ${MODELPARAM_VALUE.BRAM_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.USE_BLOGANA { MODELPARAM_VALUE.USE_BLOGANA PARAM_VALUE.USE_BLOGANA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_BLOGANA}] ${MODELPARAM_VALUE.USE_BLOGANA}
}

