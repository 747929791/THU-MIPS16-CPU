--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package defines is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--
   constant ZeroWord : std_logic_vector(15 downto 0) := "0000000000000000";
	constant RegAddrZero : std_logic_vector(3  downto 0) := "0000";
	constant NopInst : std_logic_vector(15 downto 0) := "0000100000000000";
	constant Enable : std_logic := '1'; --使能
	constant Disable : std_logic := '0'; --禁用
	constant Stop : std_logic :='1'; --流水线暂停
	constant NoStop : std_logic :='0'; --流水线运行
	
	--ALU指令码,实验指导书P23页的编号
	
	--
	constant EXE_ADDIU_OP : std_logic_vector(7 downto 0) := "00000010"; --2
	constant EXE_ADDIU3_OP : std_logic_vector(7 downto 0) := "00000011"; --3
	constant EXE_ADDSP3_OP : std_logic_vector(7 downto 0) := "00000100"; --4
	constant EXE_ADDSP_OP : std_logic_vector(7 downto 0) := "00000101"; --4
	constant EXE_ADDU_OP : std_logic_vector(7 downto 0) := "00000110"; --6
	constant EXE_AND_OP : std_logic_vector(7 downto 0) := "00000111"; --7
	constant EXE_CMP_OP : std_logic_vector(7 downto 0) := "00001101"; --13
	constant EXE_CMPI_OP : std_logic_vector(7 downto 0) := "00001110"; --14
	constant EXE_JALR_OP : std_logic_vector(7 downto 0) := "00010000"; -- 16
	constant EXE_LI_OP : std_logic_vector(7 downto 0) := "00010011"; --19
	constant EXE_LW : std_logic_vector(7 downto 0) := "00010100"; --20
	constant EXE_LW_SP : std_logic_vector(7 downto 0) := "00010101"; --21
	constant EXE_MOVE_OP : std_logic_vector(7 downto 0) := "00011000"; --24
	constant EXE_NEG_OP : std_logic_vector(7 downto 0) := "00011011"; --27
	constant EXE_NOT_OP : std_logic_vector(7 downto 0) := "00011100"; --28
	constant EXE_NOP_OP : std_logic_vector(7 downto 0) := "00011101"; --29
	constant EXE_OR_OP : std_logic_vector(7 downto 0) := "00011110"; --30
	constant EXE_SLL_OP : std_logic_vector(7 downto 0) := "00011111"; --31
	constant EXE_SLLV_OP : std_logic_vector(7 downto 0) := "00100000"; --32
	constant EXE_SRA_OP : std_logic_vector(7 downto 0) := "00100101"; --37
	constant EXE_SRAV_OP : std_logic_vector(7 downto 0) := "00100110"; --38
	constant EXE_SRL_OP : std_logic_vector(7 downto 0) := "00100111"; --39
	constant EXE_SRLV_OP : std_logic_vector(7 downto 0) := "00101000"; --40
	constant EXE_SUBU_OP : std_logic_vector(7 downto 0) := "00101001"; --41
	constant EXE_SW : std_logic_vector(7 downto 0) := "00101010"; --42
	constant EXE_XOR_OP : std_logic_vector(7 downto 0) := "00101101"; --45
	
	
	--ALU操作类型
	constant EXE_RES_NOP : std_logic_vector(2 downto 0) := "000";
	constant EXE_RES_LOGIC : std_logic_vector(2 downto 0) := "001";
	constant EXE_RES_LOAD_STORE : std_logic_vector(2 downto 0) := "100";
	
	--特殊寄存器地址
	constant SP_REGISTER : std_logic_vector(3 downto 0) := "1000"; --8号SP寄存器
	constant T_REGISTER : std_logic_vector(3 downto 0) := "1001"; --9号T寄存器
	constant RA_REGISTER : std_logic_vector(3 downto 0) := "1010"; --10号RA寄存器
	constant IH_REGISTER : std_logic_vector(3 downto 0) := "1011"; --11号IH寄存器
	
end defines;

package body defines is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
end defines;
