library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity safe is 
    port ( 
        clk : in std_logic;
        reset : in std_logic;
		step : in std_logic;
        dir : in std_logic; -- '0' for left and '1' for right 
        dial : in unsigned(9 downto 0); -- rotation_amount 
        password : out unsigned(15 downto 0)
    );
end entity safe;

architecture rtl of safe is 
	signal pointer : unsigned(6 downto 0) := to_unsigned(50, 7); -- where we are 'at' so 0-99 
    signal counter : unsigned(15 downto 0) := (others => '0'); -- basically password bc it's the amount of times we hit 0 
begin
    process(clk) -- maybe it's process(clk, reset) instead?
        variable dial_amount : integer;
        variable dial_pointer : integer;
        variable next_pointer : integer;
	begin
		if rising_edge(clk) then
			if reset = '1' then 
				pointer <= to_unsigned(50, 7);
				counter <= (others => '0');
			elsif step = '1' then -- one clock cycle
				dial_pointer := to_integer(pointer);
				dial_amount := to_integer(dial) mod 100;
				if dir = '1' then -- right rotation 
					next_pointer := (dial_pointer + dial_amount) mod 100; 
				else -- elsif dir = '0' then and left rotation
					next_pointer := (dial_pointer - dial_amount) mod 100;
					if next_pointer < 0 then 
						next_pointer := next_pointer + 100;
					end if; 
				end if;
				
				pointer <= to_unsigned(next_pointer, 7);
				
				if next_pointer = 0 then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;
	password <= counter; -- setting password to the counter 
end architecture rtl;