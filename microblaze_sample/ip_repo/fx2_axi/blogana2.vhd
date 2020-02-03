--------------------------------------------------------------------------------
--     BlockRAM Logic Analyzer Version 1.5 (fot Artix-7)
--     (C) Copyright 2005 Nahitech Inc. All rights reserved.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity blogana2 is
  generic(
    BIT_WIDTH     : integer := 72; --�T���v�����O����M����BIT�����w��i1bit�ȏ�A252bit�ȉ��őI���j
    SAMPLE_LENGTH : integer := 1024--�T���v�����O�̒���(word)���w��i1word�ȏ�A8192word�ʉ��őI���j
    );
  Port (	CLK         : in std_logic;
			TRIG        : in std_logic;
			USER_OP     : out std_logic_vector(19 downto 0);
			SAMPLE_EN   : in std_logic;
			DIN         : in std_logic_vector(255 downto 0); --BIT����generic��BIT_WIDTH�Ŏw��
			SAMP_FREQ   : in integer range 0 to 2147483647; -- �T���v�����O���g��
			BUSY        : out std_logic                     -- �K���ǂ����ɏo�͂��邱��
            );
end blogana2;

architecture Behavioral of blogana2 is
  constant COLUMN_NUM    : integer := (SAMPLE_LENGTH - 1) / 1024 + 1; --BRAM array�̗񐔂̌v�Z(1~8)
  constant ROW_NUM       : integer := (BIT_WIDTH - 1) / 36 + 1; --BRAM array�̍s���̌v�Z(1~7)

  signal BSREG    : std_logic_vector(35 downto 0);
  signal CAPTURE  : std_logic;
  signal DRCK     : std_logic;
  signal DRCKR    : std_logic;
  signal SEL      : std_logic;
  signal SHIFT    : std_logic;
  signal TDI      : std_logic;
  signal TDO      : std_logic;
  signal UPDATE   : std_logic;
  signal UPDATED  : std_logic;
  signal UPDATED2 : std_logic;

  signal MES_MODE : std_logic_vector(1 downto 0);
  signal WEA      : std_logic_vector(COLUMN_NUM-1 downto 0);

  signal RMODE    : std_logic_vector(1 downto 0);
  -- 00 �X�e�[�^�X
  -- 01 ���g��
  -- 10 �f�[�^

  type   bram_array is array(COLUMN_NUM-1 downto 0) of std_logic_vector(36*ROW_NUM-1 downto 0);
  
  signal COMMAND       : std_logic_vector(31 downto 0);
  signal STATUS_WORD   : std_logic_vector(31 downto 0);
  signal DATA_WORD     : std_logic_vector(35 downto 0);
  signal DIN_EX        : std_logic_vector(36*ROW_NUM-1 downto 0); --DIN��36bit�P�ʂ̕��ɕϊ����Ċi�[
  signal DIO_18B       : bram_array;
  signal WADDR         : std_logic_vector( 9 downto 0); -- MAX=1023
  signal RADDR         : std_logic_vector( 9 downto 0); -- MAX=1023
  signal COUNT         : std_logic_vector(13 downto 0); -- MAX=16383
  signal DATA_LENGTH   : std_logic_vector(13 downto 0); -- MAX=16383
  signal DATA_WIDTH    : integer range 0 to 255; --���ۂ̍ő�l��252
  signal COLUMN_POINT_R: integer range 0 to 7; --BRAM�̗���w��i�ǂݏo�����j
  signal COLUMN_POINT_W: integer range 0 to 7; --BRAM�̗���w��i�������ݎ��j
  signal ROW_POINT     : integer range 0 to 6; --BRAM�̍s���w��

  constant MAX_WADDR   : integer := 1023;
  constant MAX_RADDR   : integer := 1023;

  signal TRIG_MODE  : std_logic_vector(1 downto 0);
  signal ADDR_A     : std_logic_vector(9 downto 0);
  signal ADDR_B     : std_logic_vector(9 downto 0);
  signal DATA_A     : std_logic_vector(36*ROW_NUM-1 downto 0);
  signal nRESET     : std_logic;

  component RAMB16_S18_S18
    generic (
      WRITE_MODE_A : string     := "WRITE_FIRST";
      WRITE_MODE_B : string     := "WRITE_FIRST";
      INIT_A       : bit_vector := X"00000";
      SRVAL_A      : bit_vector := X"00000";

      INIT_B       : bit_vector := X"00000";
      SRVAL_B      : bit_vector := X"00000";

      INITP_00     : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_01     : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_02     : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_03     : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_00      : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_01      : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_02      : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_03      : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );
    port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
          DIB    : in STD_LOGIC_VECTOR (15 downto 0);
          DIPA   : in STD_LOGIC_VECTOR (1 downto 0);
          DIPB   : in STD_LOGIC_VECTOR (1 downto 0);
          ENA    : in STD_logic;
          ENB    : in STD_logic;
          WEA    : in STD_logic;
          WEB    : in STD_logic;
          SSRA   : in STD_logic;
          SSRB   : in STD_logic;
          CLKA   : in STD_logic;
          CLKB   : in STD_logic;
          ADDRA  : in STD_LOGIC_VECTOR (9 downto 0);
          ADDRB  : in STD_LOGIC_VECTOR (9 downto 0);
          DOA    : out STD_LOGIC_VECTOR (15 downto 0);
          DOB    : out STD_LOGIC_VECTOR (15 downto 0);
          DOPA   : out STD_LOGIC_VECTOR (1 downto 0);
          DOPB   : out STD_LOGIC_VECTOR (1 downto 0)); 
  end component;

begin

------------------------------------------------------------------------------------------
-- BSCAN�}�N���̎g�p
------------------------------------------------------------------------------------------

  BSCANE2_inst : BSCANE2
    generic map (
      JTAG_CHAIN => 1  -- Value for USER command.
      )
    port map (
      CAPTURE => CAPTURE, -- 1-bit output: CAPTURE output from TAP controller.
      DRCK    => DRCKR,   -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
      -- SHIFT are asserted.

      RESET   => open,    -- 1-bit output: Reset output for TAP controller.
      RUNTEST => open,    -- 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
      SEL     => SEL,     -- 1-bit output: USER instruction active output.
      SHIFT   => SHIFT,   -- 1-bit output: SHIFT output from TAP controller.
      TCK     => open,    -- 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
      TDI     => TDI,     -- 1-bit output: Test Data Input (TDI) output from TAP controller.
      TMS     => open,    -- 1-bit output: Test Mode Select output. Fabric connection to TAP.
      UPDATE  => UPDATE,  -- 1-bit output: UPDATE output from TAP controller
      TDO     => TDO      -- 1-bit input : Test Data Output (TDO) input for USER function.
      );

  --bram16�ȉ��̏ꍇ�ABUFR
  SELECT_BUFR : if (ROW_NUM * COLUMN_NUM * 2  <= 16) generate
    inst_bufr : bufr port map (
      clr => '0',
      ce  => '1',
      i   => DRCKR,
      o   => DRCK
      );
  end generate;

  --bram17�ȏ�̏ꍇ�ABUFG (�����̈�ɂ܂�����z�u���\�ɂ��邽�߁j
  SELECT_BOFG : if (ROW_NUM * COLUMN_NUM * 2  > 16) generate   
    inst_bufg : bufg port map(
      i => DRCKR,
      o => DRCK
      );
  end generate;

  process(DRCK)
  begin
    if(DRCK'event and DRCK = '1') then
      if(SEL = '1') then
        if(CAPTURE = '1') then
          case RMODE is
            when "00" =>
              BSREG <= "1100" & STATUS_WORD;
              RADDR <= WADDR; --�T���v�����O�J�n�n�_��waddr���R�s�[
              COLUMN_POINT_R <= COLUMN_POINT_W; --�T���v�����O�J�n�n�_��COLUMN_POINT_W���R�s�[
              ROW_POINT <= 0;
            when "01" =>
              BSREG <= "1101" & conv_std_logic_vector(SAMP_FREQ,32);
            when "10" =>
              BSREG <= DATA_WORD;
              if (ROW_POINT = ROW_NUM - 1) then --ROW_POINT���ő�l�ɒB������ARADDR���C���N�������g
                ROW_POINT <= 0;
                if (RADDR = conv_std_logic_vector(MAX_RADDR, 10)) then 
                  RADDR <= (others => '0');
                  if (COLUMN_POINT_R = COLUMN_NUM-1) then --RADDR���ő�l�ɒB����x�ACOLUMN_POINT_R���C���N�������g
                    COLUMN_POINT_R <= 0;
                  else 
                    COLUMN_POINT_R <= COLUMN_POINT_R + 1;
                  end if;
                else 
                  RADDR <= RADDR + 1;
                end if;
              else
                ROW_POINT <= ROW_POINT + 1;
              end if;
            when others =>
              BSREG <= (others => '1');
          end case;
        else
          BSREG <= TDI & BSREG(35 downto 1);
        end if;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if(CLK'event and CLK = '1') then
      UPDATED  <= UPDATE and SEL;
      UPDATED2 <= UPDATED;

      if((UPDATED2 = '0') and (UPDATED = '1')) then
        COMMAND <= BSREG(31 downto 0);
      end if;
    end if;
  end process;
  TDO <= BSREG(0);
  BUSY <= '1' when(MES_MODE /= "00") else '0';

------------------------------------------------------------------------------------------
-- BLOGANA�����H
------------------------------------------------------------------------------------------

  DATA_LENGTH   <= conv_std_logic_vector(COLUMN_NUM * 1024, 14); -- <= 1024 ~ 8192
  DATA_WIDTH    <= ROW_NUM * 36; -- <= 36 ~ 252

  STATUS_WORD(31 downto 30) <= MES_MODE;
  STATUS_WORD(29 downto 22) <= conv_std_logic_vector(DATA_WIDTH,8); --max255
  STATUS_WORD(21 downto 16) <= DATA_LENGTH(12 downto 7); -- ��128
  STATUS_WORD(15 downto 0)  <= "000000" & WADDR;

  RMODE     <= COMMAND(31 downto 30);
  TRIG_MODE <= COMMAND(3 downto 2);
  nRESET    <= '1';--COMMAND(4);
  USER_OP   <= COMMAND(27 downto 8);

  process(CLK)
  begin
    if(CLK'event and CLK = '1') then
      if(MES_MODE = "01") then
        case TRIG_MODE is
          when "00" => -- 6%
            COUNT <= "0000" & DATA_LENGTH(13 downto 4); -- ��16
          when "01"  => -- 25%
            COUNT <= "00" & DATA_LENGTH(13 downto 2); -- ��4
          when "10"  => -- 50%
            COUNT <= '0' & DATA_LENGTH(13 downto 1); -- ��2
          when others  => -- 100%
            COUNT <= DATA_LENGTH - ("0000" & DATA_LENGTH(13 downto 4)); -- ��16�~15
        end case;
      else
        if(SAMPLE_EN = '1') then
          COUNT <= COUNT + 1;
        end if;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if(CLK'event and CLK = '1') then
      case MES_MODE is
        when "00" => -- IDLE STATE
          if (WADDR = conv_std_logic_vector(MAX_WADDR, 10)) then --WADDR���ő�l�ɒB������ACOLUMN_POINT_W���C���N�������g
            WADDR <= (others => '0');
            if (COLUMN_POINT_W = COLUMN_NUM - 1) then
              COLUMN_POINT_W <= 0;
            else
              COLUMN_POINT_W <= COLUMN_POINT_W + 1;
            end if;
          else
            WADDR <= WADDR + 1;
          end if;
          if(COMMAND(0) = '1') then -- start !
            MES_MODE <= "01";
          end if;

        when "01" => -- Wait Trigger
          if(SAMPLE_EN = '1') then
            if (WADDR = conv_std_logic_vector(MAX_WADDR, 10)) then --WADDR���ő�l�ɒB������ACOLUMN_POINT_W���C���N�������g
              WADDR <= (others => '0');
              if (COLUMN_POINT_W = COLUMN_NUM - 1) then
                COLUMN_POINT_W <= 0;
              else
                COLUMN_POINT_W <= COLUMN_POINT_W + 1;
              end if;
            else
              WADDR <= WADDR + 1;
            end if;
          end if;
          if((TRIG = '1') or (COMMAND(1) = '1')) then
            MES_MODE <= "11";
          end if;
          
        when "11" => -- Run
          if(SAMPLE_EN = '1') then
            if (WADDR = conv_std_logic_vector(MAX_WADDR, 10)) then --WADDR���ő�l�ɒB������ACOLUMN_POINT_W���C���N�������g
              WADDR <= (others => '0');
              if (COLUMN_POINT_W = COLUMN_NUM - 1) then
                COLUMN_POINT_W <= 0;
              else
                COLUMN_POINT_W <= COLUMN_POINT_W + 1;
              end if;
            else
              WADDR <= WADDR + 1;
            end if;
          end if;
          if(COUNT = DATA_LENGTH - 2) then
            MES_MODE <= "10";
          end if;
          
        when others =>
          if(COMMAND(0) = '0') then -- end
            MES_MODE <= "00";
          end if;
      end case;
    end if;
  end process;

  --COLUMN_POINT_W�̎w�����WEA��high�ɂ���
  process (WEA, MES_MODE, COLUMN_POINT_W)
  begin
    loop_wea : for I in 0 to COLUMN_NUM-1 loop
      if (I = COLUMN_POINT_W) then
        if (MES_MODE = "10") then
          WEA(I) <= '0';
        else
          WEA(I) <= '1';
        end if;
      else
        WEA(I) <= '0';
      end if;
    end loop;
  end process;

------------------------------------------------------------------------------------------
-- ������
------------------------------------------------------------------------------------------

  process(CLK)
  begin
    if(CLK'event and CLK = '1') then
		DIN_EX <= DIN(36*ROW_NUM-1 downto 0);
	end if;
  end process;
--  DIN_EX <= conv_std_logic_vector(0, 36*ROW_NUM-BIT_WIDTH) & DIN; --DIN��36bit�P�ʂɊg��
  
  process (DIN_EX,DIO_18B,WADDR,RADDR,ROW_POINT,COLUMN_POINT_R)
  begin
    ADDR_A    <= WADDR;
    ADDR_B    <= RADDR;
    DATA_A    <= DIN_EX;
    DATA_WORD <= DIO_18B(COLUMN_POINT_R)(36*(ROW_POINT+1)-1 downto 36*ROW_POINT);
                             --COLUMN_POINT, ROW_POINT�ɂ��ƂÂ��A�o�͂���f�[�^��؂�ւ�
  end process;

  --�������̐����i�ő�112��<252bit * 8192word>, 1�u���b�N������18bit * 1024word * 2�j
  BRAM_ROW : for J in 0 to ROW_NUM-1 generate
    BRAM_COLUMN : for I in 0 to COLUMN_NUM-1 generate
      BRAM_18B_ODD : RAMB16_S18_S18 port map (
        DIA   => DATA_A(36*(J+1)-21 downto 36*J),
        DIPA  => DATA_A(36*(J+1)-19 downto 36*(J+1)-20),
        ENA   => nRESET,
        WEA   => WEA(I),
        SSRA  => '0',
        CLKA  => CLK,
        ADDRA => ADDR_A,
        DOA   => open,
        DOPA  => open,
        
        DIB   => (others => '0'),
        DIPB  => (others => '0'),
        ENB   => nRESET,
        WEB   => '0',
        SSRB  => '0',
        CLKB  => DRCK,
        ADDRB => ADDR_B,
        DOB   => DIO_18B(I)(36*(J+1)-21 downto 36*J),
        DOPB  => DIO_18B(I)(36*(J+1)-19 downto 36*(J+1)-20)
        );

      BRAM_18B_EVEN : RAMB16_S18_S18 port map (
        DIA   => DATA_A(36*(J+1)-3 downto 36*J+18),
        DIPA  => DATA_A(36*(J+1)-1 downto 36*(J+1)-2),
        ENA   => nRESET,
        WEA   => WEA(I),
        SSRA  => '0',
        CLKA  => CLK,
        ADDRA => ADDR_A,
        DOA   => open,
        DOPA  => open,
        
        DIB   => (others => '0'),
        DIPB  => (others => '0'),
        ENB   => nRESET,
        WEB   => '0',
        SSRB  => '0',
        CLKB  => DRCK,
        ADDRB => ADDR_B,
        DOB   => DIO_18B(I)(36*(J+1)-3 downto 36*J+18),
        DOPB  => DIO_18B(I)(36*(J+1)-1 downto 36*(J+1)-2)
        );
    end generate;
  end generate;

end Behavioral;
