----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:56:43 04/22/2014 
-- Design Name: 
-- Module Name:    fx3_axi - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fx2_axi is generic (
	AXI_ID_WIDTH     : integer range 0 to 4 := 3;
	MAX_IREGS        : integer range 1 to 16 := 16;
	FLAG_NUM_IREG    : integer range 0 to 255 := 0;
	FLAG_NUM_BRAM    : integer range 0 to 255 := 1;
	FLAG_NUM_AXI     : integer range 0 to 255 := 2;
	BRAM_ADDR_WIDTH  : integer range 0 to 19 := 17;
	USE_BLOGANA      : boolean := true
);
port (
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
--		usb_reset_bp          : inout std_logic;

	-- user interface port (mandantory)
		clk100m_i             : in   std_logic;
		reset_i               : in   std_logic; -- active high

	------------------------------------------------------------
	-- AXI Master Port
	------------------------------------------------------------
		m_axi_aclk             : in  STD_LOGIC;
		m_axi_aresetn          : in  STD_LOGIC;
	-- Master Interface Write Address Ports
		m_axi_awid_o    	: out STD_LOGIC_VECTOR(AXI_ID_WIDTH-1 downto 0);
		m_axi_awaddr_o    	: out STD_LOGIC_VECTOR(31 downto 0);
		m_axi_awlen_o     	: out STD_LOGIC_VECTOR(7 downto 0);
		m_axi_awsize_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		m_axi_awburst_o   	: out STD_LOGIC_VECTOR(1 downto 0);
		m_axi_awlock_o    	: out STD_LOGIC_VECTOR(0 downto 0);
		m_axi_awcache_o   	: out STD_LOGIC_VECTOR(3 downto 0);
		m_axi_awprot_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		m_axi_awqos_o     	: out STD_LOGIC_VECTOR(3 downto 0);
		m_axi_awvalid_o   	: out STD_LOGIC;
		m_axi_awready_i   	: in  STD_LOGIC;
	-- Master Interface Write Data Ports
		m_axi_wdata_o     	: out STD_LOGIC_VECTOR(63 downto 0);
		m_axi_wstrb_o     	: out STD_LOGIC_VECTOR(7 downto 0);
		m_axi_wlast_o     	: out STD_LOGIC;
		m_axi_wvalid_o    	: out STD_LOGIC;
		m_axi_wready_i    	: in  STD_LOGIC;
	-- Master Interface Write Response Ports
		m_axi_bready_o    	: out STD_LOGIC;
		m_axi_bid_i       	: in  STD_LOGIC_VECTOR(AXI_ID_WIDTH-1 downto 0);
		m_axi_bresp_i     	: in  STD_LOGIC_VECTOR(1 downto 0);
		m_axi_bvalid_i    	: in  STD_LOGIC;
	-- Master Interface Read Address Ports
		m_axi_arid_o      	: out STD_LOGIC_VECTOR(AXI_ID_WIDTH-1 downto 0);
		m_axi_araddr_o    	: out STD_LOGIC_VECTOR(31 downto 0);
		m_axi_arlen_o     	: out STD_LOGIC_VECTOR(7 downto 0);
		m_axi_arsize_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		m_axi_arburst_o   	: out STD_LOGIC_VECTOR(1 downto 0);
		m_axi_arlock_o    	: out STD_LOGIC_VECTOR(0 downto 0);
		m_axi_arcache_o   	: out STD_LOGIC_VECTOR(3 downto 0);
		m_axi_arprot_o    	: out STD_LOGIC_VECTOR(2 downto 0);
		m_axi_arqos_o     	: out STD_LOGIC_VECTOR(3 downto 0);
		m_axi_arvalid_o   	: out STD_LOGIC;
		m_axi_arready_i   	: in  STD_LOGIC;
	-- Master Interface Read Data Ports
		m_axi_rready_o      : out STD_LOGIC;
		m_axi_rid_i         : in  STD_LOGIC_VECTOR(AXI_ID_WIDTH-1 downto 0);
		m_axi_rdata_i       : in  STD_LOGIC_VECTOR(63 downto 0);
		m_axi_rresp_i       : in  STD_LOGIC_VECTOR(1 downto 0);
		m_axi_rlast_i       : in  STD_LOGIC;
		m_axi_rvalid_i      : in  STD_LOGIC;

	------------------------------------------------------------
	-- BRAM interface
	------------------------------------------------------------
		bram_clk_o          : out  std_logic;
		bram_rst_o          : out  std_logic;
		bram_en_o           : out  std_logic;
		bram_wea_o          : out  std_logic_vector(0 downto 0);
		bram_addr_o         : out  std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0);
		bram_wrdata_o       : out  std_logic_vector(31 downto 0);
		bram_rddata_i       : in   std_logic_vector(31 downto 0);

	------------------------------------------------------------
	-- Tokuden Local Interface Port
	------------------------------------------------------------
	-- user interface port (tokuden original)
--		bulkout_ready_i     : in   std_logic; -- not implement yet
--		bulkout_wait_i      : in   std_logic; -- User circuit is ready but nomore data cannot be received.
--		bulkout_start_o     : out  std_logic; -- Start timing of bulkout (SOF)
--		bulkout_busy_o      : out  std_logic; -- now running.
--		bulkout_end_o       : out  std_logic; -- End timing. (EOF)
--		bulkout_dvalid_o    : out  std_logic; -- Received data is valid
--		bulkout_data_o      : out  std_logic_vector(31 downto 0);
				
--		bulkin_ready_i      : in   std_logic; -- not implement yet
--		bulkin_start_o      : out  std_logic; -- Bulkin start (SOF)
--		bulkin_busy_o       : out  std_logic; -- now running.
--		bulkin_end_o        : out  std_logic; -- Bulkin end (EOF)
--		bulkin_data_i       : in   std_logic_vector(31 downto 0);
--		bulkin_dreq_o       : out  std_logic; -- Bulkin data request
--		bulkin_dvalid_i     : in   std_logic; -- Send data is valid
--		bulkin_abort_i      : in   std_logic; -- Abort and send PKTEND

--		datalen_o           : out  std_logic_vector(31 downto 0);
--		addr_o              : out  std_logic_vector(31 downto 0);
--		flag_o              : out  std_logic_vector(15 downto 0);

	------------------------------------------------------------
	-- Simple internal registers
	------------------------------------------------------------
		ireg_op             : out  std_logic_vector(MAX_IREGS*16-1 downto 0);
		ireg_ip             : in   std_logic_vector(MAX_IREGS*16-1 downto 0);
		ireg_updated_op     : out  std_logic_vector(MAX_IREGS-1 downto 0);
		ireg_captured_op    : out  std_logic_vector(MAX_IREGS-1 downto 0);

	-- Debug ports
		debug_op            : out  std_logic_vector(15 downto 0)
	);
end fx2_axi;

architecture Behavioral of fx2_axi is

	signal clk100m             : std_logic;
	signal axiclk              : std_logic;
	signal axireset            : std_logic;

    signal m_axi_awaddr        : std_logic_vector(31 downto 0);
    signal m_axi_awlen         : std_logic_vector(7 downto 0);
    signal m_axi_awsize        : std_logic_vector(2 downto 0);
    signal m_axi_awburst       : std_logic_vector(1 downto 0);
    signal m_axi_awcache       : std_logic_vector(3 downto 0);
    signal m_axi_awprot        : std_logic_vector(2 downto 0);
    signal m_axi_awvalid       : std_logic;
    signal m_axi_awready        : std_logic;
	signal m_axi_awid           : STD_LOGIC_VECTOR(AXI_ID_WIDTH-1 downto 0);
    signal m_axi_wdata          : std_logic_vector(63 downto 0);
    signal m_axi_wstrb          : std_logic_vector(7 downto 0);
    signal m_axi_wlast          : std_logic;
    signal m_axi_wvalid         : std_logic;
    signal m_axi_wready         : std_logic;
    signal m_axi_bresp          : std_logic_vector(1 downto 0);
    signal m_axi_bvalid         : std_logic;
    signal m_axi_bvalid_detect  : std_logic;
    signal m_axi_bready       : std_logic;
    signal m_axi_araddr       : std_logic_vector(31 downto 0);
    signal m_axi_arlen        : std_logic_vector(7 downto 0);
    signal m_axi_arsize       : std_logic_vector(2 downto 0);
    signal m_axi_arburst      : std_logic_vector(1 downto 0);
    signal m_axi_arcache      : std_logic_vector(3 downto 0);
    signal m_axi_arprot       : std_logic_vector(2 downto 0);
    signal m_axi_arvalid      : std_logic;
    signal m_axi_arready      : std_logic;
    signal m_axi_rdata         : std_logic_vector(63 downto 0);
    signal m_axi_rresp         : std_logic_vector(1 downto 0);
    signal m_axi_rlast         : std_logic;
    signal m_axi_rvalid        : std_logic;
    signal m_axi_rready        : std_logic;
    signal wr_remain           : std_logic_vector(31 downto 0);
    signal wr_state            : std_logic_vector(2 downto 0);
    signal rd_remain           : std_logic_vector(31 downto 0);
    signal rd_state            : std_logic_vector(2 downto 0);
	
	signal bvtimer             : std_logic_vector(7 downto 0);
	
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
--			usb_reset_bp          : inout std_logic;
	
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

	signal uif_reset          : std_logic;
	signal uif_rd_data        : std_logic_vector(15 downto 0);
    signal uif_wr_data        : std_logic_vector(15 downto 0);
    signal uif_rd_rdy         : std_logic;
	signal uif_rd_wait        : std_logic;
	signal uif_wr_req         : std_logic;
	signal uif_wr_wait        : std_logic;
	signal uif_rd             : std_logic;
	signal uif_wr             : std_logic;
	signal uif_length         : std_logic_vector(31 downto 0);
	signal uif_addr           : std_logic_vector(31 downto 0);
	signal uif_flag           : std_logic_vector(15 downto 0);

	signal mem_remain         : std_logic_vector(31 downto 0);
	signal debug              : std_logic_vector(31 downto 0); -- for debug
	
	signal axi_selected       : std_logic;
	signal ireg_selected      : std_logic;
	signal bram_selected      : std_logic;

	-- BRAMインタフェース
	signal bram_wea    : std_logic_vector(0 downto 0);
	signal bram_addr   : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0);
	signal bram_wrdata : std_logic_vector(31 downto 0);
	signal bram_rddata : std_logic_vector(31 downto 0);
	signal bram_rd_en  : std_logic;

	-- 内部レジスタ(汎用)
	signal ireg_rdata         : std_logic_vector(15 downto 0);
	signal ireg_wdata         : std_logic_vector(15 downto 0);
	signal ireg_raddr         : std_logic_vector(3 downto 0);
	signal ireg_waddr         : std_logic_vector(3 downto 0);
	signal ireg_rd_en         : std_logic;

	component u2dfifov is port (
		rst        : in  std_logic;
		wr_clk     : in  std_logic;
		rd_clk     : in  std_logic;
		din        : in  std_logic_vector(63 downto 0);
		wr_en      : in  std_logic;
		rd_en      : in  std_logic;
		dout       : out std_logic_vector(63 downto 0);
		full       : out std_logic;
		empty      : out std_logic;
		prog_full  : out std_logic;
		prog_empty : out std_logic
	);
	end component;
	signal u2dfifo_rst     : std_logic;
	signal u2dfifo_wr      : std_logic;
	signal u2dfifo_din     : std_logic_vector(63 downto 0);
	signal u2dfifo_rd      : std_logic;
	signal u2dfifo_wr_d    : std_logic;
	signal u2dfifo_wr_trig : std_logic;
	signal u2dfifo_dout    : std_logic_vector(63 downto 0);
	signal u2dfifo_empty   : std_logic;
	signal u2dfifo_full    : std_logic;

	signal dram_wreq     : std_logic;
	signal dram_wreq_d   : std_logic;
	signal dram_wack     : std_logic;
	signal dram_wackd    : std_logic;
	signal dram_wack_d   : std_logic;
	signal dram_wack_dd  : std_logic;
	signal dram_rreq     : std_logic;
	signal dram_rreq_d   : std_logic;
	signal dram_rack     : std_logic;
	signal dram_rackd    : std_logic;
	signal dram_rack_d   : std_logic;
	signal dram_rack_dd  : std_logic;
	signal dram_rwaddr   : std_logic_vector(31 downto 0);
	signal dram_rwlen    : std_logic_vector(31 downto 0);
	signal axi_rd_valid  : std_logic;
	signal axi_rd_data   : std_logic_vector(31 downto 0);

	component d2ufifov is port (
		rst        : in  std_logic;
		wr_clk     : in  std_logic;
		rd_clk     : in  std_logic;
		din        : in  std_logic_vector(63 downto 0);
		wr_en      : in  std_logic;
		rd_en      : in  std_logic;
		dout       : out std_logic_vector(63 downto 0);
		full       : out std_logic;
		empty      : out std_logic;
		prog_full  : out std_logic;
		prog_empty : out std_logic
	);
	end component;
	signal d2ufifo_rst   : std_logic;
	signal d2ufifo_wr    : std_logic;
	signal d2ufifo_din   : std_logic_vector(63 downto 0);
	signal d2ufifo_rd    : std_logic;
	signal d2ufifo_dout  : std_logic_vector(63 downto 0);
	signal d2ufifo_empty : std_logic;
	signal d2ufifo_full  : std_logic;
	signal d2ufifo_rd_trig : std_logic;

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

	clk100m <= clk100m_i;
	
	ireg_captured_op <= (others => '0'); -- *** NOT IMPLEMENTED ***

	-- flag(1 downto 0)に応じてさまざまなターゲットにつなぐセレクタ
	ireg_selected <= '1' when (uif_flag(2 downto 0) = FLAG_NUM_IREG) else '0';
	bram_selected <= '1' when (uif_flag(2 downto 0) = FLAG_NUM_BRAM) else '0';
	axi_selected  <= '1' when (uif_flag(2 downto 0) = FLAG_NUM_AXI) else '0';
	
	uif_wr <= ireg_rd_en      when (ireg_selected = '1') else  -- 内蔵レジスタ
--	          bram_rd_en      when (bram_selected = '1') else  -- BRAM
--			  axi_rd_valid    when (axi_selected = '1')  else  -- AXI
			  '0';
--			  bulkin_dvalid_i;

	uif_wr_data   <= ireg_rdata      when (ireg_selected = '1') else
--	                 bram_rddata     when (bram_selected = '1') else
--					 axi_rd_data     when (axi_selected = '1')  else
--					 bulkin_data_i;
                     (others => '0');

--	uif_wr_wait <=  '0'             when (ireg_selected = '1') else  -- 内蔵レジスタ
--	                '0'             when (bram_selected = '1') else  -- BRAM
--	                (u2dfifo_full)  when (axi_selected = '1')  else
--				 bulkout_wait_i;

--	bulkout_ready       <= bulkout_ready_i;
--	bulkout_start_o     <= bulkout_start;
--	bulkout_busy_o      <= bulkout_busy;
--	bulkout_end_o       <= bulkout_end;
--	bulkout_dvalid_o    <= bulkout_dvalid;
--	bulkout_data_o      <= bulkout_data;
--	bulkin_ready        <= bulkin_ready_i;
--	bulkin_start_o      <= bulkin_start;
--	bulkin_busy_o       <= bulkin_busy;
--	bulkin_end_o        <= bulkin_end;
--	bulkin_dreq_o       <= bulkin_dreq;
--	bulkin_abort        <= bulkin_abort_i;
--	datalen_o           <= uif_length; 
--	addr_o              <= uif_addr;
--	flag_o              <= uif_flag;

	inst_fx2 : ezusbfx2_ctrl port map (
		-- ezusb fx2 port
			usb_clkout_ip         => usb_clkout_ip,
			usb_ifclk_op          => usb_ifclk_op,
			usb_fd_bp             => usb_fd_bp,
			usb_flaga_ip          => usb_flaga_ip,
			usb_flagb_ip          => usb_flagb_ip,
			usb_flagc_ip          => usb_flagc_ip,
			usb_sloe_op           => usb_sloe_op,
			usb_slrd_op           => usb_slrd_op,
			usb_slwr_op           => usb_slwr_op,
			usb_fifoaddr_op       => usb_fifoaddr_op,
			usb_pktend_op         => usb_pktend_op,
--			usb_reset_bp          => usb_reset_bp,
	
		-- user interface port
			uif_sysclk_ip        => clk100m,
			uif_reset_ip         => uif_reset,
			uif_rd_data_op       => uif_rd_data,
			uif_wr_data_ip       => uif_wr_data,
			uif_rd_rdy_op        => uif_rd_rdy,
			uif_rd_wait_op       => uif_rd_wait,
			uif_wr_req_op        => uif_wr_req,
			uif_wr_wait_op       => uif_wr_wait,
			uif_rd_ip            => uif_rd,
			uif_wr_ip            => uif_wr,

		-- following signals are option
			uif_usbclk_op        => open,
			uif_length_op        => uif_length(24 downto 0),
			uif_addr_op          => uif_addr(26 downto 0),
			uif_flag_op          => uif_flag,
			uif_debug            => open    
    );

-- ********* ここから内部レジスタの回路 (target 0x00) ********** --
	process(clk100m) begin
		if(clk100m'event and clk100m='1') then
			if(uif_wr_req = '1') then
				ireg_waddr <= uif_addr(4 downto 1);
			elsif(uif_wr = '1') and (uif_wr_wait = '0') then
				ireg_waddr <= ireg_waddr + 1;
			end if;
		end if;
	end process;

	process(clk100m) begin
		if(clk100m'event and clk100m='1') then
			if(uif_rd_rdy = '1') then
				ireg_raddr <= uif_addr(4 downto 1);
				ireg_rd_en <= '0';
			elsif(uif_rd = '1') and (uif_rd_wait = '0') then
				ireg_raddr <= ireg_raddr + 1;
				ireg_rd_en <= '1';
			else
				ireg_rd_en <= '0';
			end if;
		end if;
	end process;

	loop_iregwr : FOR I in 0 to MAX_IREGS-1 generate
		process(clk100m) begin
			if(clk100m'event and clk100m='1') then
				if(uif_rd = '1') and (ireg_selected = '1')
					and (conv_integer(ireg_waddr) = I) then
					ireg_op(I * 16 + 15 downto I * 16) <= uif_rd_data;
					ireg_updated_op(I) <= '1';
				else
					ireg_updated_op(I) <= '0';
				end if;
			end if;
		end process;
	end generate;


	process(clk100m) begin
		if(clk100m'event and clk100m='1') then
			ireg_rdata <= ireg_ip(conv_integer(ireg_raddr) * 16 + 15 downto conv_integer(ireg_raddr) * 16);
		end if;
	end process;

--	loop_iregrd : FOR I in 0 to MAX_IREGS generate
--		variable iregrd_tmp : std_logic_vector(31 downto 0);
--	end generate;

--			case conv_integer(ireg_raddr) is
--			IREGRD_LOOP: FOR I in 0 to MAX_IREGS-2 loop
--				when I =>
--					ireg_rdata <= ireg_ip(I);
--				end loop;
--				when others =>
--					ireg_rdata <= ireg_ip(MAX_IREGS-1);
--			end case;
--		end if;
--	end process;

-- ********* ここからBRAMの回路 (target 0x01) ********** --

	bram_clk_o <= clk100m;
	bram_rst_o <= '0';
	bram_en_o  <= '1';

--	process(clk100m) begin
--		if(clk100m'event and clk100m='1') then
--			if(bulkout_start = '1') or (bulkin_start = '1') then
--				bram_addr <= uif_addr(BRAM_ADDR_WIDTH+1 downto 2);
--			elsif(bulkout_dvalid = '1') or (bulkin_dreq = '1') then
--				bram_addr <= bram_addr + 1;
--			end if;
--		end if;
--	end process;

--	process(clk100m) begin
--		if(clk100m'event and clk100m='1') then
--			if(bulkin_start = '1') then
--				bram_rd_en <= '0';
--			elsif(bulkin_dreq = '1') then
--				bram_rd_en <= '1';
--			else
--				bram_rd_en <= '0';
--			end if;
--		end if;
--	end process;

--	bram_wrdata <= bulkout_data;
--	bram_wea(0) <= bulkout_dvalid when (bram_selected = '1') else '0';

--	bram_wea_o    <= bram_wea;
--	bram_addr_o   <= bram_addr;
--	bram_wrdata_o <= bram_wrdata;
--	bram_rddata <= bram_rddata_i;

---- ********* ここまでBRAMの回路 (target 0x01) ********** --

---- ********* ここからAXIのインタフェース (target 0x00) ********** --
--	axiclk <= m_axi_aclk;
--	axireset <= not m_axi_aresetn;

--	process(clk100m) begin
--		if(clk100m'event and clk100m='1') then
--			if(bulkout_start = '1') and (axi_selected = '1') then
--				dram_rwaddr <= uif_addr(31 downto 0);
----				dram_rwlen  <= "0" & uif_length(uif_length'left downto 1);
--			elsif(bulkin_start = '1') and (axi_selected = '1') then
--				dram_rwaddr <= uif_addr(31 downto 0);
----				dram_rwlen  <= "0" & uif_datalen(uif_length'left downto 1);
--			end if;

--            dram_wack_d <= dram_wack or dram_wackd;     
--			dram_wack_dd <= dram_wack_d;
--			if(bulkout_start = '1') and (axi_selected = '1') then
--				dram_wreq  <= '1';
--			elsif(dram_wack_dd = '1') then
--				dram_wreq  <= '0';
--			end if;

--			dram_rack_d <= dram_rack or dram_rackd;
--			dram_rack_dd <= dram_rack_d;
--			if(bulkin_start = '1') and (axi_selected = '1') then
--				dram_rreq  <= '1';
--			elsif(dram_rack_dd = '1') then
--				dram_rreq  <= '0';
--			end if;
--		end if;
--	end process;
----	u2dfifo_rst  <= blogana_user(16);
--	u2dfifo_rst <= '0';

----	inst_u2dfifov : u2dfifov port map (
----		rst        => u2dfifo_rst,
----		wr_clk     => clk100m,
----		rd_clk     => axiclk,
----		din        => u2dfifo_din,
----		wr_en      => u2dfifo_wr_d,
----		rd_en      => u2dfifo_rd,
----		dout       => u2dfifo_dout,
----		full       => open,
----		empty      => u2dfifo_empty,
----		prog_empty => open,
----		prog_full  => u2dfifo_full
----	);
--	u2dfifo_rd <= '1' when (m_axi_wready = '1') and (m_axi_wvalid = '1') else '0';
--	process(clk100m) begin
--		if(clk100m'event and clk100m='1') then
--			if(bulkout_dvalid = '1') and (axi_selected = '1') then
--				u2dfifo_wr <= '1';
--			else
--				u2dfifo_wr <= '0';
--			end if;

--			if(u2dfifo_rst = '1') then
--				u2dfifo_wr_trig <= '0';
--				u2dfifo_wr_d <= '0';
--			elsif(bulkout_dvalid = '1') and (axi_selected = '1') then
--				u2dfifo_wr_trig <= not u2dfifo_wr_trig;
--				u2dfifo_wr_d <= u2dfifo_wr_trig;
--				u2dfifo_din(31 downto 0) <= u2dfifo_din(63 downto 32);
--				u2dfifo_din(63 downto 32) <= bulkout_data;
--			else
--				u2dfifo_wr_d <= '0';
--			end if;
--		end if;
--	end process;
			
--	m_axi_wdata <= u2dfifo_dout;

--	d2ufifo_rst  <= bulkin_start;--'1' when (rd_state = "000") else '0';
--	d2ufifo_wr   <= '1' when (m_axi_rready = '1') and (m_axi_rvalid = '1') and (rd_state(2 downto 1) = "10") else '0';
--	d2ufifo_din  <= m_axi_rdata;

----	inst_d2ufifov : d2ufifov port map (
----		rst        => d2ufifo_rst,
----		wr_clk     => axiclk,
----		rd_clk     => clk100m,
----		din        => d2ufifo_din,
----		wr_en      => d2ufifo_wr,
----		rd_en      => d2ufifo_rd and (not d2ufifo_rd_trig),
----		dout       => d2ufifo_dout,
----		full       => open,
----		empty      => d2ufifo_empty,
----		prog_empty => open,
----		prog_full  => d2ufifo_full
----	);
--	d2ufifo_rd <= '0' when (bulkin_dreq = '0') else
--	              '1' when (d2ufifo_rd_trig = '1') else
--				  (not d2ufifo_empty) and axi_selected;

--	process(clk100m) begin
--		if(clk100m'event and clk100m='1') then
--			if(u2dfifo_rst = '1') then
--				d2ufifo_rd_trig <= '0';
--			elsif(d2ufifo_rd= '1') then
--				d2ufifo_rd_trig <= not d2ufifo_rd_trig;
--			end if;
--			axi_rd_valid <= d2ufifo_rd;
--		end if;
--	end process;
--	axi_rd_data  <= d2ufifo_dout(31 downto 0) when (d2ufifo_rd_trig = '1') else
--	                d2ufifo_dout(63 downto 32);

	process(axiclk) begin
		if(axiclk'event and axiclk = '1') then
		
			if(m_axi_awready = '1') and (m_axi_awvalid = '1') then
				m_axi_bvalid_detect <= '0';
			elsif(m_axi_bvalid = '1') then
				m_axi_bvalid_detect <= '1';
			end if;

			if((m_axi_awready = '1') and (m_axi_awvalid = '1')) or (axireset = '1') then
				bvtimer <= (others => '0');
			elsif(wr_state = "101") and (bvtimer /= "11111111") then
				bvtimer <= bvtimer + 1;
			end if;
			
			dram_wreq_d <= dram_wreq;
			dram_wackd <= dram_wack;

			if(axireset = '1') then
				m_axi_wvalid <= '0';
				m_axi_awvalid <= '0';
				m_axi_awid <= (others => '0');
				wr_state <= "000";
				dram_wack <= '0';
			else
--				if(axis_wren(16) = '1') then
--					m_axi_awaddr <= (others => '0');--axis_wdata;
--				end if;
				m_axi_awsize <= "011"; -- 64bit?
				m_axi_awburst <= "01"; -- increment
				m_axi_awcache <= "0011"; -- Normal Non-cacheable Bufferable
				m_axi_awprot  <= "000";

				case wr_state is
					when "000" =>
						m_axi_awaddr <= dram_rwaddr;--(others => '0');--axis_wdata;
						m_axi_wvalid <= '0';
						m_axi_awvalid <= '0';
						m_axi_wstrb <= "00000000";
						m_axi_wlast <= '0';
						m_axi_bready <= '1';
						if(dram_wreq_d = '1') then
--						if(timer_trig_wr = '1') then
--						if(blogana_user(16) = '1') then
--							wr_remain  <= x"0000" & blogana_user(15 downto 0);--x"02000000";
							wr_remain  <= dram_rwlen;--x"02000000";
							wr_state <= "001";
							dram_wack <= '1';
						else
							dram_wack <= '0';
						end if;
					
					when "001" =>
--						dram_wack <= '0';
						if(wr_remain = 0) then
							wr_state <= "110";
						else
--						if( = '1') then DMAターゲットの準備ができていたら・・
							wr_state <= "010";
--						end if;
						end if;

					when "010" => -- ADDR発行
						dram_wack <= '0';
						m_axi_awvalid <= '1';
						if(wr_remain >= 64) then
							m_axi_awlen <= conv_std_logic_vector(64 - 1,8);
						else
							m_axi_awlen <= wr_remain(7 downto 0) - 1;
						end if;
						wr_state <= "011";

					when "011" => -- ADDR確認
						if(m_axi_awready = '1') then -- ADDR受け入れ可能
							m_axi_awid <= m_axi_awid + 1;
							m_axi_awvalid <= '0';
							if(wr_remain >= 64) then
								wr_remain <= wr_remain - 64;
							else
								wr_remain <= (others => '0');
							end if;
							wr_state <= "100";
						end if;
						if(m_axi_awlen = 0) then
							m_axi_wlast <= '1';
						end if;

					when "100" => -- DATA送信
						m_axi_wstrb <= "11111111";
						if(m_axi_wready = '1') and (u2dfifo_empty = '0') then
							if(m_axi_wvalid = '1') then -- 書き込み成功
								m_axi_awaddr <= m_axi_awaddr + 8;
								m_axi_awlen <= m_axi_awlen - 1;
								if(m_axi_awlen = 1) then -- 次はラスト
									m_axi_wlast <= '1';
								end if;
								if(m_axi_awlen = 0) then -- 次はない
									m_axi_wlast <= '0';
									m_axi_wvalid <= '0';
									wr_state <= "101";
								else
									m_axi_wvalid <= '0';
								end if;
							else
								m_axi_wvalid <= '1';
							end if;
						else
							m_axi_wvalid <= '0';
						end if;

					when "101" =>
						if(m_axi_bvalid_detect = '1') then
							wr_state <= "001";
						end if;
						m_axi_wvalid <= '0';
						m_axi_wstrb <= "00000000";
						m_axi_wlast <= '0';

					when others =>
						dram_wack <= '0';
--						if(blogana_user(16) = '0') then
							wr_state <= "000";
--						end if;
						m_axi_wvalid <= '0';
						m_axi_wstrb <= "00000000";
						m_axi_wlast <= '0';
				end case;
			end if;
		end if;
	end process;

	process(axiclk) begin
		if(axiclk'event and axiclk = '1') then
		
			dram_rreq_d <= dram_rreq;
            dram_rackd <= dram_rack;
		
			if(axireset = '1') then
				m_axi_rready <= '0';
				m_axi_arvalid <= '0';
				m_axi_araddr <= (others => '0');--axis_wdata;
				rd_state <= "000";
				dram_rack <= '0';
			else
--				if(axis_wren(16) = '1') then
--					m_axi_awaddr <= (others => '0');--axis_wdata;
--				end if;
				m_axi_arsize <= "011"; -- 64bit?
				m_axi_arburst <= "01"; -- increment
				m_axi_arcache <= "0011"; -- Normal Non-cacheable Bufferable
				m_axi_arprot  <= "000";

				case rd_state is
					when "000" =>
						m_axi_araddr <= dram_rwaddr;--axis_wdata;
						m_axi_rready <= '0';
						m_axi_arvalid <= '0';
						if(dram_rreq_d = '1') then
--						if(timer_trig_rd = '1') then
--						if(blogana_user(17) = '1') then
--							rd_remain  <= x"02000000";
--							rd_remain  <= x"0000" & blogana_user(15 downto 0);--x"02000000";
							rd_state <= "001";
							rd_remain  <= dram_rwlen;--x"02000000";
							dram_rack <= '1';
						else
							dram_rack <= '0';
						end if;
					
					when "001" =>
						if(rd_remain = 0) then
							rd_state <= "110";
						elsif(d2ufifo_full = '0') then
							rd_state <= "010";
						end if;

					when "010" => -- ADDR発行
						dram_rack <= '0';
						m_axi_arvalid <= '1';
						if(rd_remain >= 64) then
							m_axi_arlen <= conv_std_logic_vector(64 - 1,8);
						else
							m_axi_arlen <= rd_remain(7 downto 0) - 1;
						end if;
						rd_state <= "011";

					when "011" => -- ADDR確認
						if(m_axi_arready = '1') then -- ADDR受け入れ可能
							m_axi_arvalid <= '0';
							if(rd_remain >= 64) then
								rd_remain <= rd_remain - 64;
							else
								rd_remain <= (others => '0');
							end if;
							m_axi_rready <= '1';
							rd_state <= "100";
						end if;

					when "100" => -- DATA受信
						m_axi_arvalid <= '0';
						if(m_axi_rvalid = '1') and (m_axi_rready = '1') then
							m_axi_araddr <= m_axi_araddr + 8;
							m_axi_arlen <= m_axi_arlen - 1;
							if(m_axi_arlen = 0) then
								m_axi_rready <= '0';
								rd_state <= "101";
							end if;
						end if;

					when "101" =>
						rd_state <= "001";
						m_axi_rready <= '0';

					when others =>
						dram_rack <= '0';
--						if(blogana_user(17) = '0') then
							rd_state <= "000";
--						end if;
						m_axi_rready <= '0';
				end case;
			end if;
		end if;
	end process;
--	axim_WVALID_i <= '1' when (axim_state = "10") and (axim_WREADY_o = '1') else '0';

	m_axi_awid_o    	<= m_axi_awid;
	m_axi_awaddr_o    	<= m_axi_awaddr;
	m_axi_awlen_o     	<= m_axi_awlen;
	m_axi_awsize_o    	<= m_axi_awsize;
	m_axi_awburst_o   	<= m_axi_awburst;
	m_axi_awlock_o    	<= (others => '0');
	m_axi_awcache_o   	<= m_axi_awcache;
	m_axi_awprot_o    	<= m_axi_awprot;
	m_axi_awqos_o     	<= (others => '0');
	m_axi_awvalid_o   	<= m_axi_awvalid;
	m_axi_awready     	<= m_axi_awready_i;
	m_axi_wdata_o     	<= m_axi_wdata;
	m_axi_wstrb_o     	<= m_axi_wstrb;
	m_axi_wlast_o     	<= m_axi_wlast;
	m_axi_wvalid_o    	<= m_axi_wvalid;
	m_axi_wready      	<= m_axi_wready_i;
	m_axi_bready_o    	<= m_axi_bready;
--	m_axi_bid         	<= m_axi_bid_i;
	m_axi_bresp       	<= m_axi_bresp_i;
	m_axi_bvalid      	<= m_axi_bvalid_i;
--	m_axi_arid_o      	<= m_axi_arid;
	m_axi_arid_o      	<= (others => '0');
	m_axi_araddr_o    	<= m_axi_araddr;
	m_axi_arlen_o     	<= m_axi_arlen;
	m_axi_arsize_o    	<= m_axi_arsize;
	m_axi_arburst_o   	<= m_axi_arburst;
	m_axi_arlock_o    	<= (others => '0');
	m_axi_arcache_o   	<= m_axi_arcache;
	m_axi_arprot_o    	<= m_axi_arprot;
	m_axi_arqos_o     	<= (others => '0');
	m_axi_arvalid_o   	<= m_axi_arvalid;
	m_axi_arready     	<= m_axi_arready_i;
	m_axi_rready_o      <= m_axi_rready;
--	m_axi_rid           <= m_axi_rid_i;
	m_axi_rdata         <= m_axi_rdata_i;
	m_axi_rresp         <= m_axi_rresp_i;
	m_axi_rlast         <= m_axi_rlast_i;
	m_axi_rvalid        <= m_axi_rvalid_i;

	if_inst_blogana : if USE_BLOGANA generate
		inst_blogana2 :  blogana2 generic map
		(
			BIT_WIDTH     => 144,
			SAMPLE_LENGTH => 2048
		)
		port map
		(
			clk => axiclk,
			trig => blogana_trig,
			din  => blogana_din,
			USER_OP   => blogana_user,
			SAMPLE_EN => '1',--spi_debug(15),
			samp_freq => 100000000,
			busy => blogana_busy
		);
	end generate;

	blogana_trig <= '1' when (blogana_user(19) = '0') and (rd_state = "001") else
					'0';
	
	BLOGANA_DIN(31 downto 0)  <= m_axi_araddr;
	BLOGANA_DIN(63 downto 32) <= m_axi_rdata(31 downto 0);
	BLOGANA_DIN(71 downto 64) <= m_axi_arlen; 
	BLOGANA_DIN(72) <= m_axi_arvalid; 
	BLOGANA_DIN(73) <= m_axi_arready; 
	BLOGANA_DIN(74) <= m_axi_rready; 
	BLOGANA_DIN(75) <= m_axi_rvalid; 
	BLOGANA_DIN(76) <= m_axi_rlast; 
	
	BLOGANA_DIN(83 downto 81) <= rd_state; 
	BLOGANA_DIN(115 downto 84) <= rd_remain; 
	BLOGANA_DIN(117) <= dram_rreq_d; 
	BLOGANA_DIN(118) <= dram_rack; 
	BLOGANA_DIN(119) <= axireset; 	
	
--	--rd_error when (blogana_user(16) = '1') else
--					'1' when (blogana_user(19) = '1') and (wr_state = "001") else
--	                '1' when (blogana_user(19) = '0') and (rd_state = "001") else
--					--'1' when (bvtimer = "11111111") and (wr_state = "101") else 
--					'0';

--	BLOGANA_DIN(7 downto 0) <= wr_remain(7 downto 0) when (blogana_user(19) = '1') else rd_remain(7 downto 0);
--	BLOGANA_DIN(10 downto 8) <= wr_state when (blogana_user(19) = '1') else rd_state;
--	BLOGANA_DIN(11) <= m_axi_awvalid when (blogana_user(19) = '1') else m_axi_arvalid;
--	BLOGANA_DIN(12) <= m_axi_awready when (blogana_user(19) = '1') else m_axi_arready;
--	BLOGANA_DIN(16 downto 13) <= m_axi_awid;--m_axi_wstrb(3 downto 0);
--	BLOGANA_DIN(17) <= m_axi_wlast when (blogana_user(19) = '1') else m_axi_rlast;
--	BLOGANA_DIN(18) <= m_axi_wvalid when (blogana_user(19) = '1') else m_axi_rvalid;
--	BLOGANA_DIN(19) <= m_axi_wready when (blogana_user(19) = '1') else m_axi_rready;
--	BLOGANA_DIN(21 downto 20) <= m_axi_bresp(1 downto 0) when (blogana_user(19) = '1') else m_axi_rresp(1 downto 0);
--	BLOGANA_DIN(22) <= m_axi_bvalid;
--	BLOGANA_DIN(23) <= d2ufifo_full;
--	BLOGANA_DIN(31 downto 24) <= m_axi_awlen(7 downto 0) when (blogana_user(19) = '1') else m_axi_arlen(7 downto 0);
----	BLOGANA_DIN(63 downto 32) <= bulkout_data;
--	BLOGANA_DIN(47 downto 32) <= bulkin_data(15 downto 0);-- m_axi_wdata(15 downto 0) when (blogana_user(19) = '1') else m_axi_rdata(15 downto 0);
--	BLOGANA_DIN(63 downto 48) <= bulkin_data(31 downto 16);--m_axi_wdata(31 downto 16) when (blogana_user(19) = '1') else m_axi_rdata(31 downto 0);
----	BLOGANA_DIN(71 downto 64) <= m_axi_awaddr(7 downto 0) when (blogana_user(19) = '1') else m_axi_araddr(7 downto 0);

--	BLOGANA_DIN(31 downto 0)  <= m_axi_wdata(31 downto 0)  when (blogana_user(19) = '1') else 
--	                             u2dfifo_din(31 downto 0)  when (blogana_user(18) = '1') else 
--								 bulkout_data;
--	BLOGANA_DIN(63 downto 32) <= m_axi_wdata(63 downto 32) when (blogana_user(19) = '1') else
--	                             u2dfifo_din(63 downto 32)  when (blogana_user(18) = '1') else 
--								 bulkout_data;

--	BLOGANA_DIN(64) <= bulkin_dvalid;
--	BLOGANA_DIN(65) <= bulkin_busy;
--	BLOGANA_DIN(66) <= axi_selected;
--	BLOGANA_DIN(67) <= d2ufifo_empty;
--	BLOGANA_DIN(68) <= bulkin_dreq;
--	BLOGANA_DIN(69) <= axi_rd_valid;
--	BLOGANA_DIN(70) <= d2ufifo_rd;
--	BLOGANA_DIN(71) <= d2ufifo_rd_trig;
--	BLOGANA_DIN(64) <= bulkout_dvalid;
--	BLOGANA_DIN(65) <= bulkout_end;
--	BLOGANA_DIN(66) <= bulkout_start;
--	BLOGANA_DIN(67) <= u2dfifo_rd;
--	BLOGANA_DIN(68) <= u2dfifo_empty;
--	BLOGANA_DIN(69) <= u2dfifo_wr_d;
--	BLOGANA_DIN(70) <= u2dfifo_wr;
--	BLOGANA_DIN(71) <= u2dfifo_wr_trig;

	debug_op(7 downto 0) <= dram_rack & m_axi_rvalid & m_axi_rready & m_axi_arvalid & m_axi_arready & rd_state;

end Behavioral;
