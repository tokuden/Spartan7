--------------------------------------------------------------------------------
--     BlockRAM Logic Analyzer Version 1.5 (fot Artix-7)
--     (C) Copyright 2005 Nahitech Inc. All rights reserved.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity blogana is
    Port (	CLK         : in std_logic;
			TRIG        : in std_logic;
			USER_OP     : out std_logic_vector(19 downto 0);
			SAMPLE_EN   : in std_logic;
			DIN         : in std_logic_vector(71 downto 0); -- 必ず72本
			SAMP_FREQ   : in integer range 0 to 2147483647; -- サンプリング周波数
			WIDTH72     : in std_logic;                     -- 1:72ビット 0:36ビット
			LENGTH1024  : in std_logic;                     -- 1:1024ワード 0:512ワード
			BUSY        : out std_logic                     -- 必ずどこかに出力すること
	);
end blogana;

architecture Behavioral of blogana is

	signal BSREG    : std_logic_vector(35 downto 0);
	signal CAPTURE  : std_logic;
	signal DRCK     : std_logic;
	signal DRCKR    : std_logic;
	signal SEL      : std_logic;
	signal SHIFT    : std_logic;
	signal TDI      : std_logic;
	signal TDO      : std_logic;
	signal UPDATE   : std_logic;
	signal UPDATED  : std_logic;
	signal UPDATED2 : std_logic;

	signal MES_MODE : std_logic_vector(1 downto 0);
	signal WEA      : std_logic;

	signal RMODE    : std_logic_vector(1 downto 0);
	-- 00 ステータス
	-- 01 周波数
	-- 10 データ

	signal COMMAND       : std_logic_vector(31 downto 0);
	signal STATUS_WORD   : std_logic_vector(31 downto 0);
	signal DATA_WORD     : std_logic_vector(35 downto 0);
	signal DIO_36B       : std_logic_vector(71 downto 0);
	signal DIO_18B       : std_logic_vector(71 downto 0);
	signal WADDR         : std_logic_vector(10 downto 0); -- MAX=2047
	signal RADDR         : std_logic_vector(10 downto 0); -- MAX=2047
	signal COUNT         : std_logic_vector(11 downto 0); -- MAX=2048
	signal DATA_LENGTH   : std_logic_vector(11 downto 0); -- MAX=2048
	signal DATA_WIDTH    : integer range 0 to 127;
	signal BLOGANA_MODE  : std_logic_vector(1 downto 0);

	signal TRIG_MODE  : std_logic_vector(1 downto 0);
	signal ADDR_A     : std_logic_vector(10 downto 0);
	signal ADDR_B     : std_logic_vector(10 downto 0);
	signal DATA_A     : std_logic_vector(71 downto 0);
	signal nRESET     : std_logic;

	component RAMB16_S36_S36
	  generic (
       WRITE_MODE_A : string := "WRITE_FIRST";
       WRITE_MODE_B : string := "WRITE_FIRST";
       INIT_A : bit_vector  := X"000000000";
       SRVAL_A : bit_vector  := X"000000000";

       INIT_B : bit_vector  := X"000000000";
       SRVAL_B : bit_vector  := X"000000000";

       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );
	  port (DIA    : in STD_LOGIC_VECTOR (31 downto 0);
        DIB    : in STD_LOGIC_VECTOR (31 downto 0);
        DIPA    : in STD_LOGIC_VECTOR (3 downto 0);
        DIPB    : in STD_LOGIC_VECTOR (3 downto 0);
        ENA    : in STD_logic;
        ENB    : in STD_logic;
        WEA    : in STD_logic;
        WEB    : in STD_logic;
        SSRA   : in STD_logic;
        SSRB   : in STD_logic;
        CLKA   : in STD_logic;
        CLKB   : in STD_logic;
        ADDRA  : in STD_LOGIC_VECTOR (8 downto 0);
        ADDRB  : in STD_LOGIC_VECTOR (8 downto 0);
        DOA    : out STD_LOGIC_VECTOR (31 downto 0);
        DOB    : out STD_LOGIC_VECTOR (31 downto 0);
        DOPA    : out STD_LOGIC_VECTOR (3 downto 0);
        DOPB    : out STD_LOGIC_VECTOR (3 downto 0)); 
	end component;

	component RAMB16_S18_S18
	--
	  generic (
	       WRITE_MODE_A : string := "WRITE_FIRST";
	       WRITE_MODE_B : string := "WRITE_FIRST";
	       INIT_A : bit_vector  := X"00000";
	       SRVAL_A : bit_vector := X"00000";

	       INIT_B : bit_vector  := X"00000";
	       SRVAL_B : bit_vector := X"00000";

	       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );
	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIPA    : in STD_LOGIC_VECTOR (1 downto 0);
	        DIPB    : in STD_LOGIC_VECTOR (1 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        SSRA   : in STD_logic;
	        SSRB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (9 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (9 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOPA    : out STD_LOGIC_VECTOR (1 downto 0);
	        DOPB    : out STD_LOGIC_VECTOR (1 downto 0)); 
	end component;

begin

------------------------------------------------------------------------------------------
-- BSCANマクロの使用
------------------------------------------------------------------------------------------

   BSCANE2_inst : BSCANE2
   generic map (
      JTAG_CHAIN => 1  -- Value for USER command.
   )
   port map (
      CAPTURE => CAPTURE, -- 1-bit output: CAPTURE output from TAP controller.
      DRCK => DRCKR,      -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
                          -- SHIFT are asserted.

      RESET => open,     -- 1-bit output: Reset output for TAP controller.
      RUNTEST => open, -- 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
      SEL => SEL,         -- 1-bit output: USER instruction active output.
      SHIFT => SHIFT,     -- 1-bit output: SHIFT output from TAP controller.
      TCK => open,         -- 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
      TDI => TDI,         -- 1-bit output: Test Data Input (TDI) output from TAP controller.
      TMS => open,         -- 1-bit output: Test Mode Select output. Fabric connection to TAP.
      UPDATE => UPDATE,   -- 1-bit output: UPDATE output from TAP controller
      TDO => TDO          -- 1-bit input: Test Data Output (TDO) input for USER function.
   );
   
   inst_bufr : bufr port map (
		clr => '0',
		ce => '1',
		i => DRCKR,
		o => DRCK
	);

	process(DRCK) begin
		if(DRCK'event and DRCK = '1') then
			if(SEL = '1') then
				if(CAPTURE = '1') then
					case RMODE is
						when "00" =>
							BSREG <= "1100" & STATUS_WORD;
							if(WIDTH72 = '1') then
								RADDR <= WADDR(9 downto 0) & "0";
							else
								RADDR <= WADDR;
							end if;
						when "01" =>
							BSREG <= "1101" & conv_std_logic_vector(SAMP_FREQ,32);
						when "10" =>
							BSREG <= DATA_WORD;
							RADDR <= RADDR + 1;
						when others =>
							BSREG <= (others => '1');
					end case;
				else
					BSREG <= TDI & BSREG(35 downto 1);
				end if;
			end if;
		end if;
	end process;

	process(CLK) begin
		if(CLK'event and CLK = '1') then
			UPDATED  <= UPDATE and SEL;
			UPDATED2 <= UPDATED;

			if((UPDATED2 = '0') and (UPDATED = '1')) then
				COMMAND <= BSREG(31 downto 0);
			end if;
		end if;
	end process;
	TDO <= BSREG(0);
	BUSY <= '1' when(MES_MODE /= "00") else '0';

------------------------------------------------------------------------------------------
-- BLOGANA制御回路
------------------------------------------------------------------------------------------

	DATA_LENGTH   <= CONV_STD_LOGIC_VECTOR(512,12) when(LENGTH1024 = '0') else CONV_STD_LOGIC_VECTOR(1024,12);

	DATA_WIDTH    <= 72 when (WIDTH72 = '1') else 36;

	STATUS_WORD(31 downto 30) <= MES_MODE;
	STATUS_WORD(29 downto 22) <= "0" & conv_std_logic_vector(DATA_WIDTH,7);
	STATUS_WORD(21 downto 16) <= "0" & DATA_LENGTH(11 downto 7); -- ÷128
	STATUS_WORD(15 downto 0)  <= "00000" & WADDR;

	RMODE <= COMMAND(31 downto 30);
	TRIG_MODE <= COMMAND(3 downto 2);
	nRESET <= '1';--COMMAND(4);
	USER_OP <= COMMAND(27 downto 8);

	process(CLK) begin
		if(CLK'event and CLK = '1') then
			if(MES_MODE = "01") then
				case TRIG_MODE is
					when "00" => -- 6%
						COUNT <= "0000" & DATA_LENGTH(11 downto 4); -- ÷16
					when "01"  => -- 25%
						COUNT <= "00" & DATA_LENGTH(11 downto 2); -- ÷4
					when "10"  => -- 50%
						COUNT <= "0" & DATA_LENGTH(11 downto 1); -- ÷2
					when others  => -- 100%
						COUNT <= DATA_LENGTH - ("0000" & DATA_LENGTH(11 downto 4)); -- ÷16×15
				end case;
			else
				if(SAMPLE_EN = '1') then
					COUNT <= COUNT + 1;
				end if;
			end if;
		end if;
	end process;

	process(CLK) begin
		if(CLK'event and CLK = '1') then
			case MES_MODE is
				when "00" => -- IDLE STATE
					WADDR <= WADDR + 1;
					if(COMMAND(0) = '1') then -- start !
						MES_MODE <= "01";
					end if;

				when "01" => -- Wait Trigger
					if(SAMPLE_EN = '1') then
						WADDR <= WADDR + 1;
					end if;
					if((TRIG = '1') or (COMMAND(1) = '1')) then
						MES_MODE <= "11";
					end if;
	
				when "11" => -- Run
					if(SAMPLE_EN = '1') then
						WADDR <= WADDR + 1;
					end if;
					if(COUNT = DATA_LENGTH - 2) then
						MES_MODE <= "10";
					end if;
	
				when others =>
					if(COMMAND(0) = '0') then -- end
						MES_MODE <= "00";
					end if;
			end case;
		end if;
	end process;

	WEA <= '1' when ((MES_MODE = "01") or (MES_MODE = "11") or (MES_MODE = "00")) else '0';

------------------------------------------------------------------------------------------
-- メモリ
------------------------------------------------------------------------------------------

	-- 36ビット 512バイト
--	DATA_A(35 downto  0) <= DIN(35 downto  0);
--	DATA_A(71 downto 36) <= (others => '0');--DIN(71 downto 36);
--	ADDR_A    <= "00" & WADDR(8 downto 0);
--	ADDR_B    <= "00" & RADDR(8 downto 0);
--	DATA_WORD <= DIO_36B(35 downto 0);

	-- 72ビット 512バイト
--	DATA_A(35 downto  0) <= DIN(35 downto  0);
--	DATA_A(71 downto 36) <= DIN(71 downto 36);
--	ADDR_A    <= "00" & WADDR(8 downto 0);
--	ADDR_B    <= "00" & RADDR(9 downto 1);
--	DATA_WORD <= DIO_36B(35 downto 0) when(RADDR(0) = '0') else DIO_36B(71 downto 36);

	-- 36ビット 1024バイト
--	DATA_A(35 downto  0) <= DIN(35 downto  0);
--	DATA_A(71 downto 36) <= (others => '0');--DIN(71 downto 36);
--	ADDR_A    <= "0" & WADDR(9 downto 0);
--	ADDR_B    <= "0" & RADDR(9 downto 0);
--	DATA_WORD <= DIO_18B(35 downto 0);

	-- 72ビット 1024バイト
--	DATA_A(35 downto  0) <= DIN(35 downto  0);
--	DATA_A(71 downto 36) <= DIN(71 downto 36);
--	ADDR_A    <= "0" & WADDR(9 downto 0);
--	ADDR_B    <= "0" & RADDR(10 downto 1);
--	DATA_WORD <= DIO_18B(35 downto 0) when(RADDR(0) = '0') else DIO_18B(71 downto 36);

	BLOGANA_MODE <= LENGTH1024 & WIDTH72;

	process (BLOGANA_MODE,DIN,DIO_18B,DIO_36B,WADDR(8 downto 0),RADDR(8 downto 0)) begin
		case BLOGANA_MODE is
			when "00" =>
				-- 36ビット 512バイト
				DATA_A(35 downto  0) <= DIN(35 downto  0);
				DATA_A(71 downto 36) <= (others => '0');--DIN(71 downto 36);
				ADDR_A    <= "00" & WADDR(8 downto 0);
				ADDR_B    <= "00" & RADDR(8 downto 0);
				DATA_WORD <= DIO_36B(35 downto 0);

			when "01" =>
				-- 72ビット 512バイト
				DATA_A(35 downto  0) <= DIN(35 downto  0);
				DATA_A(71 downto 36) <= DIN(71 downto 36);
				ADDR_A    <= "00" & WADDR(8 downto 0);
				ADDR_B    <= "00" & RADDR(9 downto 1);
				if(RADDR(0) = '0') then
					DATA_WORD <= DIO_36B(35 downto 0);
				else
					DATA_WORD <= DIO_36B(71 downto 36);
				end if;

			when "10" =>
				-- 36ビット 1024バイト
				DATA_A(35 downto  0) <= DIN(35 downto  0);
				DATA_A(71 downto 36) <= (others => '0');--DIN(71 downto 36);
				ADDR_A    <= "0" & WADDR(9 downto 0);
				ADDR_B    <= "0" & RADDR(9 downto 0);
				DATA_WORD <= DIO_18B(35 downto 0);

			when others =>
				-- 72ビット 1024バイト
				DATA_A(35 downto  0) <= DIN(35 downto  0);
				DATA_A(71 downto 36) <= DIN(71 downto 36);
				ADDR_A    <= "0" & WADDR(9 downto 0);
				ADDR_B    <= "0" & RADDR(10 downto 1);
				if(RADDR(0) = '0') then
					DATA_WORD <= DIO_18B(35 downto 0);
				else
					DATA_WORD <= DIO_18B(71 downto 36);
				end if;
		end case;
	end process;

	BRAM_36B1 : RAMB16_S36_S36 port map (
		DIA   => DATA_A(31 downto 0),
		DIPA  => DATA_A(35 downto 32),
		ENA   => nRESET,
		WEA   => WEA,
		SSRA  => '0',
		CLKA  => CLK,
		ADDRA => ADDR_A(8 downto 0),
		DOA   => open,
		DOPA  => open,
	
		DIB   => (others => '0'),
		DIPB  => (others => '0'),
		ENB   => nRESET,
		WEB   => '0',
		SSRB  => '0',
		CLKB  => DRCK,
		ADDRB => ADDR_B(8 downto 0),
		DOB   => DIO_36B(31 downto 0),
		DOPB  => DIO_36B(35 downto 32)
	);
	BRAM_36B2 : RAMB16_S36_S36 port map (
		DIA   => DATA_A(67 downto 36),
		DIPA  => DATA_A(71 downto 68),
		ENA   => nRESET,
		WEA   => WEA,
		SSRA  => '0',
		CLKA  => CLK,
		ADDRA => ADDR_A(8 downto 0),
		DOA   => open,
		DOPA  => open,
	
		DIB   => (others => '0'),
		DIPB  => (others => '0'),
		ENB   => nRESET,
		WEB   => '0',
		SSRB  => '0',
		CLKB  => DRCK,
		ADDRB => ADDR_B(8 downto 0),
		DOB   => DIO_36B(67 downto 36),
		DOPB  => DIO_36B(71 downto 68)
	);

	BRAM_18B1 : RAMB16_S18_S18 port map (
		DIA   => DATA_A(15 downto 0),
		DIPA  => DATA_A(17 downto 16),
		ENA   => nRESET,
		WEA   => WEA,
		SSRA  => '0',
		CLKA  => CLK,
		ADDRA => ADDR_A(9 downto 0),
		DOA   => open,
		DOPA  => open,
	
		DIB   => (others => '0'),
		DIPB  => (others => '0'),
		ENB   => nRESET,
		WEB   => '0',
		SSRB  => '0',
		CLKB  => DRCK,
		ADDRB => ADDR_B(9 downto 0),
		DOB   => DIO_18B(15 downto 0),
		DOPB  => DIO_18B(17 downto 16)
	);
	BRAM_18B2 : RAMB16_S18_S18 port map (
		DIA   => DATA_A(33 downto 18),
		DIPA  => DATA_A(35 downto 34),
		ENA   => nRESET,
		WEA   => WEA,
		SSRA  => '0',
		CLKA  => CLK,
		ADDRA => ADDR_A(9 downto 0),
		DOA   => open,
		DOPA  => open,
	
		DIB   => (others => '0'),
		DIPB  => (others => '0'),
		ENB   => nRESET,
		WEB   => '0',
		SSRB  => '0',
		CLKB  => DRCK,
		ADDRB => ADDR_B(9 downto 0),
		DOB   => DIO_18B(33 downto 18),
		DOPB  => DIO_18B(35 downto 34)
	);
	BRAM_18B3 : RAMB16_S18_S18 port map (
		DIA   => DATA_A(51 downto 36),
		DIPA  => DATA_A(53 downto 52),
		ENA   => nRESET,
		WEA   => WEA,
		SSRA  => '0',
		CLKA  => CLK,
		ADDRA => ADDR_A(9 downto 0),
		DOA   => open,
		DOPA  => open,
	
		DIB   => (others => '0'),
		DIPB  => (others => '0'),
		ENB   => nRESET,
		WEB   => '0',
		SSRB  => '0',
		CLKB  => DRCK,
		ADDRB => ADDR_B(9 downto 0),
		DOB   => DIO_18B(51 downto 36),
		DOPB  => DIO_18B(53 downto 52)
	);
	BRAM_18B4 : RAMB16_S18_S18 port map (
		DIA   => DATA_A(69 downto 54),
		DIPA  => DATA_A(71 downto 70),
		ENA   => nRESET,
		WEA   => WEA,
		SSRA  => '0',
		CLKA  => CLK,
		ADDRA => ADDR_A(9 downto 0),
		DOA   => open,
		DOPA  => open,
	
		DIB   => (others => '0'),
		DIPB  => (others => '0'),
		ENB   => nRESET,
		WEB   => '0',
		SSRB  => '0',
		CLKB  => DRCK,
		ADDRB => ADDR_B(9 downto 0),
		DOB   => DIO_18B(69 downto 54),
		DOPB  => DIO_18B(71 downto 70)
	);

end Behavioral;
