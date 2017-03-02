library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
library UNISIM;
use UNISIM.VComponents.all;
--some important ports and variables which should be used
Entity tutorial Is
port (
        BTNC : in std_logic;
        BTNR : in std_logic;
        jb : in std_logic_vector(3 downto 0); 
        clk : in std_logic;
		swt : in STD_LOGIC_VECTOR(15 downto 0);
		led : out STD_LOGIC_VECTOR(15 downto 0);
		AN  : out STD_LOGIC_VECTOR(7 downto 0);
		LED16_R :out std_logic;
		LED16_G :out std_logic;
		LED16_B :out std_logic;
		LED17_R :out std_logic;
        LED17_G :out std_logic;
        LED17_B :out std_logic;
		CA  : out STD_LOGIC;
		CB  : out STD_LOGIC;
		CC  : out STD_LOGIC;
		CD  : out STD_LOGIC;
		CE  : out STD_LOGIC;
		CF  : out STD_LOGIC;
		CG  : out STD_LOGIC;
		DP  : out STD_LOGIC		
	);
end tutorial;
Architecture behavior of tutorial Is
--some useful components
component ibuf_lvcmos33 port (i : in std_logic; o : out std_logic); end component;
-- CMOS33 clock input buffer primitive
component ibufg_lvcmos33 port(i : in std_logic; o : out std_logic); end component;
-- CMOS33 output buffer primitive
component obuf_lvcmos33 port(i : in std_logic; o : out std_logic); end component;
-- global buffer primitive
component bufg port(i : in std_logic; o : out std_logic); end component;
--some important ports and variables which should be used
signal segment:std_logic_vector(7 downto 0);
signal clk100int:std_logic;
signal clk100:std_logic;
signal pb:std_logic_vector(3 downto 0);
signal digit : std_logic_vector(3 downto 0) ;--
signal seg : std_logic_vector(7 downto 0) ;--
signal mhz_count: std_logic_vector(9 downto 0) ;--
signal khz_count: std_logic_vector(9 downto 0) ;--
signal hz_count: std_logic_vector(9 downto 0) ;--
signal mhz_en: std_logic ;--
signal khz_en: std_logic ;--
signal hz_en: std_logic ;--
Signal led_int : STD_LOGIC_VECTOR(15 downto 0);
signal m:std_logic_vector(2 downto 0);
signal temp:std_logic_vector(7 downto 0);
signal d: std_logic_vector(2 downto 0) ;
signal point: std_logic ;
signal p: std_logic ;
signal rst:std_logic;
signal m4cnt:std_logic_vector(1 downto 0);
signal unlock_flag:std_logic:='0';
signal judge :std_logic;
signal storage :std_logic_vector(15 downto 0):="0011100001100101";
signal count_status:std_logic:='0';
signal time:std_logic_vector(2 downto 0):="101";
signal editpw:std_logic:='0';
signal sw0:std_logic_vector(3 downto 0);
signal sw1:std_logic_vector(3 downto 0);
signal sw2:std_logic_vector(3 downto 0);
signal sw3:std_logic_vector(3 downto 0);
signal dis0:std_logic_vector(0 to 6);
signal dis1:std_logic_vector(0 to 6);
signal dis2:std_logic_vector(0 to 6);
signal dis3:std_logic_vector(0 to 6);
signal dis4:std_logic_vector(0 to 6);
shared variable a:integer :=6;
shared variable m5cntint:integer :=-1;
shared variable init:integer :=0;
begin
--the value of swt can be stored into 4 4-bit vectors to simplify the translate method
    sw0<=swt(15 downto 12);
    sw1<=swt(11 downto 8);
    sw2<=swt(7 downto 4);
    sw3<=swt(3 downto 0);
    rst<=pb(0);
    
    clk100in_buf:ibufg_lvcmos33 port map(i=>clk,o=>clk100int);
    rxclka_bufg:bufg port map(i=>clk100int,o=>clk100); 
    loop0 : for i in 0 to 3 generate
    segment_ibuf : obuf_lvcmos33 port map(i=>segment(i),o=>AN(i));
    segment_ibuf2 : obuf_lvcmos33 port map(i=>segment(i+4),o=>AN(i+4));
    pb_ibuf : ibuf_lvcmos33  port map(i => jb(i),o => pb(i));
    end generate ;
    loop2 : for i in 0 to 7 generate
    end generate;
    loop1: for i in 0 to 15 generate
    ledobuf: obuf_lvcmos33 port map(i=>led_int(i),o=>led(i));
    end generate;
--create the scrolling led light (used for testing)  
    process(clk100,rst)
        begin
            if rst='1' then 
            led_int(15 downto 0)<="0000000000000001";
            point<='0';
            point<=not point;
            elsif clk100'event and clk100='1' then 
            if hz_en='1' then 
            point<=not point;
            led_int(15 downto 0)<=led_int(14 downto 0)&led_int(15);
            end if;
            if d(1)='1' and d(0)='0' then
            p <= point ;
            else
            p <= '1' ;
            end if ;
            end if;
    end process;
--create the 1MHz clock            
    process(clk100,rst)
    begin
    if rst='1' then 
        mhz_count<=(others =>'0');
        mhz_en<='0';
    elsif clk100'event and clk100='1' then
        mhz_count<=mhz_count+1;
        if mhz_count(6)='1' and mhz_count(5)='1' and mhz_count(2)='1' then 
            mhz_en<='1';
            mhz_count<=(others=>'0');
        else
            mhz_en<='0';
        end if;
    end if;
    end process;
--create the 1KHz clock    
    process (clk100, rst)
    begin
    if rst = '1' then
    khz_count <= (others => '0') ;
    khz_en <= '0' ;
    elsif clk100'event and clk100 = '1' then
    if mhz_en = '1' then
    khz_count <= khz_count + 1 ;
    if khz_count(9)='1' and khz_count(8)='1' and khz_count(7)='1' and khz_count(6)='1' and khz_count(5)='1' and khz_count(3)='1' then
    khz_en <= '1' ;
    khz_count <= (others => '0') ;
    else
    khz_en <= '0' ;
    end if ;
    else
    khz_en <= '0' ;
    end if ;
    end if ;
    end process ;
--create the 1Hz clock
process (clk100, rst)
begin
if rst = '1' then
hz_count <= (others => '0') ;
hz_en <= '0' ;
elsif clk100'event and clk100 = '1' then
if khz_en = '1' then
hz_count <= hz_count + 1 ;
   if hz_count(9)='1' and hz_count(8)='1' and hz_count(7)='1' and hz_count(6)='1' and hz_count(5)='1' and hz_count(3)='1' then
hz_en <= '1' ;
hz_count <= (others => '0') ;
else
hz_en <= '0' ;
end if ;
else
hz_en <= '0' ;
end if ;
end if ;
end process ;
--write a table to simplify the translate method
process
begin
case sw0 is
when "0000"=> dis0(0 to 6)<="0000001";
when "0001"=> dis0(0 to 6)<="1001111";
when "0010"=> dis0(0 to 6)<="0010010";
when "0011"=> dis0(0 to 6)<="0000110";
when "0100"=> dis0(0 to 6)<="1001100";
when "0101"=> dis0(0 to 6)<="0100100";
when "0110"=> dis0(0 to 6)<="0100000";
when "0111"=> dis0(0 to 6)<="0001111";
when "1000"=> dis0(0 to 6)<="0000000";
when "1001"=> dis0(0 to 6)<="0000100";
when others=> dis0(0 to 6)<=(others=>'0');
end case;
case sw1 is
when "0000"=> dis1(0 to 6)<="0000001";
when "0001"=> dis1(0 to 6)<="1001111";
when "0010"=> dis1(0 to 6)<="0010010";
when "0011"=> dis1(0 to 6)<="0000110";
when "0100"=> dis1(0 to 6)<="1001100";
when "0101"=> dis1(0 to 6)<="0100100";
when "0110"=> dis1(0 to 6)<="0100000";
when "0111"=> dis1(0 to 6)<="0001111";
when "1000"=> dis1(0 to 6)<="0000000";
when "1001"=> dis1(0 to 6)<="0000100";
when others=> dis1(0 to 6)<=(others=>'0');
end case;
case sw2 is
when "0000"=> dis2(0 to 6)<="0000001";
when "0001"=> dis2(0 to 6)<="1001111";
when "0010"=> dis2(0 to 6)<="0010010";
when "0011"=> dis2(0 to 6)<="0000110";
when "0100"=> dis2(0 to 6)<="1001100";
when "0101"=> dis2(0 to 6)<="0100100";
when "0110"=> dis2(0 to 6)<="0100000";
when "0111"=> dis2(0 to 6)<="0001111";
when "1000"=> dis2(0 to 6)<="0000000";
when "1001"=> dis2(0 to 6)<="0000100";
when others=> dis2(0 to 6)<=(others=>'0');
end case;
case sw3 is
when "0000"=> dis3(0 to 6)<="0000001";
when "0001"=> dis3(0 to 6)<="1001111";
when "0010"=> dis3(0 to 6)<="0010010";
when "0011"=> dis3(0 to 6)<="0000110";
when "0100"=> dis3(0 to 6)<="1001100";
when "0101"=> dis3(0 to 6)<="0100100";
when "0110"=> dis3(0 to 6)<="0100000";
when "0111"=> dis3(0 to 6)<="0001111";
when "1000"=> dis3(0 to 6)<="0000000";
when "1001"=> dis3(0 to 6)<="0000100";
when others=> dis3(0 to 6)<=(others=>'0');
end case;
case a is
when 0=> dis4(0 to 6)<="0000001";
when 1=> dis4(0 to 6)<="1001111";
when 2=> dis4(0 to 6)<="0010010";
when 3=> dis4(0 to 6)<="0000110";
when 4=> dis4(0 to 6)<="1001100";
when 5=> dis4(0 to 6)<="0100100";
when 6=> dis4(0 to 6)<="1111111";
when others=> dis4(0 to 6)<=(others=>'1');
end case;--after 5 seconds , the 7-segment-display should display "Error"
if a=0 then
    dis4(0 to 6)<="0110000";
    dis0(0 to 6)<="1111010";
    dis1(0 to 6)<="1111010";
    dis2(0 to 6)<="1100010";
    dis3(0 to 6)<="1111010";
end if;
end process;
--add segment display
process(clk100,rst)
begin
if rst='1' then 
    m5cntint:=-1;
elsif clk100'event and clk100='1' then
if khz_en='1' then
    if m5cntint=0 then
        CA<=dis0(0);
        CB<=dis0(1);
        CC<=dis0(2);
        CD<=dis0(3);
        CE<=dis0(4);
        CF<=dis0(5);
        CG<=dis0(6);
        m5cntint:=1;
    elsif m5cntint=1 then
        CA<=dis1(0);
        CB<=dis1(1);
        CC<=dis1(2);
        CD<=dis1(3);
        CE<=dis1(4);
        CF<=dis1(5);
        CG<=dis1(6);
        m5cntint:=2;
    elsif m5cntint=2 then
        CA<=dis2(0);
        CB<=dis2(1);
        CC<=dis2(2);
        CD<=dis2(3);
        CE<=dis2(4);
        CF<=dis2(5);
        CG<=dis2(6);
        m5cntint:=3;
    elsif m5cntint=3 then
        CA<=dis3(0);
        CB<=dis3(1);
        CC<=dis3(2);
        CD<=dis3(3);
        CE<=dis3(4);
        CF<=dis3(5);
        CG<=dis3(6);
        m5cntint:=-1;
    elsif m5cntint=-1 then
        CA<=dis4(0);
        CB<=dis4(1);
        CC<=dis4(2);
        CD<=dis4(3);
        CE<=dis4(4);
        CF<=dis4(5);
        CG<=dis4(6);
        m5cntint:=0;
    end if;
end if;
end if;
end process;
--set the current 7-segment display
process(clk100,rst)
        begin
            if rst='1' then 
            segment(4 downto 0)<="11110";
            point<='0';
            point<=not point;
            elsif clk100'event and clk100='1' then 
            if khz_en='1' then 
            point<=not point;
            segment(4 downto 0)<=segment(0)&segment(4 downto 1);
            end if;
            if d(1)='1' and d(0)='0' then
            p <= point ;
            else
            p <= '1' ;
            end if ;
            end if;
    end process;
--judge the password
process(clk100,rst)
begin
if clk100'event and clk100='1' then
if khz_en='1' then
    judge<='0';
    for i in 0 to 15 loop
        if swt(i)/=storage(i) then
            judge<='1';
        end if;
    end loop;
    if judge='0' then 
        LED17_G<='1';
        LED17_R<='0';
        unlock_flag<='1';
    elsif judge/='0' then
        LED17_G<='0';
        LED17_R<='1';
        unlock_flag<='0';
    end if;
end if;
end if;
end process;    
--count 5 seconds if locked
 process(clk100,rst)
        begin
            if rst='1' then 
            elsif clk100'event and clk100='1' then
            if unlock_flag='1' then
                a:=6; 
            elsif hz_en='1' and a>0 then 
            a:=(a-1);
            end if;
            if (a=0 or BTNR='1')and unlock_flag='0' then
               LED16_R<='1';
            else
               LED16_R<='0';
            end if;
            end if ;
    end process;
--change the password if unlocked
process(clk100,rst)
begin
    if BTNR='1' then
    if unlock_flag='1'and editpw='0' then
        editpw<='1';
    elsif editpw='1' then
        storage(15 downto 12)<=sw0;
        storage(11 downto 8)<=sw1;
        storage(7 downto 4)<=sw2;
        storage(3 downto 0)<=sw3;
        editpw<='0';
    end if;
    end if;
    if BTNR='0' and editpw='1' then
        editpw<='0';
    end if;
end process;
end behavior;