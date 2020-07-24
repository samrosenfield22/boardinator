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
  rst, clk:                 in std_logic;
  uartcon_reg, tx_byte_reg:   in std_logic_vector(7 downto 0);
  uartstat_reg, rx_byte_reg:  out std_logic_vector(7 downto 0);
  txpin : out STD_LOGIC;
  rxpin : in STD_LOGIC;
  
  rxreg_read_sig : in STD_LOGIC
);
end uart;

architecture Behavioral of uart is

component timer_module
     Port(
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        tmrcon_sfr, tmrcmp_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        tmrout_sfr, tmrstat_sfr : out STD_LOGIC_VECTOR (7 downto 0)
    );
    end component;

constant WORDLEN:       natural := 8 + STARTBIT_CNT + STOPBIT_CNT;

--uartcon bits
constant TX_START_BIT:  natural := 0;
constant BAUD_HILO_BIT: natural := 1;
constant LOOPBACK_BIT:  natural := 2;
constant TX_EN_BIT:     natural := 7;

--uartstat bits
constant TXBUSY_BIT:    natural := 0;
constant RXBUSY_BIT:    natural := 1;
constant RXAVAIL_BIT:   natural := 2;

--values calculated to give 1/9600 and 1/115200 sec delays
--using the sfr calculator
constant LO_BAUD_PRESCALE:  std_logic_vector(3 downto 0) := "0000";     --0
constant LO_BAUD_COMPARE:   std_logic_vector(7 downto 0) := "01010001"; --81;
constant HI_BAUD_PRESCALE:  std_logic_vector(3 downto 0) := "0000";     --0
constant HI_BAUD_COMPARE:   std_logic_vector(7 downto 0) := "00000111"; --7    3.2% error

signal txint, rxint:    std_logic := '1';

--signal tx_word:         std_logic_vector(WORDLEN-1 downto 0);
signal startbits:       std_logic_vector(STARTBIT_CNT-1 downto 0);
signal stopbits:        std_logic_vector(STOPBIT_CNT-1 downto 0);
--signal tx_start:        std_logic := '0';

signal uart_tmr_prescale:   std_logic_vector(3 downto 0);
signal uart_tmr_cmp:        std_logic_vector(7 downto 0);
signal uart_tmr_val:        std_logic_vector(7 downto 0);
signal loopback:            std_logic := '0';

signal uartstat_buf:        std_logic_vector(7 downto 0) := (others => '0');

--signal tmr_tick:        std_logic := '0';
--signal tx_clk:          std_logic := '0';
signal tmrcon:          std_logic_vector(7 downto 0);
signal baud_hilo:       std_logic;

signal rx_match_val:    std_logic_vector(7 downto 0) := (others => '0');
signal rx_tick:         std_logic := '0';

signal dummy_open:      std_logic_vector(6 downto 0);

-- Signals for tx_start and busy
signal txStart, txStart_r : std_logic := '0';
signal txBusy, txBusy_r : std_logic := '0';
signal tmr_tick, tmrTick_r : std_logic := '0';

begin

txpin <= txint;

baud_hilo <= uartcon_reg(BAUD_HILO_BIT);
uart_tmr_prescale <= LO_BAUD_PRESCALE when baud_hilo='0' else HI_BAUD_PRESCALE;
uart_tmr_cmp <= LO_BAUD_COMPARE when baud_hilo='0' else HI_BAUD_COMPARE;

tmrcon <= uartcon_reg(TX_EN_BIT) & "000" & uart_tmr_prescale;

uartstat_reg <= uartstat_buf;

uart_timer: timer_module port map (
        rst => rst,
        clk => clk,
        tmrcon_sfr => tmrcon,
        tmrcmp_sfr => uart_tmr_cmp,
        tmrout_sfr => uart_tmr_val,
        tmrstat_sfr(0) => tmr_tick,
        tmrstat_sfr(7 downto 1) => dummy_open
    );

--transmit
txStart <= uartcon_reg(TX_START_BIT);
stopbits <= (others => '1');
startbits <= (others => '0');
--tx_word <= stopbits & tx_byte_reg & startbits;

--when tx_start transitions hi, load the word, then shift it out on every timer tick
--transmitter : process(tx_start, tmr_tick, tx_clk)
--transmitter : process(tx_start, tmr_tick)
--  variable tx_busy:         std_logic := '0';
--  variable tx_shift_cnt, cnt_next:    natural := 0;
--  variable tx_word:         std_logic_vector(WORDLEN-1 downto 0);
--begin
--  if(tx_busy='0') then
--	 txint <= '1';
--     tx_clk <= '0';
	 
--	 if(tx_start'event and tx_start='1') then
--      tx_busy := '1';
--      uartstat_buf(TXBUSY_BIT) <= '1';
--      tx_shift_cnt := WORDLEN;
--      tx_word := stopbits & tx_byte_reg & startbits;
--	 end if;
--  else
--    if (tmr_tick'event and tmr_tick='1') then
--        if(tx_clk='0') then
--          if(tx_shift_cnt = 0) then
--              tx_busy := '0';
--              uartstat_buf(TXBUSY_BIT) <= '0';
--              --txint <= '1';
--          else
--              txint <= tx_word(0);
--              tx_word := "0" & tx_word(WORDLEN-1 downto 1);
--              tx_shift_cnt := tx_shift_cnt-1;
--          end if;
--        end if; 
        
--        tx_clk <= not(tx_clk);
--    end if;
--  end if;

--  --uartstat_buf(TXBUSY_BIT) <= tx_busy;
--end process;




transmitter : process(clk)
  type txState_t is (IDLE, BUSY, DONE);
  variable txState : txState_t := IDLE;
  
  variable tx_shift_cnt, cnt_next: natural := 0;
  variable tx_word: std_logic_vector(WORDLEN-1 downto 0);
  variable tx_clk: std_logic := '0';
begin

  if rising_edge(clk) then

  -- Register to look for edges 
  txStart_r <= txStart;
  txBusy_r <= txBusy;
  tmrTick_r <= tmr_tick;

    case (txState) is
      when IDLE =>
        if (txStart_r = '0' and txStart = '1') then
          txState := BUSY;
          txint <= '1';
          tx_shift_cnt := WORDLEN;
          tx_clk := '0';
          tx_word := stopbits & tx_byte_reg & startbits;
        end if;

      when BUSY =>
        txBusy  <= '1';
        if(tmrTick_r = '0' and tmr_tick = '1') then
          if(tx_clk = '0') then
            if (tx_shift_cnt = 0) then
              txState := DONE;
            else
              txint <= tx_word(0);
              tx_word := "0" & tx_word(WORDLEN-1 downto 1);
              tx_shift_cnt := tx_shift_cnt - 1;
            end if;
          end if;

          tx_clk := not(tx_clk);
        end if;

      when DONE =>
        -- Reset things here
        txBusy  <= '0';
        txState := IDLE;
    end case;

    uartstat_buf(TXBUSY_BIT) <= txBusy;

  end if;
end process;


loopback <= uartcon_reg(LOOPBACK_BIT);
rxint <=    rxpin when loopback='0' else
            txint;

rx_tick <= '1' when (rx_match_val = uart_tmr_val) else '0';

receiver: process(rxint, rx_tick, rxreg_read_sig)
    variable rx_word:           std_logic_vector(WORDLEN-1 downto 0) := (others => '0');
    variable rx_busy, rx_avail: std_logic := '0';
    --variable rx_match_val:  std_logic_vector(7 downto 0) := (others => '0');
    variable rx_shift_cnt:      natural := 0;
    variable is_sample:         std_logic := '1';
begin
    if(rx_busy = '0') then
        if(rxint'event and rxint='0') then
            rx_busy := '1';
            rx_shift_cnt := WORDLEN;
            rx_match_val <= uart_tmr_val;
            is_sample := '1';
        end if;
        
        if(rx_avail='1' and (rxreg_read_sig'event and rxreg_read_sig='1')) then
            rx_avail := '0';
        end if;
    else
        if(rx_tick'event and rx_tick='1') then
            is_sample := not(is_sample);
            if(is_sample = '1') then
                if(rx_shift_cnt = 0) then
                    rx_busy := '0';
                    rx_avail := '1';
                    rx_match_val <= (others => '0');    --
                    rx_byte_reg <= rx_word(STARTBIT_CNT+7 downto STARTBIT_CNT);
                    
                    --check for framing error?
                else
                    rx_word := rxint & rx_word(WORDLEN-1 downto 1);
                    rx_shift_cnt := rx_shift_cnt - 1;
                end if;
            end if;
        end if;
    end if;
    
    uartstat_buf(RXBUSY_BIT) <= rx_busy;
    uartstat_buf(RXAVAIL_BIT) <= rx_avail;
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
