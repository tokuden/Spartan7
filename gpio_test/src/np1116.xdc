set_property IOSTANDARD LVCMOS15 [get_ports {led_op[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports xtalclk_ip]
set_property PACKAGE_PIN C12 [get_ports xtalclk_ip]
create_clock -name xtalclk_ip -period 20.0 [get_ports xtalclk_ip]

set_property IOSTANDARD LVCMOS33 [get_ports pushsw_ip]
set_property PACKAGE_PIN D11 [get_ports pushsw_ip]

set_property PACKAGE_PIN A5 [get_ports {led_op[0]}]
set_property PACKAGE_PIN J5 [get_ports {led_op[1]}]
set_property PACKAGE_PIN G5 [get_ports {led_op[2]}]
set_property PACKAGE_PIN B5 [get_ports {led_op[3]}]
set_property PACKAGE_PIN F5 [get_ports {led_op[4]}]
set_property PACKAGE_PIN E5 [get_ports {led_op[5]}]
set_property PACKAGE_PIN F6 [get_ports {led_op[6]}]
set_property PACKAGE_PIN E4 [get_ports {led_op[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_op[*]}]

# port IOA
set_property PACKAGE_PIN K6 [get_ports {gpio_op[0]}]
set_property PACKAGE_PIN L6 [get_ports {gpio_op[1]}]
set_property PACKAGE_PIN K4 [get_ports {gpio_op[2]}]
set_property PACKAGE_PIN L4 [get_ports {gpio_op[3]}]
set_property PACKAGE_PIN R7 [get_ports {gpio_op[4]}]
set_property PACKAGE_PIN R6 [get_ports {gpio_op[5]}]
set_property PACKAGE_PIN T6 [get_ports {gpio_op[6]}]
set_property PACKAGE_PIN T5 [get_ports {gpio_op[7]}]
set_property PACKAGE_PIN V7 [get_ports {gpio_op[8]}]
set_property PACKAGE_PIN V6 [get_ports {gpio_op[9]}]
set_property PACKAGE_PIN V5 [get_ports {gpio_op[10]}]
set_property PACKAGE_PIN V4 [get_ports {gpio_op[11]}]
set_property PACKAGE_PIN V3 [get_ports {gpio_op[12]}]
set_property PACKAGE_PIN V2 [get_ports {gpio_op[13]}]
set_property PACKAGE_PIN U3 [get_ports {gpio_op[14]}]
set_property PACKAGE_PIN U2 [get_ports {gpio_op[15]}]
set_property PACKAGE_PIN T1 [get_ports {gpio_op[16]}]
set_property PACKAGE_PIN U1 [get_ports {gpio_op[17]}]
set_property PACKAGE_PIN U7 [get_ports {gpio_op[18]}]
set_property PACKAGE_PIN U6 [get_ports {gpio_op[19]}]
set_property PACKAGE_PIN P6 [get_ports {gpio_op[20]}]
set_property PACKAGE_PIN P5 [get_ports {gpio_op[21]}]
set_property PACKAGE_PIN R3 [get_ports {gpio_op[22]}]
set_property PACKAGE_PIN T2 [get_ports {gpio_op[23]}]
set_property PACKAGE_PIN M6 [get_ports {gpio_op[24]}]
set_property PACKAGE_PIN M5 [get_ports {gpio_op[25]}]
set_property PACKAGE_PIN L5 [get_ports {gpio_op[26]}]
set_property PACKAGE_PIN M4 [get_ports {gpio_op[27]}]

# port IOB
set_property PACKAGE_PIN H18 [get_ports {gpio_op[28]}]
set_property PACKAGE_PIN G18 [get_ports {gpio_op[29]}]
set_property PACKAGE_PIN K14 [get_ports {gpio_op[30]}]
set_property PACKAGE_PIN J15 [get_ports {gpio_op[31]}]
set_property PACKAGE_PIN H16 [get_ports {gpio_op[32]}]
set_property PACKAGE_PIN H17 [get_ports {gpio_op[33]}]
set_property PACKAGE_PIN G16 [get_ports {gpio_op[34]}]
set_property PACKAGE_PIN G17 [get_ports {gpio_op[35]}]
set_property PACKAGE_PIN F18 [get_ports {gpio_op[36]}]
set_property PACKAGE_PIN E18 [get_ports {gpio_op[37]}]
set_property PACKAGE_PIN D18 [get_ports {gpio_op[38]}]
set_property PACKAGE_PIN C18 [get_ports {gpio_op[39]}]
set_property PACKAGE_PIN C17 [get_ports {gpio_op[40]}]
set_property PACKAGE_PIN B18 [get_ports {gpio_op[41]}]
set_property PACKAGE_PIN B17 [get_ports {gpio_op[42]}]
set_property PACKAGE_PIN A17 [get_ports {gpio_op[43]}]
set_property PACKAGE_PIN E16 [get_ports {gpio_op[44]}]
set_property PACKAGE_PIN E17 [get_ports {gpio_op[45]}]
set_property PACKAGE_PIN D16 [get_ports {gpio_op[46]}]
set_property PACKAGE_PIN D17 [get_ports {gpio_op[47]}]
set_property PACKAGE_PIN D14 [get_ports {gpio_op[48]}]
set_property PACKAGE_PIN D15 [get_ports {gpio_op[49]}]
set_property PACKAGE_PIN C13 [get_ports {gpio_op[50]}]
set_property PACKAGE_PIN C14 [get_ports {gpio_op[51]}]
set_property PACKAGE_PIN F14 [get_ports {gpio_op[52]}]
set_property PACKAGE_PIN F15 [get_ports {gpio_op[53]}]
set_property PACKAGE_PIN E12 [get_ports {gpio_op[54]}]
set_property PACKAGE_PIN D12 [get_ports {gpio_op[55]}]
set_property PACKAGE_PIN B16 [get_ports {gpio_op[56]}]
set_property PACKAGE_PIN A16 [get_ports {gpio_op[57]}]
set_property PACKAGE_PIN B15 [get_ports {gpio_op[58]}]
set_property PACKAGE_PIN A15 [get_ports {gpio_op[59]}]
set_property PACKAGE_PIN B14 [get_ports {gpio_op[60]}]
set_property PACKAGE_PIN A14 [get_ports {gpio_op[61]}]
set_property PACKAGE_PIN B13 [get_ports {gpio_op[62]}]
set_property PACKAGE_PIN A13 [get_ports {gpio_op[63]}]