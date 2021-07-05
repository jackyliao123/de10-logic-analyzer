library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frontend_part is
    port(
        clk     : in  std_logic; 
        reset   : in  std_logic;
        i       : in  std_logic;
        o_valid : out std_logic;                                 
        o       : out std_logic_vector(7 downto 0)
    );    
end entity;

architecture main of frontend_part is
    -- state
    signal v : std_logic_vector(7 downto 0);

    -- registers
    signal r1 : std_logic_vector(7 downto 0);
    signal r2 : std_logic_vector(7 downto 0);
    signal r3 : std_logic;

    -- shifter
    signal shifter_src : std_logic_vector(7 downto 0);
    signal shifter : std_logic_vector(7 downto 0);
    
begin
    o <= r2;
    o_valid <= r3;

    -- shifter
    shifter_src <= std_logic_vector(shift_left(unsigned(r1), 1));
    shifter <= shifter_src(7 downto 1) & i;

    -- state
    process begin
        wait until rising_edge(clk);
        if reset = '1' then
            v(7 downto 1) <= (others => '0');
            v(0) <= '1';
        else
            v(7 downto 0) <= std_logic_vector(rotate_left(unsigned(v), 1));
        end if;
    end process;

    -- r1
    process begin
        wait until rising_edge(clk);
        if v(0) = '1' then
                r1 <= "0000000" & i;
        else
                r1 <= shifter;
        end if;
    end process;
    -- r2
    process begin
        wait until rising_edge(clk);
        if v(7) = '1' then
                r2 <= shifter;
        end if;
    end process;
    -- r3
    process begin
        wait until rising_edge(clk);
        r3 <= v(7);
    end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frontend is
    port(
        clk     : in  std_logic; 
        reset   : in  std_logic;
        inin    : in  std_logic_vector(1 downto 0);
        o_valid : out std_logic;                                 
        outout  : out std_logic_vector(15 downto 0)
    );    
end entity;

architecture main of frontend is
    -- state
    signal o_v : std_logic_vector(1 downto 0);

begin
    part0 : entity work.frontend_part(main)
        port map(
            clk     => clk,
            reset   => reset,
            i       => inin(0),
            o_valid => o_v(0),
            o       => outout(7 downto 0)
        );
    part1 : entity work.frontend_part(main)
        port map(
            clk     => clk,
            reset   => reset,
            i       => inin(1),
            o_valid => o_v(1),
            o       => outout(15 downto 8)
        );
    
    o_valid <= o_v(0);
end architecture;
