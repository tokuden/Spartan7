----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/12/28 01:39:26
-- Design Name: 
-- Module Name: ezusbfx2_ctrl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ezusbfx2_wrapper is port (
		-- ezusb fx2 port
			usb_clkout_ip         : in    std_logic;
			usb_ifclk_op          : out   std_logic;
			usb_fd_bp             : inout std_logic_vector(15 downto 0);
			usb_flaga_ip          : in    std_logic;
			usb_flagb_ip          : in    std_logic;
			usb_flagc_ip          : in    std_logic;
			usb_sloe_op           : out   std_logic;
			usb_slrd_op           : out   std_logic;
			usb_slwr_op           : out   std_logic;
			usb_fifoaddr_op       : out   std_logic_vector(1 downto 0);
			usb_pktend_op         : out   std_logic;
			usb_reset_bp          : inout std_logic;
	
		-- user interface port
			uif_sysclk_ip        : in   std_logic;
			uif_reset_ip         : in   std_logic;
			uif_rd_data_op       : out  std_logic_vector(15 downto 0);
			uif_wr_data_ip       : in   std_logic_vector(15 downto 0);
			uif_rd_rdy_op        : out  std_logic;
			uif_rd_wait_op       : out  std_logic;
			uif_wr_req_op        : out  std_logic;
			uif_wr_wait_op       : out  std_logic;
			uif_rd_ip            : in   std_logic;
			uif_wr_ip            : in   std_logic;

		-- following signals art option
			uif_usbclk_op        : out  std_logic;
			uif_length_op        : out std_logic_vector(24 downto 0);
			uif_addr_op          : out std_logic_vector(26 downto 0);
			uif_flag_op          : out std_logic_vector(15 downto 0);
			uif_debug            : inout std_logic_vector(15 downto 0) -- for debug    
);
end ezusbfx2_wrapper;

architecture Behavioral of ezusbfx2_wrapper is
	component ezusbfx2_ctrl is port (
		-- ezusb fx2 port
			usb_clkout_ip         : in    std_logic;
			usb_ifclk_op          : out   std_logic;
			usb_fd_bp             : inout std_logic_vector(15 downto 0);
			usb_flaga_ip          : in    std_logic;
			usb_flagb_ip          : in    std_logic;
			usb_flagc_ip          : in    std_logic;
			usb_sloe_op           : out   std_logic;
			usb_slrd_op           : out   std_logic;
			usb_slwr_op           : out   std_logic;
			usb_fifoaddr_op       : out   std_logic_vector(1 downto 0);
			usb_pktend_op         : out   std_logic;
			usb_reset_bp          : inout std_logic;
	
		-- user interface port
			uif_sysclk_ip        : in   std_logic;
			uif_reset_ip         : in   std_logic;
			uif_rd_data_op       : out  std_logic_vector(15 downto 0);
			uif_wr_data_ip       : in   std_logic_vector(15 downto 0);
			uif_rd_rdy_op        : out  std_logic;
			uif_rd_wait_op       : out  std_logic;
			uif_wr_req_op        : out  std_logic;
			uif_wr_wait_op       : out  std_logic;
			uif_rd_ip            : in   std_logic;
			uif_wr_ip            : in   std_logic;

		-- following signals art option
			uif_usbclk_op        : out  std_logic;
			uif_length_op        : out std_logic_vector(24 downto 0);
			uif_addr_op          : out std_logic_vector(26 downto 0);
			uif_flag_op          : out std_logic_vector(15 downto 0);
			uif_debug            : inout std_logic_vector(15 downto 0) -- for debug
	);
	end component;

begin

	INST_USBCTRL : ezusbfx2_ctrl port map (
		usb_clkout_ip      => usb_clkout_ip,
		usb_ifclk_op       => usb_ifclk_op,
		usb_fd_bp          => usb_fd_bp,
		usb_flaga_ip       => usb_flaga_ip,
		usb_flagb_ip       => usb_flagb_ip,
		usb_flagc_ip       => usb_flagc_ip,
		usb_sloe_op        => usb_sloe_op,
		usb_slrd_op        => usb_slrd_op,
		usb_slwr_op        => usb_slwr_op,
		usb_fifoaddr_op    => usb_fifoaddr_op,
		usb_pktend_op      => usb_pktend_op,
		usb_reset_bp       => usb_reset_bp,
	
		uif_sysclk_ip      => uif_sysclk_ip,
		uif_reset_ip       => uif_reset_ip,
		uif_rd_data_op     => uif_rd_data_op,
		uif_wr_data_ip     => uif_wr_data_ip,
		uif_rd_rdy_op      => uif_rd_rdy_op,
		uif_rd_wait_op     => uif_rd_wait_op,
		uif_wr_req_op      => uif_wr_req_op,
		uif_wr_wait_op     => uif_wr_wait_op,
		uif_rd_ip          => uif_rd_ip,
		uif_wr_ip          => uif_wr_ip,

		uif_usbclk_op      => uif_usbclk_op,
		uif_length_op      => uif_length_op,
		uif_addr_op        => uif_addr_op,
		uif_flag_op        => uif_flag_op,
		uif_debug          => uif_debug
	);

end Behavioral;
