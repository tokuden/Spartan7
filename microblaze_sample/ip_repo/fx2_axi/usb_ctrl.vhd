----------------------------------------------------------------------------------
-- Company:  Tokushu Denshi Kairo Inc.
-- Engineer: Naitou Ryuji
-- 
-- Create Date:    10:09:53 08/18/2006 
-- Design Name:    USB CTRL
-- Module Name:    uif_ctrl - Behavioral 
-- Project Name:   EZUSB FX2 FPGA Interface
-- Target Devices: FPGA
-- Tool versions:  ISE8.1
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.0 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ezusbfx2_ctrl is
    Port (
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
--			usb_reset_bp          : inout std_logic;
	
		-- user interface port (mandantory)
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

		-- optional signals
			uif_usbclk_op        : out  std_logic;
			uif_length_op        : out std_logic_vector(24 downto 0);
			uif_addr_op          : out std_logic_vector(26 downto 0);
			uif_flag_op          : out std_logic_vector(15 downto 0);
			uif_debug            : out std_logic_vector(15 downto 0) -- for debug
		);
end ezusbfx2_ctrl;

architecture Behavioral of ezusbfx2_ctrl is
	signal USBCLK : std_logic;

	component FX2_48MHz is port (
		CLK         : in std_logic;
		RESET       : in std_logic; -- 同期リセット
		FLAGR       : in std_logic;
		FLAGW       : in std_logic;
		SENDIM      : in std_logic;
		IFCLK       : out std_logic;
		SLOE        : out std_logic;
		SLRD        : out std_logic;
		SLWR        : out std_logic;
		DATAOUT     : out std_logic;
		PKTEND      : out std_logic;
		FIFOADR     : out std_logic_vector(1 downto 0);
		FD_IN       : in std_logic_vector(15 downto 0);
		FD_OUT      : out std_logic_vector(15 downto 0);
		TXRDY       : in std_logic;
		RXRDY       : in std_logic;
		RECEIVED    : out std_logic;
		TRANSMITTED : out std_logic;
		RDATA       : out std_logic_vector(15 downto 0);
		WDATA       : in std_logic_vector(15 downto 0);
		STATUS      : out std_logic_vector(7 downto 0)
	);
	end component;

	signal CORE_RDATA       : std_logic_vector(15 downto 0);
	signal CORE_WDATA       : std_logic_vector(15 downto 0);
	signal RECEIVED         : std_logic;
	signal TRANSMITTED      : std_logic;
	signal RXRDY            : std_logic;
	signal txrdy            : std_logic;
	signal txrdy_r          : std_logic;
	signal RXEND            : std_logic;
	signal RD_RDY_sc        : std_logic;
	signal rxend_sc         : std_logic;

	signal GSTATE           : std_logic_vector(3 downto 0);
	signal user_flag        : std_logic_vector(15 downto 0);
	signal user_addr        : std_logic_vector(26 downto 0);
	signal user_length      : std_logic_vector(24 downto 0);
	signal user_cmd         : std_logic_vector(7 downto 0);
	signal TRXCNT           : std_logic_vector(24 downto 0);

	signal short_packet  : std_logic;

-- for interface fifo

	component fifo2kb is
		port (clock:		  IN  std_logic;
			 read_enable_in:  IN  std_logic;
			 write_enable_in: IN  std_logic;
			 write_data_in:	IN  std_logic_vector(15 downto 0);
			 fifo_gsr_in:	  IN  std_logic;
			 read_data_out:	OUT std_logic_vector(15 downto 0);
			 full_out:		  OUT std_logic;
			 empty_out:		 OUT std_logic;
			 fifocount_out:	OUT std_logic_vector(9 downto 0));
	end component;

	signal ofifo_res      : std_logic;
	signal ofifo_rd       : std_logic;
	signal ofifo_wr       : std_logic;
	signal ofifo_rdata    : std_logic_vector(15 downto 0);
	signal ofifo_wdata    : std_logic_vector(15 downto 0);
	signal ofifo_full     : std_logic;
	signal ofifo_empty    : std_logic;
--	signal ofifo_empty_sc : std_logic;
	signal ofifo_rcnt     : std_logic_vector(10 downto 0);
	signal ofifo_wcnt     : std_logic_vector(10 downto 0);
	signal ofifo_rrst_bsy : std_logic;
	signal ofifo_wrst_bsy : std_logic;

	signal USB_STATUS   : std_logic_vector(7 downto 0);
	
--	signal nUSB_RESET_IN  : STD_LOGIC;
	signal nUSB_FLAGB_IN  : STD_LOGIC;
	
-- for DEBUG use

	component asyncfifo is
		PORT (
			rst : IN STD_LOGIC;
			wr_clk : IN STD_LOGIC;
			rd_clk : IN STD_LOGIC;
			din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_en : IN STD_LOGIC;
			rd_en : IN STD_LOGIC;
			dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			full : OUT STD_LOGIC;
			empty : OUT STD_LOGIC;
			rd_data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			wr_data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			wr_rst_busy : OUT STD_LOGIC;
			rd_rst_busy : OUT STD_LOGIC
	);
	end component;

	signal ififo_res      : std_logic;
	signal ififo_rdata    : std_logic_vector(15 downto 0);
	signal ififo_empty    : std_logic;
	signal ififo_full     : std_logic;
	signal ififo_rcnt     : std_logic_vector(10 downto 0); -- usbclk
	signal ififo_wcnt     : std_logic_vector(10 downto 0); -- sysclk
	signal ififo_rrst_bsy : std_logic;
	signal ififo_wrst_bsy : std_logic;
	
	signal wr_start       : std_logic;
	signal wr_start_d     : std_logic;
	signal wr_start_dd    : std_logic;
	signal wr_done        : std_logic;
	signal wr_done_d      : std_logic;
	signal wr_wait_node   : std_logic;
	signal txcnt          : std_logic_vector(24 downto 0); -- usbclk

	signal usb_ifclk         : std_logic;
	signal usb_fd_out        : std_logic_vector(15 downto 0);
	signal usb_fd_in         : std_logic_vector(15 downto 0);
	signal usb_flaga         : std_logic;
	signal usb_fd_dir        : std_logic;
	signal usb_fd_tri        : std_logic;
	signal usb_flagb         : std_logic;
	signal usb_flagc         : std_logic;
	signal usb_flagc_d       : std_logic;
	signal usb_sloe          : std_logic;
	signal usb_slrd          : std_logic;
	signal usb_slwr          : std_logic;
	signal usb_fifoaddr      : std_logic_vector(1 downto 0);
	signal usb_pktend        : std_logic;
	signal usb_reset         : std_logic;

	signal uif_sysclk       : std_logic;
	signal uif_reset        : std_logic;
	signal uif_rd_data      : std_logic_vector(15 downto 0);
	signal uif_wr_data      : std_logic_vector(15 downto 0);
	signal uif_rd_rdy       : std_logic;
	signal uif_rd_wait      : std_logic;
	signal uif_wr_req       : std_logic;
	signal uif_wr_wait      : std_logic;
	signal uif_rd           : std_logic;
	signal uif_wr           : std_logic;
	signal uif_addr         : std_logic_vector(26 downto 0);

	signal sysclk           : std_logic;

	component clk_wiz_0 is port (
		clk_in1  : in std_logic;
		clk_out1 : out std_logic;
		clk_out2 : out std_logic
	);
	end component;
--	signal CLK192 : std_logic;

	component blogana2 is
	generic(
		BIT_WIDTH     : integer := 252; --サンプリングする信号のBIT幅を指定（1bit以上、252bit以下で選択）
		SAMPLE_LENGTH : integer := 8192--サンプリングの長さ(word)を指定（1word以上、8192word位下で選択）
    );
	Port (	CLK         : in std_logic;
			TRIG        : in std_logic;
			USER_OP     : out std_logic_vector(19 downto 0);
			SAMPLE_EN   : in std_logic;
			DIN         : in std_logic_vector(255 downto 0); --BIT幅はgenericのBIT_WIDTHで指定
			SAMP_FREQ   : in integer range 0 to 2147483647; -- サンプリング周波数
			BUSY        : out std_logic                     -- 必ずどこかに出力すること
            );
	end component;

	signal blogana_din : std_logic_vector(255 downto 0);
	signal blogana_trig : std_logic;
	signal blogana_busy : std_logic;
	signal blogana_user : std_logic_vector(19 downto 0);

begin

--------------------------------------------------------
-- EZ USB FX2 signal assign
--------------------------------------------------------

--	inst_usbclk_bufg : bufg port map (
--		I => usb_clkout_ip,
--		O => USBCLK
--	);

	usb_fifoaddr_op <= usb_fifoaddr when(usb_pktend = '0') else "10";
	usb_sloe_op     <= usb_sloe;
	usb_slrd_op     <= usb_slrd;
	usb_slwr_op     <= usb_slwr;
	usb_pktend_op   <= usb_pktend;
	usb_ifclk_op    <= usb_ifclk;

	usb_flaga       <= usb_flaga_ip;
	usb_flagb       <= usb_flagb_ip;
	usb_flagc       <= usb_flagc_ip;

	usb_fd_tri <= not usb_fd_dir;

	IOBs: FOR I in 0 to 15 generate
		IOBUF_inst : IOBUF port map (
			O  => usb_fd_in(I),
			IO => usb_fd_bp(I),
			I  => usb_fd_out(I),
			T  => usb_fd_tri
		);
	end generate;

--	usb_reset_bp <= '0' when (uif_reset = '1') else '1';

--	nUSB_RESET_IN <= not usb_reset_bp;
	nUSB_FLAGB_IN <= not usb_flagb;

--------------------------------------------------------
-- USER port signal assign
--------------------------------------------------------

	sysclk      <= uif_sysclk_ip;
	uif_rd      <= uif_rd_ip;
	uif_wr      <= uif_wr_ip;
	uif_wr_data <= uif_wr_data_ip;

	uif_reset      <= uif_reset_ip;
	uif_usbclk_op  <= usbclk;
	uif_rd_data_op <= uif_rd_data;   -- for probe
	uif_rd_wait_op <= uif_rd_wait;
	uif_wr_wait_op <= WR_WAIT_node;
	uif_wr_req_op  <= uif_wr_req;

-- 出力のための同期化
	process(sysclk) begin
		if(sysclk'event and sysclk = '1') then
			uif_rd_rdy_op  <= uif_rd_rdy;
			uif_flag_op    <= user_flag;
			uif_length_op  <= user_length;
			uif_addr_op    <= user_addr;
		end if;
	end process;

--	process(sysclk,user_addr_set) begin
--		if(user_addr_set = '1') then
--			uif_addr <= user_addr;
--		elsif(sysclk'event and sysclk = '1') then
--			if(uif_wr_req = '1') and (uif_wr = '1') and (uif_wr_wait = '0') then
--				uif_addr <= uif_addr + 1;
--			elsif(RD_RDY_sc = '1') and (uif_rd = '1') and (uif_rd_wait = '0') then
--				uif_addr <= uif_addr + 1;
--			end if;
--		end if;
--	end process;
--	uif_addr_op <= uif_addr;
--

--------------------------------------------------------
-- EZ USB FX2 Core
--------------------------------------------------------

	USB1 : FX2_48MHz port map (
		CLK         => USBCLK,
		RESET       => uif_reset,
		FLAGR       => usb_flagc,
		FLAGW       => nUSB_FLAGB_IN,
		SENDIM      => '0',
		IFCLK       => usb_ifclk,
		SLOE        => usb_sloe,
		SLRD        => usb_slrd,
		SLWR        => usb_slwr,
		DATAOUT     => usb_fd_dir,
		PKTEND      => open,--USB_PKTEND_node,
		FIFOADR     => usb_fifoaddr,
		FD_IN       => usb_fd_in,
		FD_OUT      => usb_fd_out,
		TXRDY       => txrdy,
		RXRDY       => RXRDY,
		RECEIVED    => RECEIVED,
		TRANSMITTED => TRANSMITTED,
		RDATA       => CORE_RDATA,
		WDATA       => CORE_WDATA,
		STATUS      => USB_STATUS
	);

--------------------------------------------------------
-- OUT FIFO (PC->USB)
--------------------------------------------------------

	INST_OFIFO : asyncfifo port map (
		rst    => ofifo_res,
		------ SYSCLK domain -----
		rd_clk => SYSCLK,
		rd_en  => ofifo_rd,
		dout   => uif_rd_data,
		full   => ofifo_full,
		empty  => ofifo_empty,
		rd_data_count => ofifo_rcnt(9 downto 0),

		------ USBCLK domain -----
		wr_clk => USBCLK,
		din    => OFIFO_WDATA,
		wr_en  => OFIFO_WR,
		wr_data_count => ofifo_wcnt(9 downto 0),
		wr_rst_busy => ofifo_wrst_bsy,
		rd_rst_busy => ofifo_rrst_bsy
	);

	ofifo_rd <= uif_rd and RD_RDY_sc and (not uif_rd_wait);

	process(SYSCLK) begin
		if(SYSCLK'event and SYSCLK = '1') then
			RD_RDY_sc <= uif_rd_rdy;
			RXEND_sc  <= RXEND;
--			ofifo_empty_sc <= ofifo_empty;
		end if;
	end process;

	uif_rd_wait <= --'0' when((ofifo_empty = '1') and (ofifo_empty_sc = '0')) else
					'1' when(ofifo_empty = '1') else
	                '0' when(ofifo_rcnt >= 8) else
                    '0' when(RXEND_sc = '1') else 
					'1';


--------------------------------------------------------
-- IN FIFO (FPGA->USB->PC)
--------------------------------------------------------

	INST_IFIFO : asyncfifo port map (
		rst    => ififo_res,
		rd_clk => USBCLK,
		rd_en  => TRANSMITTED,
		dout   => ififo_rdata,
		full   => ififo_full, -- ififo_full
		empty  => ififo_empty,

		wr_clk => sysclk,
		din    => uif_wr_data,
		wr_en  => uif_wr,
		rd_data_count => ififo_rcnt(9 downto 0),
		wr_data_count => ififo_wcnt(9 downto 0),
		wr_rst_busy => ififo_wrst_bsy,
		rd_rst_busy => ififo_rrst_bsy
	);

	CORE_WDATA   <= ififo_rdata;-- when(ififo_empty = '0') else (others => '1');
	WR_WAIT_node <= '1' when(ififo_wcnt(9 downto 2) = "11111111") else '0';

	txrdy <= txrdy_r when(TRXCNT /= 0) else '0';

--------------------------------------------------------
-- MAIN STATE MACHINE
--------------------------------------------------------

	process(USBCLK,uif_reset) begin
		if(uif_reset = '1') then
			GSTATE <= "0000";
		elsif(USBCLK'event and USBCLK='1') then
			OFIFO_WDATA <= CORE_RDATA;
			usb_flagc_d <= usb_flagc;

			case GSTATE is
				when "0000" => -- FIFOをリセットする
					wr_start <= '0';
					TRXCNT  <= (others => '0');
					IFIFO_RES <= '1';
					OFIFO_RES <= '1';
					RXRDY <= '0';
					RXEND <= '0';
					OFIFO_WR <= '0';
					usb_pktend <= '0';
					GSTATE <= GSTATE + 1;
					
				when "0001" => -- FIFOのリセット解除待ち
					IFIFO_RES <= '0';
					OFIFO_RES <= '0';
					if (ififo_full = '0') and (ofifo_full = '0') then
						GSTATE <= GSTATE + 1;
					end if;
					
				when "0010" => -- 開始キーを待つ
					wr_start <= '0';
					TRXCNT  <= (others => '0');
					IFIFO_RES <= '0';
					OFIFO_RES <= '0';
					RXRDY <= '1';
					RXEND <= '0';
					OFIFO_WR <= '0';
					usb_pktend <= '0';
					if(RECEIVED = '1') then
						if (CORE_RDATA(15 downto 8) = x"AA") then
							user_cmd <= CORE_RDATA(7 downto 0);
							GSTATE <= GSTATE + 1;
						end if;
					end if;

				when "0011" => -- ユーザアトリビュートを受信 
					OFIFO_RES <= '0';
					IFIFO_RES <= '0';

					if(usb_flagc = '0') then
						GSTATE <= "0000";
					elsif(RECEIVED = '1') then
						user_flag <= CORE_RDATA;
						GSTATE <= GSTATE + 1;
					end if;

				when "0100" => -- 長さ（下16bit）を受信
					if(RECEIVED = '1') then
						TRXCNT(15 downto 0) <= CORE_RDATA;
						GSTATE <= GSTATE + 1;
					elsif(usb_flagc = '0') then
						GSTATE <= "0000";
					end if;

				when "0101" => -- 長さ（上9bit）を受信
					if(TRXCNT(7 downto 0) /= 0) then
						short_packet <= '1';
					else
						short_packet <= '0';
					end if;
					if(RECEIVED = '1') then
						TRXCNT(24 downto 16) <= CORE_RDATA(8 downto 0);
						GSTATE <= GSTATE + 1;
					elsif(usb_flagc = '0') then
						GSTATE <= "0000";
					end if;

				when "0110" => -- アドレス（下16bit）を受信
					user_length <= trxcnt;
					if(RECEIVED = '1') then
						user_addr(15 downto 0) <= CORE_RDATA;
						GSTATE <= GSTATE + 1;
					elsif(usb_flagc = '0') then
						GSTATE <= "0000";
					end if;

				when "0111" => -- アドレス（上9bit）を受信
					if(RECEIVED = '1') then
						user_addr(26 downto 16) <= CORE_RDATA(10 downto 0);
						case user_cmd is
							when x"55" => -- out
								uif_rd_rdy <= '1';
								GSTATE <= "1000";
							when x"56" => -- in
								RXRDY <= '0';
								wr_start <= '1';
								GSTATE <= "1100";
							when others =>
								GSTATE <= "0000";
						end case;
						
					elsif(usb_flagc = '0') then
						GSTATE <= "0000";
					end if;

				when "1000" => -- 受信データFIFO書き込み
					if((usb_flagc_d = '1') and (usb_flagc = '0') and (OFIFO_WCNT >= 512)) then
						RXRDY <= '0'; -- WAIT
					elsif(TRXCNT = 0) then
						RXRDY <= '0'; -- END
					elsif(OFIFO_WCNT < 512) then
						RXRDY <= '1'; -- REGO
					end if;

					if(TRXCNT = 0) then
						RXEND <= '1';
						GSTATE <= GSTATE + 1;
					end if;

					if(RECEIVED = '1') and (TRXCNT /= 0) then
						TRXCNT <= TRXCNT - 1;
						OFIFO_WR    <= '1';
					else
						OFIFO_WR    <= '0';
					end if;

				when "1001" =>
					GSTATE <= "1010";

				when "1010" => -- 受信データFIFO読み出し完了待ち
					if(OFIFO_WCNT = 0) then
						uif_rd_rdy <= '0';
						RXRDY <= '0';
						GSTATE <= "0000";
					end if;

				when "1100" => -- データ送信

					if(TRXCNT = 0) then
						txrdy_r <= '0';
						usb_pktend <= short_packet;
						GSTATE <= "0000";
						wr_start <= '0';
					elsif((wr_done_d = '1') and (ififo_empty = '0')) then
						txrdy_r <= '1';
					elsif(ififo_rcnt <  "00000001000") then -- IN FIFOの残量が少なければ送信停止
						txrdy_r <= '0';
					elsif(ififo_rcnt >= "00000010000") then -- IN FIFOの残量が多ければ送信
						txrdy_r <= '1';
					end if;

					if(transmitted = '1') then
						TRXCNT <= TRXCNT - 1;
					end if;

				when others =>
					GSTATE <= "0000";
			end case;
		end if;
	end process;

	process (SYSCLK) begin
		if(SYSCLK'event and SYSCLK = '1') then
			wr_start_d <= wr_start;
			wr_start_dd <= wr_start_d;

			if(wr_start_d = '1') and (wr_start_dd = '0') then
				TXCNT <= TRXCNT;
			elsif((uif_wr = '1') and (TXCNT /= 0)) then
				TXCNT <= TXCNT - 1;
			end if;

			if(wr_start_d = '1') and (wr_start_dd = '0') then
				TXCNT <= TRXCNT;
				wr_done <= '0';
			elsif(TXCNT = 0) then
				wr_done <= '1';
			end if;
		end if;
	end process;

	process(USBCLK) begin
		if(USBCLK'event and USBCLK='1') then
			wr_done_d <= wr_done;
		end if;
	end process;

	uif_wr_req <= '1' when (TXCNT /= 0) else '0';

--------------------------------------------------------
-- DEBUG
--------------------------------------------------------

	uif_debug(0) <= GSTATE(0);-- and uif_SLWR_node;--このDEBUG(0)の記述は変更しないでください。また、DEBUG(0)はFPGAの外に出力してください。
	uif_debug(1) <= GSTATE(1);-- and uif_SLWR_node;--このDEBUG(0)の記述は変更しないでください。また、DEBUG(0)はFPGAの外に出力してください。
	uif_debug(2) <= GSTATE(2);-- and uif_SLWR_node;--このDEBUG(0)の記述は変更しないでください。また、DEBUG(0)はFPGAの外に出力してください。
	uif_debug(3) <= GSTATE(3);-- and uif_SLWR_node;--このDEBUG(0)の記述は変更しないでください。また、DEBUG(0)はFPGAの外に出力してください。

	uif_debug(4) <= ofifo_rd;
	uif_debug(5) <= RD_RDY_sc;
	uif_debug(6) <= uif_rd_wait;
	uif_debug(7) <= uif_rd_rdy;
	uif_debug(8) <= RXEND_sc;
	uif_debug(9) <= RXEND;
	uif_debug(10) <= ofifo_empty;
	uif_debug(15 downto 11) <= ofifo_rcnt(4 downto 0);

--	inst_clkwiz : clk_wiz_0 port map (
--		clk_in1 => usb_clkout_ip,
--		clk_out1 => CLK192,
--		clk_out2 => USBCLK
--	);
	USBCLK <= usb_clkout_ip;
	
--	inst_blogana2 :  blogana2 generic map
--	(
--		BIT_WIDTH     => 144,
--		SAMPLE_LENGTH => 2048
--	)
--	port map
--	(
--		clk => USBCLK,
--		trig => blogana_trig,
--		din  => blogana_din,
--		USER_OP   => blogana_user,
--		SAMPLE_EN => '1',--spi_debug(15),
--		samp_freq => 192000000,
--		busy => blogana_busy
--	);

	blogana_trig <= RECEIVED;

	BLOGANA_DIN(15 downto   0)  <= OFIFO_WDATA;
	BLOGANA_DIN(31 downto  16)  <= IFIFO_RDATA;
	BLOGANA_DIN(35 downto  32)  <= GSTATE;
	BLOGANA_DIN(51 downto  36)  <= TRXCNT(15 downto 0);
	BLOGANA_DIN(67 downto  52)  <= uif_wr_data;
--	BLOGANA_DIN(70 downto  63)  <= ofifo_rcnt(7 downto 0);
	BLOGANA_DIN(86 downto  71)  <= usb_fd_in;
	BLOGANA_DIN(87)             <= OFIFO_WR;
	BLOGANA_DIN(88)             <= ofifo_full;
	BLOGANA_DIN(89)             <= ofifo_empty;
	BLOGANA_DIN(90)             <= usb_flagc;
	BLOGANA_DIN(91)             <= usb_flagc_d;
	BLOGANA_DIN(92)             <= wr_start;
	BLOGANA_DIN(93)             <= IFIFO_RES;
	BLOGANA_DIN(94)             <= OFIFO_RES;
	BLOGANA_DIN(95)             <= RXRDY;
	BLOGANA_DIN(96)             <= RXEND;
	BLOGANA_DIN(97)             <= usb_pktend;
	BLOGANA_DIN(98)             <= RECEIVED;
	BLOGANA_DIN(99)             <= short_packet;
	BLOGANA_DIN(100)            <= uif_rd_rdy;
	BLOGANA_DIN(101)            <= uif_rd;
	BLOGANA_DIN(102)            <= uif_rd_wait;
	BLOGANA_DIN(103)            <= transmitted;
	BLOGANA_DIN(104)            <= wr_done;
	BLOGANA_DIN(105)            <= wr_done_d;
	BLOGANA_DIN(106)            <= usb_sloe;
	BLOGANA_DIN(107)            <= usb_slrd;
	BLOGANA_DIN(108)            <= usb_slwr;
	BLOGANA_DIN(109)            <= usb_fd_dir;
	BLOGANA_DIN(110)            <= wr_done_d;
	BLOGANA_DIN(111)            <= ififo_empty;
	BLOGANA_DIN(112)            <= uif_wr;
	BLOGANA_DIN(123 downto 113) <= ififo_rcnt;
	BLOGANA_DIN(134 downto 124) <= ififo_wcnt;
	BLOGANA_DIN(135) <= WR_WAIT_node;
	BLOGANA_DIN(136) <= uif_wr_req;
	BLOGANA_DIN(137) <= ififo_full;
	BLOGANA_DIN(138) <= ififo_empty;
	BLOGANA_DIN(139) <= ififo_rrst_bsy;
	BLOGANA_DIN(140) <= ififo_wrst_bsy;
	BLOGANA_DIN(141) <= ofifo_rrst_bsy;
	BLOGANA_DIN(142) <= ofifo_wrst_bsy;

--	BLOGANA_DIN(15 downto   0)  <= uif_wr_data;
--	BLOGANA_DIN(41 downto  16)  <= uif_addr(25 downto 0);
--	BLOGANA_DIN(65 downto  42)  <= uif_len(23 downto 0);
--	BLOGANA_DIN(81 downto  66)  <= uif_flag;
--	BLOGANA_DIN(82)  <= uif_wr;
--	BLOGANA_DIN(83)  <= uif_rd;
--	BLOGANA_DIN(84)  <= uif_rd_rdy;
--	BLOGANA_DIN(85)  <= uif_rd_wait;
--	BLOGANA_DIN(86)  <= uif_wr_req;
--	BLOGANA_DIN(87)  <= uif_wr_wait;
--	BLOGANA_DIN(88)  <= uif_wr_pre;
--	BLOGANA_DIN(104 downto   89)  <= uif_rd_data;

end Behavioral;

