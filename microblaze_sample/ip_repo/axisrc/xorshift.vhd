----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:32:25 08/12/2012 
-- Design Name: 
-- Module Name:    xorshift - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xorshift is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en : in  STD_LOGIC;
           res2   : out  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end xorshift;

architecture Behavioral of xorshift is

	signal x : std_logic_vector(31 downto 0);
	signal y : std_logic_vector(31 downto 0);
	signal z : std_logic_vector(31 downto 0);
	signal w : std_logic_vector(31 downto 0);
	
	signal reset_d : std_logic;

begin

	process(clk)
		variable t : std_logic_vector(31 downto 0);
	begin
		if(clk'event and clk='1') then
			reset_d <= reset;
			if(reset = '1') then
				x <= conv_std_logic_vector(123456789,32);
				y <= conv_std_logic_vector(362436069,32);
				z <= conv_std_logic_vector(521288629,32);
				w <= conv_std_logic_vector(88675123,32);
			elsif(en = '1') or (reset_d = '1') then
				t := x xor (x(20 downto 0) & "00000000000");
				x <= y;
				y <= z;
				z <= w;
				w <= (w xor ("0000000000000000000" & w(31 downto 19)))
					  xor
				     (t xor ("00000000" & t(31 downto 8)));
			end if;
		end if;
	end process;
	
	res2 <= x xor y;
	result <= w;

end Behavioral;

