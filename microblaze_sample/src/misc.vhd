----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/12/28 02:40:56
-- Design Name: 
-- Module Name: misc - Behavioral
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

entity misc is
	Generic (
		CLKFREQ     : integer := 100000000;
		BRAM_ADDR_WIDTH : integer := 16
	);
	Port (
		clk           : in std_logic;
		pushsw_ip     : in std_logic;
		uif_reset     : out std_logic;
		uif_wr_data_o : out std_logic_vector(15 downto 0);
		uif_rd_data_i : in  std_logic_vector(15 downto 0);
		uif_wr_o      : out std_logic;
		uif_rd_o      : out std_logic;
		uif_rd_rdy    : in std_logic;
		uif_rd_wait   : in std_logic;
		uif_wr_req    : in std_logic;
		uif_wr_wait   : in std_logic;
		uif_addr      : in std_logic_vector(26 downto 0);
		uif_len       : in std_logic_vector(24 downto 0);
		uif_flag      : in std_logic_vector(15 downto 0);

--		bram_wr_addr_o : out std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
--		bram_wr_we_o   : out std_logic;
--		bram_wr_en_o   : out std_logic;
--		bram_wr_clk_o  : out std_logic;
--		bram_wr_rst_o  : out std_logic;
--		bram_wr_data_o : out std_logic_vector(15 downto 0);
--		bram_wr_data_i : in  std_logic_vector(15 downto 0);

--		bram_rd_addr_o : out std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
--		bram_rd_we_o   : out std_logic;
--		bram_rd_en_o   : out std_logic;
--		bram_rd_clk_o  : out std_logic;
--		bram_rd_rst_o  : out std_logic;
--		bram_rd_data_o : out std_logic_vector(15 downto 0); 
--		bram_rd_data_i : in  std_logic_vector(15 downto 0); 

		sync_rst     : in std_logic;
		init_done    : in std_logic;
		mmcm_locked  : in std_logic;
		clk2         : in std_logic;
		clk3         : in std_logic;
		led_op       : out std_logic_vector(7 downto 0)
	);
end misc;

architecture Behavioral of misc is
	signal timer : integer range 0 to CLKFREQ-1; 
	signal led   : std_logic_vector(7 downto 0);
	ATTRIBUTE X_INTERFACE_INFO : STRING;
	ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
	ATTRIBUTE X_INTERFACE_PARAMETER OF uif_reset: SIGNAL IS "XIL_INTERFACENAME uif_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
	ATTRIBUTE X_INTERFACE_INFO OF uif_reset: SIGNAL IS "xilinx.com:signal:reset:1.0 uif_reset RST";
	ATTRIBUTE X_INTERFACE_PARAMETER OF sync_rst: SIGNAL IS "XIL_INTERFACENAME sync_rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
	ATTRIBUTE X_INTERFACE_INFO OF sync_rst: SIGNAL IS "xilinx.com:signal:reset:1.0 sync_rst RST";
	signal timer2 : integer range 0 to 333333333-1; 
	signal timer3 : integer range 0 to 50000000-1; 

--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_en_o   : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W EN";
--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_data_o : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W DOUT";
--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_data_i : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W DIN";
--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_we_o   : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W WE";
--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_addr_o : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W ADDR";
--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_clk_o  : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W CLK";
--	ATTRIBUTE X_INTERFACE_INFO of bram_wr_rst_o  : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_W RST";
----	ATTRIBUTE X_INTERFACE_PARAMETER of BRAM_W: SIGNAL is "MASTER_TYPE true,MEM_ECC false,MEM_WIDTH 16,MEM_SIZE <value>,READ_WRITE_MODE <value>";

--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_en_o   : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R EN";
--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_data_o : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R DOUT";
--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_we_o   : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R WE";
--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_addr_o : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R ADDR";
--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_data_i : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R DIN";
--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_clk_o  : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R CLK";
--	ATTRIBUTE X_INTERFACE_INFO of bram_rd_rst_o  : SIGNAL is "xilinx.com:interface:bram:1.0 BRAM_R RST";
 
	component blk_mem_gen_0 IS
	PORT (
		clka : IN STD_LOGIC;
		ena : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clkb : IN STD_LOGIC;
		enb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
	END component;

	signal BRAM_DOUT        : std_logic_vector(15 downto 0);
	signal SDRAM_DOUT       : std_logic_vector(15 downto 0);
	signal GPIO_DOUT        : std_logic_vector(15 downto 0);
	signal TEST_PATTERN     : std_logic_vector(15 downto 0);
	signal LFSR             : std_logic_vector(31 downto 0);
	signal HCOUNT           : std_logic_vector(9 downto 0);
	signal VCOUNT           : std_logic_vector(9 downto 0);
	signal FRAMENUM         : std_logic_vector(7 downto 0);
	signal SEQ_PATTERN      : std_logic_vector(15 downto 0);
	signal hdr_pls          : std_logic_vector(63 downto 0);

	signal uif_wr           : std_logic;
	signal uif_rd           : std_logic;
	signal uif_rd_data      : std_logic_vector(15 downto 0);
	signal uif_wr_data      : std_logic_vector(15 downto 0);
	signal uif_wr_pre       : std_logic;
	signal uif_debug        : std_logic_vector(15 downto 0);
	signal uif_length       : std_logic_vector(24 downto 0);
	signal uif_lengthd      : std_logic_vector(24 downto 0);

	signal bram_wr_addr : std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
	signal bram_rd_addr : std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
	signal bram_wr_en   : std_logic;

--	component blogana2 is
--	generic(
--		BIT_WIDTH     : integer := 252; --サンプリングする信号のBIT幅を指定（1bit以上、252bit以下で選択）
--		SAMPLE_LENGTH : integer := 8192--サンプリングの長さ(word)を指定（1word以上、8192word位下で選択）
--    );
--	Port (	CLK         : in std_logic;
--			TRIG        : in std_logic;
--			USER_OP     : out std_logic_vector(19 downto 0);
--			SAMPLE_EN   : in std_logic;
--			DIN         : in std_logic_vector(255 downto 0); --BIT幅はgenericのBIT_WIDTHで指定
--			SAMP_FREQ   : in integer range 0 to 2147483647; -- サンプリング周波数
--			BUSY        : out std_logic                     -- 必ずどこかに出力すること
--            );
--	end component;

--	signal blogana_din : std_logic_vector(255 downto 0);
--	signal blogana_trig : std_logic;
--	signal blogana_busy : std_logic;
--	signal blogana_user : std_logic_vector(19 downto 0);

begin
	uif_reset   <= '0';
	uif_wr_data_o <= uif_wr_data;
	uif_rd_data   <= uif_rd_data_i;

	process(clk2) begin
		if(clk2'event and clk2='1') then
			if(timer2 >= 83333333 - 1) then
				led(4) <= not led(4);
				timer2 <= 0;
			else
				timer2 <= timer2 + 1;
			end if;
		end if;
	end process;
	process(clk3) begin
		if(clk3'event and clk3='1') then
			if(timer3 >= 48000000 - 1) then
				led(5) <= not led(5);
				timer3 <= 0;
			else
				timer3 <= timer3 + 1;
			end if;
		end if;
	end process;

	process(clk) begin
		if(clk'event and clk='1') then
			if(pushsw_ip = '0') then
				if(timer >= CLKFREQ/10 - 1) then
					led(0) <= not led(0);
					timer <= 0;
				else
					timer <= timer + 1;
				end if;
			else
				if(timer = CLKFREQ - 1) then
					led(0) <= not led(0);
					timer <= 0;
				else
					timer <= timer + 1;
				end if;
			end if;
		end if;
	end process;
	led(1) <= sync_rst;
	led(2) <= init_done;
	led(3) <= mmcm_locked;
	led(6) <= '0';
	led(7) <= '0';

	process(clk) begin
		if(clk'event and clk='1') then
			if(uif_rd_rdy = '0') then -- USBからの読み出し要求が終了した
				bram_wr_addr <= (others => '0');
				uif_rd <= '0';
			else
				case uif_flag(2 downto 0) is
					when "000" => -- ターゲットなしNULL
						uif_rd <= '1'; -- 常に許可
					when "001" => -- BRAMへの書き込み
						uif_rd <= '1'; -- 常に許可
					when "010" => -- SDRAMへの書き込み
--						uif_rd <= dram_wfifo_wrready;
					when others => -- GPIOへの書き込み その他
						uif_rd <= '1'; -- 常に許可
				end case;

				if((uif_rd and (not uif_rd_wait)) = '1') then
					bram_wr_addr <= bram_wr_addr + 1;
				end if;
			end if;
		end if;
	end process;

	bram_wr_en <= uif_rd and (not uif_rd_wait) when (uif_flag(2 downto 0) = "001") else '0';

	inst_blk_mem_gen_0 : blk_mem_gen_0 port map (
		clka   => clk,
		ena    => '1',
		wea(0) => bram_wr_en,
		addra  => bram_wr_addr,
		dina   => uif_rd_data,
		clkb   => clk,
		enb    => '1',
		addrb  => bram_rd_addr,
		doutb  => BRAM_DOUT
	);

	process(clk) begin
		if(clk'event and clk='1') then
			if(uif_wr_req = '0') then
				uif_wr_pre <= '0';
			else
				if(uif_wr_wait = '1') then -- HOST側のWAIT要求
					uif_wr_pre <= '0';
				else
					if(uif_flag(2 downto 0) = "010") then
--						if(dram_rfifo_empty = '1') then
--							uif_wr_pre <= '0';
--						else
--							uif_wr_pre <= '1';
--						end if;
					else
						uif_wr_pre <= '1';
					end if;
				end if;
			end if;

			if(uif_flag(2 downto 0) = "010") then
--				uif_wr <= uif_wr_pre and (not dram_rfifo_empty);
			else
				uif_wr <= uif_wr_pre;
			end if;

			-- BRAM address generator
			if(uif_wr_req = '0') then -- There is no request for IN transfer.
				bram_rd_addr <= (others => '0');
			else
				if(uif_wr_pre = '1') then -- data write occures at next clock
					if(uif_flag(2 downto 0) = "001") then -- data source is BRAM
						bram_rd_addr <= bram_rd_addr + 1;
					end if;
				end if;
			end if;

			-- Test pattern generator
			LFSR <= LFSR(30 downto 0) & 
					(not LFSR(31) xor LFSR(27) xor LFSR(24) xor LFSR(16) xor LFSR(12) xor LFSR(5) xor LFSR(2) xor LFSR(1));

			if(uif_wr_req = '0') then -- There is no request for IN transfer.
				HCOUNT <= (others => '0');
				VCOUNT <= (others => '0');
			else
				if(uif_wr_pre = '1') and (uif_wr_req = '1') then -- data write occures at next clock
					if(uif_flag(1 downto 0) = "000") then -- data source is test pattern
						if(HCOUNT(2 downto 0) = 0) then
							SEQ_PATTERN(7 downto 0) <= x"ff";
							SEQ_PATTERN(15 downto 8) <= x"00";
						else
							SEQ_PATTERN(7 downto 0) <= x"00";
							SEQ_PATTERN(15 downto 8) <= x"00";
						end if;
--							SEQ_PATTERN(7 downto 0) <= SEQ_PATTERN(7 downto 0) + 2;
--							SEQ_PATTERN(15 downto 8) <= SEQ_PATTERN(7 downto 0) + 3;
						if(HCOUNT = 320-1) then
							HCOUNT <= (others => '0');
							if(VCOUNT = 480-1) then
								VCOUNT <= (others => '0');
								FRAMENUM <= FRAMENUM + 1;
							else
								VCOUNT <= VCOUNT + 1;
							end if;
						else
							HCOUNT <= HCOUNT + 1;
						end if;
					end if;
				end if;
			end if;

			-- Test pattern selector
			case uif_flag(5 downto 3) is
				when "000" => -- sequential pattern
					TEST_PATTERN <= SEQ_PATTERN;
				when "001" => -- Horizontal gradation
					TEST_PATTERN <= HCOUNT(6 downto 0) & '1' & HCOUNT(6 downto 0) & '0';
				when "010" => -- Vertical gradation
					TEST_PATTERN <= VCOUNT(7 downto 0) & VCOUNT(7 downto 0);
				when "011" => -- Frame number
					TEST_PATTERN <= FRAMENUM & FRAMENUM;
				when "100" => -- random pattern
					TEST_PATTERN <= LFSR(15 downto 0);
				when others =>
					TEST_PATTERN <= x"0000";
			end case;
		end if;
	end process;
	
--	SDRAM_DOUT       <= dram_rfifo_rdata;

	-- Write data selector
	uif_wr_data <= TEST_PATTERN when (uif_flag(1 downto 0) = "000") else
	               BRAM_DOUT    when (uif_flag(1 downto 0) = "001") else
			       SDRAM_DOUT   when (uif_flag(1 downto 0) = "010") else
			       GPIO_DOUT    when (uif_flag(1 downto 0) = "011") else
				   x"0000";
				
	uif_wr_o <= uif_wr;
	uif_rd_o <= uif_rd;
	   
	led_op <= not led;
	

--	inst_blogana2 :  blogana2 generic map
--	(
--		BIT_WIDTH     => 144,
--		SAMPLE_LENGTH => 2048
--	)
--	port map
--	(
--		clk => clk,
--		trig => blogana_trig,
--		din  => blogana_din,
--		USER_OP   => blogana_user,
--		SAMPLE_EN => '1',--spi_debug(15),
--		samp_freq => 100000000,
--		busy => blogana_busy
--	);

--	blogana_trig <= uif_rd_rdy when (BLOGANA_USER(19) = '1') else
--					uif_wr_req when (BLOGANA_USER(18) = '1') else
--					'0';

--	BLOGANA_DIN(15  downto   0)  <= uif_wr_data;
--	BLOGANA_DIN(41  downto  16)  <= uif_addr(25 downto 0);
--	BLOGANA_DIN(65  downto  42)  <= uif_len(23 downto 0);
--	BLOGANA_DIN(81  downto  66)  <= uif_flag;
--	BLOGANA_DIN(97  downto  82)  <= uif_rd_data;
--	BLOGANA_DIN(114)  <= uif_wr;
--	BLOGANA_DIN(115)  <= uif_rd;
--	BLOGANA_DIN(116)  <= uif_rd_rdy;
--	BLOGANA_DIN(117)  <= uif_rd_wait;
--	BLOGANA_DIN(118)  <= uif_wr_req;
--	BLOGANA_DIN(119)  <= uif_wr_wait;
--	BLOGANA_DIN(120)  <= uif_wr_pre;

end Behavioral;
