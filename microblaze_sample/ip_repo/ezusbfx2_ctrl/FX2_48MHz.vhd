library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity FX2_48MHz is
	Port (	CLK         : in std_logic;
			RESET       : in std_logic; -- “¯ŠúƒŠƒZƒbƒg
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
end FX2_48MHz;

architecture Behavioral of FX2_48MHz is
	signal SLWR_reg    : std_logic;
	signal SLWR_node   : std_logic;
	signal SLRD_reg    : std_logic;
	signal SLRD_node   : std_logic;
	signal IFCLK_node  : std_logic;
	signal PKTEND_reg  : std_logic;
--	signal FLAGR_D     : std_logic;
	signal USTATE      : std_logic_vector(2 downto 0);
	signal TRANSMITTED_node : std_logic;
	signal RDATA_URA   : std_logic_vector(15 downto 0);

	component my_odelay is
		Generic ( Delay : integer := 0 );
		Port ( I : in  STD_LOGIC;
			   O : out  STD_LOGIC
		);
	end component;

	signal tmpclk : std_logic;
	
	signal CAL : std_logic;
	signal CALCNT : std_logic_vector(2 downto 0);

begin

	IFCLK_node <= not CLK;
--	IFCLK      <= IFCLK_node;

	process(CLK) begin
		if(CLK'event and CLK='1') then
			if(CALCNT /= "111") then
				CALCNT <= CALCNT + 1;
			end if;
			if(CALCNT < 4) then
				CAL <= '1';
			else
				CAL <= '0';
			end if;
		end if;
	end process;

	ODDR2_inst_n : ODDR port map (
			Q => IFCLK,
			C => CLK,
			CE => '1',
			D1 => '0',
			D2 => '1',
			R  => '0',
			S  => '0'
	);

--	INST_IODELAY2 : IODELAY2
--   generic map (
--      COUNTER_WRAPAROUND => "WRAPAROUND", -- STAY_AT_LIMIT or WRAPAROUND
--      DATA_RATE => "DDR",                 -- SDR or DDR
--      DELAY_SRC => "ODATAIN",                  -- IO, ODATAIN or IDATAIN
--      IDELAY2_VALUE => 0,                 -- Amount of Input Delay (0-255)
--      IDELAY_MODE => "NORMAL",            -- Unsupported
--      IDELAY_TYPE => "FIXED",           -- FIXED, DEFAULT, VARIABLE_FROM_ZERO, VARIABLE_FROM_HALF_MAX or
--                                          -- DIFF_PHASE_DETECTOR
--      IDELAY_VALUE => 0,                  -- Amount of input delay (0-255)
--      ODELAY_VALUE => 100,                  -- Amount of output delay (0-255)
--      SERDES_MODE => "NONE",              -- NONE, MASTER or SLAVE
--      SIM_TAPDELAY_VALUE => 75            -- Amount of delay used for simulation in pS
--   )
--   port map (
--      BUSY     => open,
--      DATAOUT  => open,
--      DATAOUT2 => open,
--      DOUT     => IFCLK,   
--      TOUT     => open,
--      CAL      => CAL, 
--      CE       => '1',
--      CLK      => CLK,
--      IDATAIN  => '0',
--      INC      => '0',
--      IOCLK0   => not CLK,
--      IOCLK1   => CLK,
--      ODATAIN  => tmpclk,
--      RST      => '0',
--      T        => '0'
--   );

	STATUS(2 downto 0) <= USTATE;
	STATUS(7 downto 3) <= (others => '0');

------------------ 
-- General State machine
------------------ 
	process(CLK) begin
		if(CLK'event and CLK='1') then
			case USTATE is 
				when "000" =>
					if((FLAGR = '1') and (RXRDY = '1')) then
						USTATE <= "001";
					elsif((FLAGR = '0') and (TXRDY = '1') and (FLAGW = '1')) then
						USTATE <= "100";
					end if;

				when "001" =>
					USTATE <= "010";

				when "010" =>
					if((FLAGR = '0') or (RXRDY = '0')) then
						USTATE <= "011";
					end if;

				when "011" =>
					USTATE <= "000";

				when "100" =>
					USTATE <= "101";
				when "101" =>
--					if((FLAGR = '1') and (RXRDY = '1')) then
--						USTATE <= "001";
					if((TXRDY = '0') or (FLAGW = '0')) then
						USTATE <= "110";
					end if;
				when "110" =>
					USTATE <= "111";
				when others =>
					USTATE <= "000";
			end case;
		end if;
	end process;

------------------ 
-- DATAOUT
------------------ 

	DATAOUT <= '1' when (USTATE(2) = '1') else '0';

------------------ 
-- FIFOADDR
------------------ 

	FIFOADR <= "00" when (USTATE(2) = '0') else "10";

------------------ 
-- FLAGR_D
------------------ 
--	process(CLK) begin
--		if(CLK'event and CLK='1') then
--			FLAGR_D <= FLAGR;
--		end if;
--	end process;

------------------ 
-- SLRD
------------------ 
	process(CLK) begin
		if(CLK'event and CLK='1') then
			if(FLAGR = '0') then
				SLRD_reg <= '1';
			elsif((USTATE = "001") or (USTATE = "010")) then
--			elsif((RXRDY = '1') and (FLAGR_D = '1')) then
				SLRD_reg <= '0';
			end if;
		end if;
	end process;

	SLRD_node <= SLRD_reg when(FLAGR = '1') else '1';
	SLRD <= SLRD_node;

------------------ 
-- SLOE
------------------ 
	SLOE <= '0' when (USTATE(2) = '0') else '1';

------------------ 
-- RECEIVED & RDATA
------------------ 
--	process(CLK) begin
--		if(CLK'event and CLK='0') then
--			RDATA_URA <= FD_IN(15 downto 0); -- IFD‚ÉŠ„‚è“–‚Ä‚ç‚ê‚é‚±‚Æ‚ðŠú‘Ò
--		end if;
--	end process;

	LOOP_IDDR : FOR I in 0 to 15 generate
		IDDR_inst : IDDR 
		port map (
			Q1 => open, -- 1-bit output for positive edge of clock 
			Q2 => RDATA_URA(I), -- 1-bit output for negative edge of clock
			C => CLK,   -- 1-bit clock input
			CE => '1', -- 1-bit clock enable input
			D => FD_IN(I),   -- 1-bit DDR data input
			R => '0',   -- 1-bit reset
			S => '0'    -- 1-bit set
		);
	end generate;

	process(CLK) begin
		if(CLK'event and CLK='1') then
			if(SLRD_node = '0') then
				RDATA <= RDATA_URA;--FD_IN(15 downto 0);
				RECEIVED <= '1';
			else
				RECEIVED <= '0';
			end if;
		end if;
	end process;

------------------ 
-- SLWR
------------------ 
	process(CLK) begin
		if(CLK'event and CLK='1') then
			if(TRANSMITTED_node = '1') then
--			if((USTATE = "100") or (USTATE = "101")) then
				SLWR_reg <= '0';
			else
				SLWR_reg <= '1';
			end if;
		end if;
	end process;


--	SLWR_node <= SLWR_reg when ((FLAGW = '1') and (TXRDY = '1')) else '1';
	SLWR_node <= SLWR_reg;-- when ((FLAGW = '1') and (TXRDY = '1')) else '1';
	SLWR      <= SLWR_node;

------------------ 
-- PKTEND
------------------ 
--	PKTEND_reg <= '0';
	PKTEND <= PKTEND_reg;

------------------ 
-- TRANSMITTED & WDATA
------------------ 
	process(CLK) begin
		if(CLK'event and CLK='1') then
			if(TRANSMITTED_node = '1') then
--			if((USTATE = "100") or (USTATE = "101")) then
				FD_OUT <= WDATA; -- OFD‚ÉŠ„‚è“–‚Ä‚ç‚ê‚é‚±‚Æ‚ðŠú‘Ò
			end if;
		end if;
	end process;

--	LOOP_ODDR : FOR I in 0 to 15 generate
--		ODDR2_inst_n : ODDR port map (
--				Q => FD_OUT(I),
--				C => CLK,
--				CE => TRANSMITTED_node,
--				D1 => WDATA(I),
--				D2 => WDATA(I),
--				R  => '0',
--				S  => '0'
--		);
--	end generate;

	TRANSMITTED_node <= '1' when ((USTATE = "101") and (FLAGW = '1') and (TXRDY = '1')) else '0';
	TRANSMITTED <= TRANSMITTED_node;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity my_odelay is
	Generic ( Delay : integer := 0 );
    Port ( I : in  STD_LOGIC;
           O : out  STD_LOGIC
	);
end my_odelay;
--
--architecture Behavioral of my_odelay is
--begin
--  INST_IODELAY2 : IODELAY2
--   generic map (
--      COUNTER_WRAPAROUND => "WRAPAROUND", -- STAY_AT_LIMIT or WRAPAROUND
--      DATA_RATE => "SDR",                 -- SDR or DDR
--      DELAY_SRC => "ODATAIN",                  -- IO, ODATAIN or IDATAIN
--      IDELAY2_VALUE => 0,                 -- Amount of Input Delay (0-255)
--      IDELAY_MODE => "NORMAL",            -- Unsupported
--      IDELAY_TYPE => "DEFAULT",           -- FIXED, DEFAULT, VARIABLE_FROM_ZERO, VARIABLE_FROM_HALF_MAX or
--                                          -- DIFF_PHASE_DETECTOR
--      IDELAY_VALUE => 0,                  -- Amount of input delay (0-255)
--      ODELAY_VALUE => Delay,                  -- Amount of output delay (0-255)
--      SERDES_MODE => "NONE",              -- NONE, MASTER or SLAVE
--      SIM_TAPDELAY_VALUE => 75            -- Amount of delay used for simulation in pS
--   )
--   port map (
--      BUSY     => open, -- 1-bit Busy after CAL
--      DATAOUT  => open, -- 1-bit Delayed data output
--      DATAOUT2 => open, -- 1-bit Delayed data output
--      DOUT     => O,    -- 1-bit Delayed Data Output to IOB
--      TOUT     => open, -- 1-bit Delayed Tristate Output
--      CAL      => '0',  -- 1-bit Initiate calibration input
--      CE       => '1',  -- 1-bit Enable increment/decrement
--      CLK      => '0',  -- 1-bit Clock input
--      IDATAIN  => '0',  -- 1-bit Data Signal from IOB
--      INC      => '0',  -- 1-bit Increment / Decrement input
--      IOCLK0   => '0',
--      IOCLK1   => '0',
--      ODATAIN  => I,    -- 1-bit Output data input from OLOGIC or OSERDES.
--      RST      => '0',  -- 1-bit Reset to zero or 1/2 of total period
--      T        => '0'   -- 1-bit Tristate input signal
--   );
--end Behavioral;
