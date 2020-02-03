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

set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PACKAGE_PIN K6 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property PACKAGE_PIN L6 [get_ports uart_rxd]


set_property PACKAGE_PIN K2 [get_ports mdio_mdio_io]
set_property PACKAGE_PIN K1 [get_ports mdio_mdc]
set_property PACKAGE_PIN L1 [get_ports rmii_crs_dv]
set_property PACKAGE_PIN M2 [get_ports {rmii_rxd[0]}]
set_property PACKAGE_PIN M1 [get_ports rmii_rx_er]
set_property PACKAGE_PIN N1 [get_ports {rmii_rxd[1]}]
set_property PACKAGE_PIN P2 [get_ports {rmii_txd[0]}]
set_property PACKAGE_PIN P1 [get_ports {rmii_txd[1]}]
set_property PACKAGE_PIN R2 [get_ports phyclk]
set_property PACKAGE_PIN T3 [get_ports phy_reset_op]
set_property PACKAGE_PIN R1 [get_ports rmii_tx_en]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_mdio_io]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_mdc]
set_property IOSTANDARD LVCMOS33 [get_ports rmii_crs_dv]
set_property IOSTANDARD LVCMOS33 [get_ports {rmii_rxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports rmii_rx_er]
set_property IOSTANDARD LVCMOS33 [get_ports {rmii_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rmii_txd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rmii_txd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports phyclk]
set_property IOSTANDARD LVCMOS33 [get_ports phy_reset_op]
set_property IOSTANDARD LVCMOS33 [get_ports rmii_tx_en]
