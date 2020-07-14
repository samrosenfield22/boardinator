----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;


entity processor is
    Port ( --temporary_processor_instr_input : in STD_LOGIC_VECTOR(15 downto 0);  --delet
           clk_in : in STD_LOGIC;
           ext_rst : in STD_LOGIC;
           --pc_out : out STD_LOGIC_VECTOR(9 downto 0);
           
			  --test_out : out STD_LOGIC_VECTOR(7 downto 0);
			  
           gpio_pins : inout STD_LOGIC_VECTOR(7 downto 0)
			  
           );
end processor;

architecture Behavioral of processor is
    
--    component BUFGP
--    port(I: in STD_LOGIC; O: out STD_LOGIC);
--    end component;

    component instruction_mem
    Port ( clk : in STD_LOGIC;
           pc : in STD_LOGIC_VECTOR (9 downto 0);
           instr : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component datapath
    Port ( op : in STD_LOGIC_VECTOR (4 downto 0);
           dst, src: in STD_LOGIC_VECTOR (2 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           lit : in STD_LOGIC_VECTOR (7 downto 0);
           en : in STD_LOGIC;
           
           stack_we : in STD_LOGIC;
           stack_data_out : in STD_LOGIC_VECTOR(7 downto 0);
           
           out_word : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR(2 downto 0);
           
           a_readback : out STD_LOGIC_VECTOR(7 downto 0);
           b_readback : out STD_LOGIC_VECTOR(7 downto 0);
			  reg0_out: out STD_LOGIC_VECTOR (7 downto 0);
           stkovflw : out STD_LOGIC);
     end component;
     
     component cu
     Port (  instr_in : in STD_LOGIC_VECTOR (15 downto 0);
            rst : in STD_LOGIC;
            clk : in STD_LOGIC;
            flags : in STD_LOGIC_VECTOR(2 downto 0);
            a_readback : in STD_LOGIC_VECTOR(7 downto 0);
            b_readback : in STD_LOGIC_VECTOR(7 downto 0);
            
            op : out STD_LOGIC_VECTOR (4 downto 0);
            dst, src : out STD_LOGIC_VECTOR (2 downto 0);
            lit : out STD_LOGIC_VECTOR (7 downto 0);
            mem_region : out STD_LOGIC_VECTOR(1 downto 0);
            data_en : out STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR (9 downto 0);
            
            ilgl_op : out STD_LOGIC;
            stack_we : out STD_LOGIC
            --stack_addr : out STD_LOGIC_VECTOR(7 downto 0)
            );
     end component;
     
     component prog_mem
     Port ( we : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           in_data : in STD_LOGIC_VECTOR (7 downto 0);
           addr : in STD_LOGIC_VECTOR (7 downto 0);
           region : in STD_LOGIC_VECTOR (1 downto 0);
           
           rstcause_sfr, tmrout_sfr, ina_sfr, inb_sfr: in STD_LOGIC_VECTOR (7 downto 0);
           
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           prog_mem_out : out memarray_t);
     end component;
     
     component reset_module
     Port ( ext_rst : in STD_LOGIC;
           stkovf_rst : in STD_LOGIC;
           ilglop_rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           
           rstcon_sfr : in STD_LOGIC_VECTOR (7 downto 0);
           rstcause_sfr : out STD_LOGIC_VECTOR (7 downto 0);
           global_rst : out STD_LOGIC);
     end component;
     
     component timer_module
     Port(
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        tmrcon_sfr, tmrcmp_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        tmrout_sfr : out STD_LOGIC_VECTOR (7 downto 0)
    );
    end component;
    
    component iobank_module
    Port (
        mode_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        write_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        read_sfr : out STD_LOGIC_VECTOR (7 downto 0);
        pins : inout STD_LOGIC_VECTOR (7 downto 0)
    );
    end component;
     
     signal clk, rst: std_logic := '1';
     
     signal op: std_logic_vector(4 downto 0);
     signal dst, src : STD_LOGIC_VECTOR (2 downto 0);
     signal lit : STD_LOGIC_VECTOR (7 downto 0);
     signal data_en: std_logic;
     signal flags : STD_LOGIC_VECTOR(2 downto 0);
     signal stack_we : std_logic;
     signal stack_addr_out : std_logic_vector(7 downto 0);
     signal stack_data_out : std_logic_vector(7 downto 0);
     signal region, region_out : std_logic_vector(1 downto 0);
     
     signal a_readback, b_readback: STD_LOGIC_VECTOR(7 downto 0);
     signal stkovflw: std_logic;
     
     signal prog_mem_regs: memarray_t;
     signal ilgl_op: std_logic;
     
     signal rstcause_sfr, tmrout_sfr: std_logic_vector(7 downto 0);
     signal ina_sfr, inb_sfr: std_logic_vector(7 downto 0);
     signal temporary_processor_instr: std_logic_vector(15 downto 0);
     signal pc: std_logic_vector(9 downto 0);
     
     signal operand: unsigned(4 downto 0);
     
     signal test_out_int: std_logic_vector(7 downto 0) := "01010101";
     
     signal clk0, clk1, clk2, clk3: std_logic := '0';

begin
    
--    global_clk_buf: BUFGP port map (
--        O => clk,
--        I => clk_in
--    );
    --clk <= clk_in;
    
    process(clk_in)
    begin
        if(clk_in'event and clk_in='1') then clk0 <= not(clk0); end if;
    end process;
    process(clk0)
    begin
        if(clk0'event and clk0='1') then clk1 <= not(clk1); end if;
    end process;
    process(clk1)
    begin
        if(clk1'event and clk1='1') then clk2 <= not(clk2); end if;
    end process;
    process(clk2)
    begin
        if(clk2'event and clk2='1') then clk3 <= not(clk3); end if;
    end process;
    process(clk3)
    begin
        if(clk3'event and clk3='1') then clk <= not(clk); end if;
    end process;
    
    
    mock_program_memory: instruction_mem port map (
        clk => clk,
        instr => temporary_processor_instr,
        pc => pc
    );
    
    data_path: datapath port map (
        op => op,
        dst => dst,
        src => src,
        rst => rst,
        clk => clk,
        lit => lit,
        en => data_en,
        stack_we => stack_we,
        stack_data_out => stack_data_out,
        --stack_addr => stack_addr,
        out_word => open,
        flags => flags,
        a_readback => a_readback,
        b_readback => b_readback,
		  --reg0_out => test_out_int,
		  --reg0_out => gpio_pins,
		  reg0_out => open,
        stkovflw => stkovflw
    );
	 --test_out_int <= "01010101";
	 --gpio_pins <= test_out_int;
    
    control: cu port map (
        instr_in => temporary_processor_instr,
        rst => rst,
        clk => clk,
        flags => flags,
        a_readback => a_readback,
        b_readback => b_readback,
        op => op,
        dst => dst,
        src => src,
        lit => lit,
        mem_region => region,
        data_en => data_en,
        pc_out => pc,
        ilgl_op => ilgl_op,
        stack_we => stack_we
        --stack_addr => stack_addr
    );
    
    prog_memory: prog_mem port map (
        we => stack_we,
        rst => rst,
        clk => clk,
        in_data => b_readback,
        addr => stack_addr_out,
        region => region_out,
        
        rstcause_sfr => rstcause_sfr,
        tmrout_sfr => tmrout_sfr,
        ina_sfr => ina_sfr,
        inb_sfr => inb_sfr,
        
        out_data => stack_data_out,
        prog_mem_out => prog_mem_regs
    );
    
    reset_mod: reset_module port map (
        ext_rst => ext_rst,
        stkovf_rst => stkovflw,
        ilglop_rst => ilgl_op,
        clk => clk,
        rstcon_sfr => prog_mem_regs(RSTCON + SFR_REGION_ADDR),
        rstcause_sfr => rstcause_sfr,
        --global_rst => rst
		  global_rst => open
    );
	 rst <= ext_rst;
    
    timer_mod: timer_module port map (
        rst => rst,
        clk => clk,
        tmrcon_sfr => prog_mem_regs(TMRCON + SFR_REGION_ADDR),
        tmrcmp_sfr => prog_mem_regs(TMRCMP + SFR_REGION_ADDR),
        tmrout_sfr => tmrout_sfr
    );
    
    --test_out <= test_out_int;
    port_a: iobank_module port map (
        mode_sfr => prog_mem_regs(MODEA + SFR_REGION_ADDR),
        write_sfr => prog_mem_regs(OUTA + SFR_REGION_ADDR),
        read_sfr => ina_sfr,
        --pins => gpio_pins(7 downto 0)
        pins => gpio_pins
		  --pins => open
    );
    port_b: iobank_module port map (
        mode_sfr => prog_mem_regs(MODEB + SFR_REGION_ADDR),
        write_sfr => prog_mem_regs(OUTB + SFR_REGION_ADDR),
        read_sfr => inb_sfr,
        --pins => gpio_pins(15 downto 8)
        pins => open
    );
    --etc
    
    --stack address selector
    process(operand, stack_we, a_readback, b_readback)
    begin
        if(not(operand=SETM_OP or operand=GETM_OP)) then
            stack_addr_out <= (others => '0');
            region_out <= (others => '0');
        else
            region_out <= region;
            if(stack_we = '1') then
                stack_addr_out <= a_readback;
            else
                stack_addr_out <= b_readback;
            end if;
        end if;
    end process;
    
    operand <= unsigned(op);

end Behavioral;
