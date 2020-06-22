----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;


entity processor is
    Port ( temporary_processor_instr_input : in STD_LOGIC_VECTOR(15 downto 0);  --delet
           clk : in STD_LOGIC;
           ext_rst : in STD_LOGIC;
           pc_out : out STD_LOGIC_VECTOR(9 downto 0));
end processor;

architecture Behavioral of processor is

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
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           prog_mem_out : out memarray_t);
     end component;
     
     component reset_module
     Port ( ext_rst : in STD_LOGIC;
           stkovf_rst : in STD_LOGIC;
           ilglop_rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           
           rstcon_sfr : in STD_LOGIC_VECTOR (7 downto 0);
           global_rst : out STD_LOGIC);
     end component;
     
     signal rst: std_logic;
     
     signal op: std_logic_vector(4 downto 0);
     signal dst, src : STD_LOGIC_VECTOR (2 downto 0);
     signal lit : STD_LOGIC_VECTOR (7 downto 0);
     signal data_en: std_logic;
     signal flags : STD_LOGIC_VECTOR(2 downto 0);
     signal stack_we : std_logic;
     signal stack_addr : std_logic_vector(7 downto 0);
     signal stack_data_out : std_logic_vector(7 downto 0);
     signal region : std_logic_vector(1 downto 0);
     
     signal a_readback, b_readback: STD_LOGIC_VECTOR(7 downto 0);
     signal stkovflw: std_logic;
     
     signal prog_mem_regs: memarray_t;
     signal ilgl_op: std_logic;

begin
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
        stkovflw => stkovflw
    );
    
    control: cu port map (
        instr_in => temporary_processor_instr_input,
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
        pc_out => pc_out,
        ilgl_op => ilgl_op,
        stack_we => stack_we
        --stack_addr => stack_addr
    );
    
    prog_memory: prog_mem port map (
        we => stack_we,
        rst => rst,
        clk => clk,
        in_data => b_readback,
        addr => stack_addr,
        region => region,
        out_data => stack_data_out,
        prog_mem_out => prog_mem_regs
    );
    
    reset_mod: reset_module port map (
        ext_rst => ext_rst,
        stkovf_rst => stkovflw,
        ilglop_rst => ilgl_op,
        clk => clk,
        rstcon_sfr => prog_mem_regs(512),
        global_rst => rst
    );
    
    --stack address selector
    process(stack_we, a_readback, b_readback)
    begin
        if(stack_we = '1') then
            stack_addr <= a_readback;
        else
            stack_addr <= b_readback;
        end if;
    end process;
    
    

end Behavioral;
