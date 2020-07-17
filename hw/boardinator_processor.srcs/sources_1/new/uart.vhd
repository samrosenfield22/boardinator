library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity uart is
generic (
  STARTBIT_CNT: natural := 1;
  STOPBIT_CNT:  natural := 1
);
port (
  rst, clk:               in std_logic;
  txcon_reg, tx_byte_reg: in std_logic_vector(7 downto 0);
  txstat_reg:             out std_logic_vector(7 downto 0);
  txpin : out STD_LOGIC;
  rxpin : in STD_LOGIC
);
end uart;

architecture Behavioral of uart is

component timer_module
     Port(
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        tmrcon_sfr, tmrcmp_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        tmrout_sfr : out STD_LOGIC_VECTOR (7 downto 0)
    );
    end component;

constant WORDLEN:       natural := 8 + STARTBIT_CNT + STOPBIT_CNT;

--txcon bits
constant TX_START_BIT:  natural := 0;
constant BAUD_HILO_BIT: natural := 1;
constant TX_EN_BIT:     natural := 7;

constant TXBUSY_BIT:    natural := 0; --b0 of txstat

--values calculated to give 1/9600 and 1/115200 sec delays
--using the sfr calculator
constant LO_BAUD_PRESCALE:  std_logic_vector(3 downto 0) := "0000";     --0
constant LO_BAUD_COMPARE:   std_logic_vector(7 downto 0) := "10100011"; --163;
constant HI_BAUD_PRESCALE:  std_logic_vector(3 downto 0) := "0000";     --0
constant HI_BAUD_COMPARE:   std_logic_vector(7 downto 0) := "00001110"; --14    3.2% error

--signal tx_word:         std_logic_vector(WORDLEN-1 downto 0);
signal startbits:       std_logic_vector(STARTBIT_CNT-1 downto 0);
signal stopbits:        std_logic_vector(STOPBIT_CNT-1 downto 0);
signal tx_start:        std_logic := '0';

signal uart_tmr_prescale:   std_logic_vector(3 downto 0);
signal uart_tmr_cmp:        std_logic_vector(7 downto 0);

signal tmr_tick:        std_logic := '0';
signal tmrcon:          std_logic_vector(7 downto 0);
signal baud_hilo:       std_logic;

signal dummy_open: std_logic_vector(6 downto 0);

begin

baud_hilo <= txcon_reg(BAUD_HILO_BIT);
uart_tmr_prescale <= LO_BAUD_PRESCALE when baud_hilo='0' else HI_BAUD_PRESCALE;
uart_tmr_cmp <= LO_BAUD_COMPARE when baud_hilo='0' else HI_BAUD_COMPARE;

tmrcon <= txcon_reg(TX_EN_BIT) & "000" & uart_tmr_prescale;

uart_timer: timer_module port map (
        rst => rst,
        clk => clk,
        tmrcon_sfr => tmrcon,
        tmrcmp_sfr => uart_tmr_cmp,
        tmrout_sfr(0) => tmr_tick,   --we don't care about tmrout(7 downto 1)
        tmrout_sfr(7 downto 1) => dummy_open
    );

--transmit
tx_start <= txcon_reg(TX_START_BIT);
stopbits <= (others => '1');
startbits <= (others => '0');
--tx_word <= stopbits & tx_byte_reg & startbits;

--when tx_start transitions hi, load the word, then shift it out on every timer tick
tx_shift : process(tx_start, tmr_tick)
  variable tx_busy:       std_logic := '0';
  variable tx_shift_cnt:  natural := 0;
  variable tx_word:       std_logic_vector(WORDLEN-1 downto 0);
begin
  if(tx_start'event and tx_start='1') then
    tx_busy := '1';
    tx_shift_cnt := WORDLEN;
    tx_word := stopbits & tx_byte_reg & startbits;
  end if;

  if(tx_busy='1') then
    if (tmr_tick'event and tmr_tick='1') then
        --tx_word(WORDLEN-1 downto 1) := tx_word(WORDLEN-2 downto 0);
        --txpin <= tx_word(WORDLEN-1);
        --tx_word(WORDLEN-2 downto 0) := tx_word(WORDLEN-1 downto 1);
        --txpin <= tx_word(0);
        --tx_word := "0" & tx_word(WORDLEN-1 downto 1);
--        tx_shift_cnt := tx_shift_cnt-1;
    
--        if(tx_shift_cnt = 0) then
--          tx_busy := '0';
--        end if;
        
        if(tx_shift_cnt = 0) then
            tx_busy := '0';
        else
            txpin <= tx_word(0);
            tx_word := "0" & tx_word(WORDLEN-1 downto 1);
            tx_shift_cnt := tx_shift_cnt-1;
        end if;
     end if;
  else
    txpin <= '1';
  end if;

  txstat_reg(TXBUSY_BIT) <= tx_busy;
end process;



--rx_shift : process(rx, rx_tmrout_reg)
--variable rx_en: std_logic := '0';
--variable rx_tmr_matchval: natural := 0;
--variable rx_word_int: std_logic_vector(WORDLEN-1 downto 0) := (others => '0');
--variable rx_shift_cnt: natural := 0;
--begin
--  if (rx'event and rx='0') then
--    rx_en := '1';
--    rx_tmr_matchval := natural(rx_tmrout_reg);  --this isn't how you cast it, is it...
--                                                --this samples on the transition -- we want to sample in the middle of each bit
--                                                --(matchval+128) % 256
--                                                --ehhhhhhhh
--    rx_word_int := (others => '0');
--    rx_shift_cnt := WORDLEN;
--  end if;

--  if(rx_en = '1' and rx_tmr_matchval=natural(rx_tmrout_reg)) then
--    rx_word_int <= rx & rx_word_int(WORDLEN-1 downto 1);
--    rx_shift_cnt := rx_shift_cnt-1;

--    if(rx_shift_cnt = 0)
--      --check for framing errors?
--      rx_byte <= rx_word_int(STARTBIT_CNT+7 downto STARTBIT_CNT);
--      rx_shift_cnt := 0;
--      rx_en := 0;
--    end if;
--  end if;
--end process;

end Behavioral;
