library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LED_Shifter is
    generic (
        COUNTER_MAX : integer := 25000000  -- 100 MHz clock, 250ms (100e6 * 0.25)
    );
    Port (
        clk         : in std_logic;        -- 100 MHz clock
        reset       : in std_logic;        -- Reset signal
        btn_left    : in std_logic;        -- Push button to select left shift
        btn_right   : in std_logic;        -- Push button to select right shift
        leds        : out std_logic_vector(3 downto 0) -- 4 LEDs
    );
end LED_Shifter;

architecture Behavioral of LED_Shifter is
    signal led_reg : std_logic_vector(3 downto 0) := "0001"; -- Starting LED pattern
    signal counter : integer := 0;
    signal shift_enable : std_logic := '0';
    signal shift_direction : std_logic := '0'; -- '0' for right, '1' for left
    signal btn_left_pressed  : std_logic := '0';
    signal btn_right_pressed : std_logic := '0';
    
begin
    -- Process to control the timing (250ms)
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            shift_enable <= '0';
        elsif rising_edge(clk) then
            if counter = COUNTER_MAX - 1 then
                counter <= 0;
                shift_enable <= '1';  -- Enable shift after 250ms
            else
                counter <= counter + 1;
                shift_enable <= '0';
            end if;
        end if;
    end process;

    -- Process to change the direction based on button presses
    process(clk, reset)
    begin
        if reset = '1' then
            shift_direction <= '0';  -- Default to right shift
            btn_left_pressed <= '0';
            btn_right_pressed <= '0';
        elsif rising_edge(clk) then
            -- Detect left button press and toggle direction to left
            if btn_left = '1' and btn_left_pressed = '0' then
                shift_direction <= '1';  -- Set to left shift
                btn_left_pressed <= '1'; -- Debounce mechanism
            elsif btn_left = '0' then
                btn_left_pressed <= '0'; -- Button released
            end if;

            -- Detect right button press and toggle direction to right
            if btn_right = '1' and btn_right_pressed = '0' then
                shift_direction <= '0';  -- Set to right shift
                btn_right_pressed <= '1'; -- Debounce mechanism
            elsif btn_right = '0' then
                btn_right_pressed <= '0'; -- Button released
            end if;
        end if;
    end process;

    -- Process for shifting the LEDs
    process(clk, reset)
    begin
        if reset = '1' then
            led_reg <= "0001";  -- Reset LED pattern to first LED on
        elsif rising_edge(clk) then
            if shift_enable = '1' then
                if shift_direction = '1' then
                    -- Left circular shift
                    led_reg <= led_reg(2 downto 0) & led_reg(3);
                else
                    -- Right circular shift
                    led_reg <= led_reg(0) & led_reg(3 downto 1);
                end if;
            end if;
        end if;
    end process;

    leds <= led_reg; -- Assign the current LED pattern to the output

end Behavioral;
