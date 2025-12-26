library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_rotation is 
    port ( 
        clk : in std_logic;
        reset : in std_logic;
		step : in std_logic;
        dir : in std_logic; -- '0' for left and '1' for right 
        dial : in unsigned(9 downto 0); -- rotation_amount 
        password : out unsigned(15 downto 0)
    );
end entity full_rotation;

architecture rtl of full_rotation is 
	signal pointer : unsigned(6 downto 0) := to_unsigned(50, 7);
	signal counter : unsigned(15 downto 0) := (others => '0');
begin 
	process(clk) 
		variable dial_amount_floor : integer;
		variable dial_amount_remainder : integer;
        variable dial_pointer : integer;
        variable next_pointer : integer;
		variable addhit : integer; 
		variable next_counter : integer;
		
		
	begin
		if rising_edge(clk) then
			if reset = '1' then 
				pointer <= to_unsigned(50, 7);
				counter <= (others => '0');
				addhit := 0;
			elsif step = '1' then 
				addhit := 0;
				dial_pointer := to_integer(pointer);
				dial_amount_floor := to_integer(dial)/100;
				dial_amount_remainder := to_integer(dial) mod 100;
				if dir = '1' then -- right rotation   
					if (dial_pointer /= 0) and (dial_amount_remainder >= (100 - dial_pointer)) then 
						addhit := 1;
					end if;
					next_pointer := (dial_pointer + dial_amount_remainder) mod 100;
				else -- left rotation  
					if (dial_pointer /= 0) and (dial_amount_remainder >= dial_pointer) then
						addhit := 1;
					end if;
					next_pointer := (dial_pointer - dial_amount_remainder) mod 100;
					if next_pointer < 0 then 
						next_pointer := next_pointer + 100;
					end if;
				end if;
				
				next_counter := to_integer(counter) + dial_amount_floor + addhit;
				pointer <= to_unsigned(next_pointer, 7);
				counter <= to_unsigned(next_counter, counter'length);
				
				
			end if;
		end if;
	end process;
	password <= counter;
end architecture rtl;
				