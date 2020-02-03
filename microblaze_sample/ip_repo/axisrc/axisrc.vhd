library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity axisrc is
	generic (
		AXI_ID_WIDTH        : integer range 0 to 4 := 1;
		USE_BLOGANA         : boolean := false
	);
	port (
		aclk                : in  std_logic;
		aresetn             : in  std_logic;
		
		enable              : in  std_logic;

	-- Master Interface Write Address Ports
		axi_awid_o    	    : out STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
		axi_awaddr_o    	: out STD_LOGIC_VECTOR(31 downto 0);
		axi_awlen_o     	: out STD_LOGIC_VECTOR(7 downto 0);
		axi_awsize_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		axi_awburst_o   	: out STD_LOGIC_VECTOR(1 downto 0);
		axi_awlock_o    	: out STD_LOGIC_VECTOR(0 downto 0);
		axi_awcache_o   	: out STD_LOGIC_VECTOR(3 downto 0);
		axi_awprot_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		axi_awqos_o     	: out STD_LOGIC_VECTOR(3 downto 0);
		axi_awvalid_o   	: out STD_LOGIC;
		axi_awready_i   	: in  STD_LOGIC;
	-- Master Interface Write Data Ports
		axi_wdata_o     	: out STD_LOGIC_VECTOR(63 downto 0);
		axi_wstrb_o     	: out STD_LOGIC_VECTOR(7 downto 0);
		axi_wlast_o     	: out STD_LOGIC;
		axi_wvalid_o    	: out STD_LOGIC;
		axi_wready_i    	: in  STD_LOGIC;
	-- Master Interface Write Response Ports
		axi_bready_o    	: out STD_LOGIC;
		axi_bid_i       	: in  STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
		axi_bresp_i     	: in  STD_LOGIC_VECTOR(1 downto 0);
		axi_bvalid_i    	: in  STD_LOGIC;
	-- Master Interface Read Address Ports
		axi_arid_o      	: out STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
		axi_araddr_o    	: out STD_LOGIC_VECTOR(31 downto 0);
		axi_arlen_o     	: out STD_LOGIC_VECTOR(7 downto 0);
		axi_arsize_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		axi_arburst_o   	: out STD_LOGIC_VECTOR(1 downto 0);
		axi_arlock_o    	: out STD_LOGIC_VECTOR(0 downto 0);
		axi_arcache_o   	: out STD_LOGIC_VECTOR(3 downto 0);
		axi_arprot_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		axi_arqos_o     	: out STD_LOGIC_VECTOR(3 downto 0);
		axi_arvalid_o   	: out STD_LOGIC;
		axi_arready_i   	: in  STD_LOGIC;
	-- Master Interface Read Data Ports
		axi_rready_o      : out STD_LOGIC;
		axi_rid_i         : in  STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
		axi_rdata_i       : in  STD_LOGIC_VECTOR(63 downto 0);
		axi_rresp_i       : in  STD_LOGIC_VECTOR(1 downto 0);
		axi_rlast_i       : in  STD_LOGIC;
		axi_rvalid_i      : in  STD_LOGIC;

		WR_START_ADDR       : std_logic_vector(31 downto 0) := x"00000000";
		WR_LENGTH           : std_logic_vector(31 downto 0) := x"00010000"; -- 8 byte 
		WR_TYPE             : std_logic_vector(1 downto 0):= "00" -- 0:Mono color 1:sequential 2:random 3:seruential
	);
end axisrc;


architecture Behavioral of axisrc is

	signal clk                  : STD_LOGIC;
	
	signal axi_awid      	: STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
	signal axi_awaddr      	: STD_LOGIC_VECTOR(31 downto 0);
	signal axi_awlen       	: STD_LOGIC_VECTOR(7 downto 0);
	signal axi_awsize      	: STD_LOGIC_VECTOR(2 downto 0);
	signal axi_awburst     	: STD_LOGIC_VECTOR(1 downto 0);
	signal axi_awlock      	: STD_LOGIC_VECTOR(0 downto 0);
	signal axi_awcache     	: STD_LOGIC_VECTOR(3 downto 0);
	signal axi_awprot      	: STD_LOGIC_VECTOR(2 downto 0);
	signal axi_awqos       	: STD_LOGIC_VECTOR(3 downto 0);
	signal axi_awvalid     	: STD_LOGIC;
	signal axi_awready     	: STD_LOGIC;
	signal axi_wdata       	: STD_LOGIC_VECTOR(63 downto 0);
	signal axi_wstrb       	: STD_LOGIC_VECTOR(7 downto 0);
	signal axi_wlast       	: STD_LOGIC;
	signal axi_wvalid      	: STD_LOGIC;
	signal axi_wready      	: STD_LOGIC;
	signal axi_bready      	: STD_LOGIC;
	signal axi_bid         	: STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
	signal axi_bresp       	: STD_LOGIC_VECTOR(1 downto 0);
	signal axi_bvalid      	: STD_LOGIC;
	signal axi_bvalid_detect : STD_LOGIC;
	signal axi_arid        	: STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
	signal axi_araddr      	: STD_LOGIC_VECTOR(31 downto 0);
	signal axi_arlen       	: STD_LOGIC_VECTOR(7 downto 0);
	signal axi_arsize       : STD_LOGIC_VECTOR(2 downto 0);
	signal axi_arburst      : STD_LOGIC_VECTOR(1 downto 0);
	signal axi_arlock       : STD_LOGIC_VECTOR(0 downto 0);
	signal axi_arcache      : STD_LOGIC_VECTOR(3 downto 0);
	signal axi_arprot       : STD_LOGIC_VECTOR(2 downto 0);
	signal axi_arqos        : STD_LOGIC_VECTOR(3 downto 0);
	signal axi_arvalid      : STD_LOGIC;
	signal axi_arready      : STD_LOGIC;
	signal axi_rready       : STD_LOGIC;
	signal axi_rid          : STD_LOGIC_VECTOR(AXI_ID_WIDTH - 1 downto 0);
	signal axi_rdata        : STD_LOGIC_VECTOR(63 downto 0);
	signal axi_rresp        : STD_LOGIC_VECTOR(1 downto 0);
	signal axi_rlast        : STD_LOGIC;
	signal axi_rvalid       : STD_LOGIC;

    signal start_addr    : std_logic_vector(31 downto 0);
    signal write_length  : std_logic_vector(31 downto 0);
    signal wr_remain     : std_logic_vector(31 downto 0);
    signal wr_addr       : std_logic_vector(31 downto 0);
    signal wstate        : std_logic_vector(2 downto 0);

    signal rd_remain     : std_logic_vector(31 downto 0);
    signal rd_state       : std_logic_vector(2 downto 0);

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

	constant MAX_PERIOD : integer := 10000000;
	signal period_timer : integer range 0 to MAX_PERIOD - 1;
	signal trigger_rd : std_logic;
	signal trigger_wr : std_logic;
	signal toggle : std_logic := '0';
	signal color  : std_logic_vector(7 downto 0) := x"00";
	signal seq    : std_logic_vector(63 downto 0) := x"0000000000000000";
	signal rand   : std_logic_vector(63 downto 0) := x"0000000000000000";

	component xorshift is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en : in  STD_LOGIC;
           res2  : out  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
	end component ;

	signal xs_res_count : integer range 0 to 7 := 0;
	signal xs_res : std_logic;
	signal xs_next : std_logic;
	signal xs_res2   : std_logic_vector(31 downto 0);
	signal xs_result : std_logic_vector(31 downto 0);

begin
	clk <= aclk;
	
	axi_awid_o    	    <= axi_awid;
	axi_awaddr_o    	<= axi_awaddr;
	axi_awlen_o     	<= axi_awlen;
	axi_awsize_o    	<= axi_awsize;
	axi_awburst_o   	<= axi_awburst;
	axi_awlock_o    	<= axi_awlock;
	axi_awcache_o   	<= axi_awcache;
	axi_awprot_o        <= axi_awprot;
	axi_awqos_o     	<= axi_awqos;
	axi_awvalid_o   	<= axi_awvalid;
	axi_awready     	<= axi_awready_i;
	axi_wdata_o     	<= axi_wdata;
	axi_wstrb_o     	<= axi_wstrb;
	axi_wlast_o     	<= axi_wlast;
	axi_wvalid_o    	<= axi_wvalid;
	axi_wready      	<= axi_wready_i;
	axi_bready_o    	<= axi_bready;
	axi_bid         	<= axi_bid_i;
	axi_bresp       	<= axi_bresp_i;
	axi_bvalid      	<= axi_bvalid_i;
	axi_arid_o      	<= axi_arid;
	axi_araddr_o    	<= axi_araddr;
	axi_arlen_o     	<= axi_arlen;
	axi_arsize_o    	<= axi_arsize;
	axi_arburst_o   	<= axi_arburst;
	axi_arlock_o    	<= axi_arlock;
	axi_arcache_o   	<= axi_arcache;
	axi_arprot_o    	<= axi_arprot;
	axi_arqos_o     	<= axi_arqos;
	axi_arvalid_o   	<= axi_arvalid;
	axi_arready     	<= axi_arready_i;
	axi_rready_o        <= axi_rready;
	axi_rid             <= axi_rid_i;
	axi_rdata           <= axi_rdata_i;
	axi_rresp           <= axi_rresp_i;
	axi_rlast           <= axi_rlast_i;
	axi_rvalid          <= axi_rvalid_i;

	axi_awsize <= "011"; -- 64bit?
	axi_awburst <= "01"; -- increment
	axi_awcache <= "0011"; -- Normal Non-cacheable Bufferable
	axi_awprot  <= "000";
	axi_awlock    	<= "0";
	axi_awqos     	<= (others => '0');

	axi_arprot      <= "000";
	axi_arid      	<= (others => '0');
	axi_arlock    	<= "0";
	axi_arqos     	<= "0000";
	
	write_length    <= WR_LENGTH;
	start_addr      <= WR_START_ADDR;

	process(clk) begin
		if(clk'event and clk='1') then
			if(enable = '1') then
				if(period_timer = MAX_PERIOD - 1) then
					period_timer <= 0;
					if(toggle = '0') then
						trigger_wr <= '0';
						trigger_rd <= '1';
	  
						toggle <= '1';
					else
						trigger_wr <= '1';
						trigger_rd <= '0';
						toggle <= '0';
					end if;
												
					color <= color + x"01";
				else
					period_timer <= period_timer + 1;
					trigger_rd <= '0';
					trigger_wr <= '0';
				end if;
			else
				trigger_rd <= '0';
				trigger_wr <= '0';
			end if;
		end if;
	end process;

	process(clk) begin
		if(clk'event and clk = '1') then
			if(axi_awready = '1') and (axi_awvalid = '1') then
				axi_bvalid_detect <= '0';
			elsif(axi_bvalid = '1') then
				axi_bvalid_detect <= '1';
			end if;

			if(aresetn = '0') then
				axi_wvalid  <= '0';
				axi_awvalid <= '0';
				axi_awid    <= (others => '0');
				wstate  <= "000";
			else
				case wstate is
					when "000" =>
						axi_wvalid <= '0';
						axi_awvalid <= '0';
						axi_wstrb <= "00000000";
						axi_wlast <= '0';
						axi_bready <= '1';

						if(trigger_wr = '1') then -- キャプチャ開始前の待ち状態
							wr_addr    <= start_addr;
							axi_awaddr <= start_addr;
							wr_remain  <= write_length(31 downto 0);
							wstate      <= "001"; 
						end if;

					when "001" =>
--						axi_bready <= '0';
						if(wr_remain = 0) then -- 残りの書き込みデータがない
							wstate <= "110";
						else
							wstate <= "010";
						end if;

					when "010" => -- ADDR発行
						axi_awvalid <= '1';
						if(wr_remain >= 256) then
							axi_awlen <= conv_std_logic_vector(256 - 1,8);
						else
							axi_awlen <= wr_remain(7 downto 0) - 1;
						end if;
						wstate <= "011";

					when "011" => -- ADDR確認

						if(axi_awready = '1') then -- ADDR受け入れ可能
							axi_awid <= axi_awid + 1;
							axi_awvalid <= '0';
							if(wr_remain >= 256) then
								wr_remain <= wr_remain - 256;
							else
								wr_remain <= (others => '0');
							end if;
							wstate <= "100";
						else
--							timer <= timer + 1;
--							if(timer = "11111111") then
--								wr_remain <= (others => '0');
--								adc_wstate <= "101";
--							end if;
						end if;
						if(axi_awlen = 0) then
							axi_wlast <= '1';
						end if;

					when "100" => -- DATA送信
						axi_wstrb <= "11111111";
						if(axi_wready = '1') then
--						  ((axi_wready = '1') and (rawfifo_empty1 = '0') and (adc_rch = '1')) then
							if(axi_wvalid = '1') then -- 書き込み成功
								axi_awaddr <= axi_awaddr + 8;
								axi_awlen <= axi_awlen - 1;
								if(axi_awlen = 1) then -- 次はラスト
									axi_wlast <= '1';
								end if;
								if(axi_awlen = 0) then -- 次はない
									axi_wlast <= '0';
									axi_wvalid <= '0';
									wstate <= "101";
								else
									axi_wvalid <= '1';
								end if;
							else
								axi_wvalid <= '1';
							end if;
						else
--							timer <= timer + 1;
--							if(timer = "11111111") then
--								axi_wlast <= '1';
--								wr_remain <= (others => '0');
--								wstate <= "101";
--							end if;
							axi_wvalid <= '0';
						end if;

					when "101" =>
						axi_awvalid <= '0';
						axi_wvalid <= '0';
						axi_wstrb <= "00000000";
						axi_wlast <= '0';
--						if(axi_bvalid_detect = '1') then
--							wstate <= "000";
--						end if;
						wstate <= "001";

					when "110" =>
						axi_wvalid <= '0';
						axi_awvalid <= '0';
						axi_wstrb <= "00000000";
						axi_wlast <= '0';
						axi_bready <= '1';
						wstate <= "000";

					when others =>
						wstate <= "000";
				end case;
			end if;
		end if;
	end process;

	process(clk) begin
		if(clk'event and clk='1') then
			if(aresetn = '0') then
				seq <= x"0706050403020100";
			else
				if (WR_TYPE = "01") or ((WR_TYPE = "11") and (axi_wvalid = '1') and (axi_wready = '1')) then
					seq(63 downto 56) <=seq(63 downto 56) + 8; 
					seq(55 downto 48) <=seq(55 downto 48) + 8; 
					seq(47 downto 40) <=seq(47 downto 40) + 8; 
					seq(39 downto 32) <=seq(39 downto 32) + 8; 
					seq(31 downto 24) <=seq(31 downto 24) + 8; 
					seq(23 downto 16) <=seq(23 downto 16) + 8; 
					seq(15 downto  8) <=seq(15 downto  8) + 8; 
					seq( 7 downto  0) <=seq( 7 downto  0) + 8; 
				end if;
			end if;
		end if;
	end process;

	xs_res <= not aresetn;
	xs_next <= '1';

	inst_xorshift : xorshift port map (
		clk    => clk,
		reset  => xs_res,
		en     => xs_next, 
        res2   => rand(63 downto 32),
        result => rand(31 downto 0)
	);

	axi_wdata <= color & color & color & color & color & color & color & color when (WR_TYPE = "00") else
	             seq when (WR_TYPE = "01") else
	             rand when (WR_TYPE = "10") else
	             seq;

	-- READ State machine
	process(clk) begin
		if(clk'event and clk = '1') then
			if(aresetn = '0') then
				axi_rready <= '0';
				axi_arvalid <= '0';
				axi_araddr <= (others => '0');
				rd_state <= "000";
				axi_arsize      <= "000";
				axi_arburst     <= "00";
				axi_arcache     <= "0000";
			else
				case rd_state is
					when "000" =>
						axi_araddr <= (others => '0');
						axi_rready <= '0';
						axi_arvalid <= '0';
						axi_arsize      <= "000";
						axi_arburst     <= "00";
						axi_arcache     <= "0000";
						if(trigger_rd = '1') then
							rd_state <= "001";
							rd_remain  <= x"00000200";
						end if;
					
					when "001" =>
						if(rd_remain = 0) then
							rd_state <= "110";
--						elsif(d2ufifo_full = '0') then -- FIFOがFULLならここでWAIT
						else
							axi_arvalid <= '1';
							axi_arsize      <= "011"; -- 64bit?
							axi_arburst     <= "01"; -- increment
							axi_arcache     <= "0011"; -- Normal Non-cacheable Bufferable
							rd_state <= "010";
						end if;

					when "010" => -- ADDR発行
						if(axi_arready = '1') then -- ADDR受け入れ可能
							axi_arvalid <= '0';
							axi_arsize      <= "000";
							axi_arburst     <= "00";
							axi_arcache     <= "0000";
							if(rd_remain >= 64) then
								axi_arlen <= conv_std_logic_vector(64 - 1,8);
							else
								axi_arlen <= rd_remain(7 downto 0) - 1;
							end if;
							rd_state <= "011";
						end if;

					when "011" => -- ADDR確認
						axi_arvalid <= '0';
						if(rd_remain >= 64) then
							rd_remain <= rd_remain - 64;
						else
							rd_remain <= (others => '0');
						end if;
						axi_rready <= '1';
						rd_state <= "100";

					when "100" => -- DATA受信
						axi_arvalid <= '0';
						if(axi_rvalid = '1') and (axi_rready = '1') then
							axi_araddr <= axi_araddr + 8;
							axi_arlen <= axi_arlen - 1;
							if(axi_arlen = 0) then
								axi_rready <= '0';
								rd_state <= "101";
							end if;
						end if;

					when "101" =>
						rd_state <= "001";
						axi_rready <= '0';

					when others =>
--						if(blogana_user(17) = '0') then
							rd_state <= "000";
--						end if;
						axi_rready <= '0';
				end case;
			end if;
		end if;
	end process;

	if_inst_blogana : if USE_BLOGANA generate
		inst_blogana2 :  blogana2 generic map
		(
			BIT_WIDTH     => 144,
			SAMPLE_LENGTH => 2048
		)
		port map
		(
			clk => clk,
			trig => blogana_trig,
			din  => blogana_din,
			USER_OP   => blogana_user,
			SAMPLE_EN => '1',--spi_debug(15),
			samp_freq => 100000000,
			busy => blogana_busy
		);
	end generate;

    blogana_trig <= trigger_rd or trigger_wr;
	blogana_din(15 downto 0)  <= axi_wdata(15 downto 0);
	blogana_din(47 downto 16) <= axi_awaddr;
	blogana_din(48)           <= axi_awready;
	blogana_din(49)           <= axi_awvalid;
	blogana_din(50)           <= axi_wready;
	blogana_din(51)           <= axi_wvalid;
	blogana_din(52)           <= axi_wlast;
	blogana_din(53 + AXI_ID_WIDTH - 1 downto 53) <= axi_awid;
	blogana_din(59 downto 57) <= wstate;
	blogana_din(70 downto 60) <= wr_remain(10 downto 0);
	blogana_din(71)           <= trigger_wr;
	blogana_din(72)           <= axi_rready;
	blogana_din(73)           <= axi_rvalid;
	blogana_din(74)           <= axi_rlast;
	blogana_din(75)           <= axi_arready;
	blogana_din(76)           <= axi_arvalid;
	blogana_din(108 downto 77) <= axi_araddr;
	blogana_din(109 + AXI_ID_WIDTH - 1 downto 109) <= axi_arid;
	blogana_din(115 downto 113) <= rd_state;
	blogana_din(126 downto 116) <= rd_remain(10 downto 0);
	blogana_din(127)           <= trigger_rd;
	blogana_din(130 downto 128)           <= axi_arsize;
	blogana_din(132 downto 131)           <= axi_arburst;
	blogana_din(136 downto 133)           <= axi_arcache;

end Behavioral;
