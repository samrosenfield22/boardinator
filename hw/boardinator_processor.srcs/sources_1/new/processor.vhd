----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity processor is
    Port ( temporary_processor_instr_input : in STD_LOGIC_VECTOR(15 downto 0);  --delet
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
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
           --stack_addr : in STD_LOGIC_VECTOR(7 downto 0);
           
           out_word : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR(2 downto 0);
           
           a_readback : out STD_LOGIC_VECTOR(7 downto 0);
           b_readback : out STD_LOGIC_VECTOR(7 downto 0));
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
            data_en : out STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR (9 downto 0);
            
            stack_we : out STD_LOGIC
            --stack_addr : out STD_LOGIC_VECTOR(7 downto 0)
            );
     end component;
     
     signal op: std_logic_vector(4 downto 0);
     signal dst, src : STD_LOGIC_VECTOR (2 downto 0);
     signal lit : STD_LOGIC_VECTOR (7 downto 0);
     signal data_en: std_logic;
     signal flags : STD_LOGIC_VECTOR(2 downto 0);
     signal stack_we : std_logic;
     signal stack_addr : std_logic_vector(7 downto 0);
     
     signal a_readback, b_readback: STD_LOGIC_VECTOR(7 downto 0);

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
        --stack_addr => stack_addr,
        out_word => open,
        flags => flags,
        a_readback => a_readback,
        b_readback => b_readback
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
        data_en => data_en,
        pc_out => pc_out,
        
        stack_we => stack_we
        --stack_addr => stack_addr
    );
    
    

end Behavioral;
