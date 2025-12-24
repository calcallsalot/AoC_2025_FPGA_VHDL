library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity day_1_tb is
end entity;

architecture sim of day_1_tb is
  signal clk      : std_logic := '0';
  signal reset    : std_logic := '1';
  signal step     : std_logic := '0';
  signal dir      : std_logic := '0';  -- '0'=L, '1'=R
  signal dial     : unsigned(9 downto 0) := (others => '0'); -- rotation amount
  signal password : unsigned(15 downto 0);

  constant CLK_PERIOD : time := 10 ns;
begin
  -- clock generator
  clk <= not clk after CLK_PERIOD/2;

  -- DUT
  uut: entity work.safe
    port map (
      clk      => clk,
      reset    => reset,
      step     => step,
      dir      => dir,
      dial     => dial,
      password => password
    );

  stim: process
    file f : text open read_mode is "inputs.txt"; -- make sure this file is in the run directory
    variable l : line;
    variable c : character;
    variable n : integer;
  begin
    -- Hold reset for a couple cycles
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    reset <= '0';

    -- Read each line like: R45 or L62
    while not endfile(f) loop
      readline(f, l);

      -- skip blank lines (optional)
      if l'length = 0 then
        next;
      end if;

      read(l, c);  -- 'R' or 'L'
      read(l, n);  -- integer amount

      if (c = 'R') or (c = 'r') then
        dir <= '1';
      elsif (c = 'L') or (c = 'l') then
        dir <= '0';
      else
        assert false report "Bad direction character in input" severity failure;
      end if;

      -- Drive amount (0..999 fits in 10 bits)
      -- No need to mod 100 here since RTL already does: to_integer(dial) mod 100
      if n < 0 then
        assert false report "Negative amount in input" severity failure;
      end if;
      dial <= to_unsigned(n, 10);

      -- Pulse step for one cycle so the instruction is applied once
      step <= '1';
      wait until rising_edge(clk);
      step <= '0';
      wait until rising_edge(clk);
    end loop;

    report "DONE. password = " & integer'image(to_integer(password)) severity note;
    wait;
  end process;

end architecture;
