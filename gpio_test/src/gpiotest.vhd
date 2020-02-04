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

entity gpiotest is
	Generic (
		CLKFREQ        : integer := 50000000;
		GPIO_BIT_WIDTH : integer := 64
	);
	Port (
		clk           : in  std_logic;
		pushsw_ip     : in  std_logic;
		gpio_op       : out std_logic_vector(GPIO_BIT_WIDTH - 1 downto 0);
		led_op        : out std_logic_vector(7 downto 0)
	);
end gpiotest;

architecture Behavioral of gpiotest is
	signal timer : integer range 0 to CLKFREQ/10-1; 
	signal led   : std_logic_vector(7 downto 0);
	signal gpio  : std_logic_vector(GPIO_BIT_WIDTH - 1 downto 0);

begin

	process(clk) begin
		if(clk'event and clk='1') then
			if(led = 0) then
				led <= x"01";
			else
				if(timer >= CLKFREQ/10 - 1) then
					timer <= 0;
					if(pushsw_ip = '0') then
						led <= led(6 downto 0) & led(7);
					else
						led <= led(0) & led(7 downto 1);
					end if;
				else
					timer <= timer + 1;
				end if;
			end if;
		end if;
	end process;

	led_op <= not led;

	process(clk) begin
		if(clk'event and clk='1') then
			if(gpio = 0) then
				gpio(0) <= '1';
			else
				gpio <= gpio(GPIO_BIT_WIDTH - 2 downto 0) & gpio(GPIO_BIT_WIDTH - 1);
			end if;
		end if;
	end process;
	
	gpio_op <= gpio;

end Behavioral;
