-- #################################################################################################
-- #  << NEO430 - Processor Top Entity >>                                                          #
-- # ********************************************************************************************* #
-- #  The NEO430 processor:                                                                        #
-- #   - Reset and clock generators                                                                #
-- #   - External IRQ synchronizer                                                                 #
-- #   - NEO430 CPU (MSP430(TM)-ISA-compatible)                                                    #
-- #   - Internal ROM (IMEM, configurable size) for code                                           #
-- #   - Internal RAM (DMEM, configurable size) for data (and code)                                #
-- #   - Optional 16bit IN and 16bit OUT parallel IO port                                          #
-- #   - Optional 32-bit Wishbone interface                                                        #
-- #   - Optional High precision timer                                                             #
-- #   - Optional USART - SPI and UART                                                             #
-- #   - Optional Internal ROM for bootloader                                                      #
-- #   - Optional Watchdog Timer                                                                   #
-- #   - Sysconfig (infomem for various system information & interrupt vector configuration )      #
-- # ********************************************************************************************* #
-- # This file is part of the NEO430 Processor project: http://opencores.org/project,neo430        #
-- # Copyright 2015-2017, Stephan Nolting: stnolting@gmail.com                                     #
-- #                                                                                               #
-- # This source file may be used and distributed without restriction provided that this copyright #
-- # statement is not removed from the file and that any derivative work contains the original     #
-- # copyright notice and the associated disclaimer.                                               #
-- #                                                                                               #
-- # This source file is free software; you can redistribute it and/or modify it under the terms   #
-- # of the GNU Lesser General Public License as published by the Free Software Foundation,        #
-- # either version 3 of the License, or (at your option) any later version.                       #
-- #                                                                                               #
-- # This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;      #
-- # without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     #
-- # See the GNU Lesser General Public License for more details.                                   #
-- #                                                                                               #
-- # You should have received a copy of the GNU Lesser General Public License along with this      #
-- # source; if not, download it from http://www.gnu.org/licenses/lgpl-3.0.en.html                 #
-- # ********************************************************************************************* #
-- #  Stephan Nolting, Hannover, Germany                                               08.02.2017  #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.neo430_package.all;

entity neo430_core is
  generic (
    USER_CODE : std_ulogic_vector(15 downto 0) := x"0000" -- custom user code
  );
  port (
    -- global control --
    clk_i      : in  std_ulogic; -- global clock, rising edge
    rst_i      : in  std_ulogic; -- global reset, async, LOW-active
    -- parallel io --
    pio_o      : out std_ulogic_vector(15 downto 0); -- parallel output
    pio_i      : in  std_ulogic_vector(15 downto 0); -- parallel input
    -- serial com --
    uart_txd_o : out std_ulogic; -- UART send data
    uart_rxd_i : in  std_ulogic; -- UART receive data
    spi_sclk_o : out std_ulogic; -- serial clock line
    spi_mosi_o : out std_ulogic; -- serial data line out
    spi_miso_i : in  std_ulogic; -- serial data line in
    spi_cs_o   : out std_ulogic_vector(05 downto 0); -- SPI CS 0..5
    -- 32-bit wishbone interface --
    wb_adr_o   : out std_ulogic_vector(31 downto 0); -- address
    wb_dat_i   : in  std_ulogic_vector(31 downto 0); -- read data
    wb_dat_o   : out std_ulogic_vector(31 downto 0); -- write data
    wb_we_o    : out std_ulogic; -- read/write
    wb_sel_o   : out std_ulogic_vector(03 downto 0); -- byte enable
    wb_stb_o   : out std_ulogic; -- strobe
    wb_cyc_o   : out std_ulogic; -- valid cycle
    wb_ack_i   : in  std_ulogic; -- transfer acknowledge
    -- external interrupt --
    irq_i      : in  std_ulogic  -- external interrupt request line
  );
end neo430_core;

architecture neo430_core_rtl of neo430_core is

  -- generators --
  signal rst_gen      : std_ulogic_vector(03 downto 0) := (others => '0'); -- perform reset on bitstream upload
  signal rst_gen_sync : std_ulogic_vector(01 downto 0);
  signal ext_rst      : std_ulogic;
  signal sys_rst      : std_ulogic;
  signal wdt_rst      : std_ulogic;
  signal clk_div      : std_ulogic_vector(11 downto 0);
  signal clk_gen      : std_ulogic_vector(07 downto 0);
  signal timer_cg_en  : std_ulogic;
  signal usart_cg_en  : std_ulogic;
  signal wdt_cg_en    : std_ulogic;

  type cpu_bus_t is record
    rd_en : std_ulogic;
    wr_en : std_ulogic_vector(01 downto 0);
    addr  : std_ulogic_vector(15 downto 0);
    rdata : std_ulogic_vector(15 downto 0);
    wdata : std_ulogic_vector(15 downto 0);
  end record;

  -- main cpu communication bus --
  signal cpu_bus  : cpu_bus_t;
  signal io_acc   : std_ulogic;
  signal io_wr_en : std_ulogic_vector(01 downto 0);
  signal io_rd_en : std_ulogic;

  -- read-back data busses --
  signal rom_rdata       : std_ulogic_vector(15 downto 0);
  signal ram_rdata       : std_ulogic_vector(15 downto 0);
  signal wb_rdata        : std_ulogic_vector(15 downto 0);
  signal boot_rdata      : std_ulogic_vector(15 downto 0);
  signal wdt_rdata       : std_ulogic_vector(15 downto 0);
  signal timer_rdata     : std_ulogic_vector(15 downto 0);
  signal usart_rdata     : std_ulogic_vector(15 downto 0);
  signal pio_rdata       : std_ulogic_vector(15 downto 0);
  signal sysconfig_rdata : std_ulogic_vector(15 downto 0);

  -- interrupt system --
  signal irq       : std_ulogic_vector(03 downto 0);
  signal timer_irq : std_ulogic;
  signal usart_irq : std_ulogic;
  signal pio_irq   : std_ulogic;
  signal xirq_sync : std_ulogic_vector(01 downto 0);

  -- misc --
  signal imem_up_en : std_ulogic;

begin

  -- Reset Generator ----------------------------------------------------------
  -- -----------------------------------------------------------------------------
  reset_generator: process(rst_i, clk_i)
  begin
    if (rst_i = '0') then
      rst_gen <= (others => '0');
    elsif rising_edge(clk_i) then
      rst_gen <= rst_gen(rst_gen'left-1 downto 0) & '1';
    end if;
  end process reset_generator;

  -- one extra sync ff to prevent weird glitches on the reset net
  -- and another one to avoid metastability
  reset_generator_sync_ff: process(clk_i)
  begin
    if rising_edge(clk_i) then
      rst_gen_sync <= rst_gen_sync(0) & rst_gen(rst_gen'left);
    end if;
  end process reset_generator_sync_ff;

  ext_rst <= rst_gen_sync(1);
  sys_rst <= ext_rst and wdt_rst;


  -- Clock Generator ----------------------------------------------------------
  -- -----------------------------------------------------------------------------
  clock_generator: process(sys_rst, clk_i)
  begin
    if (sys_rst = '0') then
      clk_div <= (others => '0');
    elsif rising_edge(clk_i) then
      if ((timer_cg_en or usart_cg_en or wdt_cg_en) = '1') then
        clk_div <= std_ulogic_vector(unsigned(clk_div) + 1);
      end if;
    end if;
  end process clock_generator;

  -- clock select --
  clk_gen(0) <= clk_div(0);  -- CLK/2
  clk_gen(1) <= clk_div(1);  -- CLK/4
  clk_gen(2) <= clk_div(2);  -- CLK/8
  clk_gen(3) <= clk_div(5);  -- CLK/64
  clk_gen(4) <= clk_div(6);  -- CLK/128
  clk_gen(5) <= clk_div(9);  -- CLK/1024
  clk_gen(6) <= clk_div(10); -- CLK/2048
  clk_gen(7) <= clk_div(11); -- CLK/4096


  -- CPU ----------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_cpu_inst: neo430_cpu
  port map (
    -- global control --
    clk_i      => clk_i,            -- global clock, rising edge
    rst_i      => sys_rst,          -- global reset, low-active, async
    -- memory interface --
    mem_rd_o   => cpu_bus.rd_en,    -- memory read
    mem_imwe_o => imem_up_en,       -- allow writing to IMEM
    mem_wr_o   => cpu_bus.wr_en,    -- memory write
    mem_addr_o => cpu_bus.addr,     -- address
    mem_data_o => cpu_bus.wdata,    -- write data
    mem_data_i => cpu_bus.rdata,    -- read data
    -- interrupt system --
    irq_i      => irq               -- interrupt request lines
  );

  -- final CPU read data --
  cpu_bus.rdata <= rom_rdata or ram_rdata or boot_rdata or wb_rdata or
                   usart_rdata or pio_rdata or timer_rdata or wdt_rdata or sysconfig_rdata;

  -- sync for external IRQ --
  external_irq_sync: process(clk_i)
  begin
    if rising_edge(clk_i) then
      xirq_sync <= xirq_sync(0) & irq_i;
    end if;
  end process external_irq_sync;

  -- interrupt priority assignment --
  irq(0) <= timer_irq;    -- timer match
  irq(1) <= usart_irq;    -- UART Rx available | UART Tx done | SPI RTX done
  irq(2) <= pio_irq;      -- PIO input pin change
  irq(3) <= xirq_sync(1); -- external interrupt request


  -- Main Memory (ROM & RAM) --------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_imem_inst: neo430_imem
  port map (
    clk_i  => clk_i,                -- global clock line
    rden_i => cpu_bus.rd_en,        -- read enable
    wren_i => cpu_bus.wr_en,        -- write enable
    upen_i => imem_up_en,           -- update enable
    addr_i => cpu_bus.addr,         -- address
    data_i => cpu_bus.wdata,        -- data in
    data_o => rom_rdata             -- data out
  );

  neo430_dmem_inst: neo430_dmem
  port map (
    clk_i  => clk_i,                -- global clock line
    rden_i => cpu_bus.rd_en,        -- read enable
    wren_i => cpu_bus.wr_en,        -- write enable
    addr_i => cpu_bus.addr,         -- address
    data_i => cpu_bus.wdata,        -- data in
    data_o => ram_rdata             -- data out
  );


  -- Boot ROM -----------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_boot_rom_inst_true:
  if (bootld_use_c = true) generate
    neo430_boot_rom_inst: neo430_boot_rom
    port map (
      clk_i  => clk_i,              -- global clock line
      rden_i => cpu_bus.rd_en,      -- read enable
      addr_i => cpu_bus.addr,       -- address
      data_o => boot_rdata          -- data out
    );
  end generate;

  neo430_boot_rom_inst_false:
  if (bootld_use_c = false) generate
    boot_rdata <= (others => '0');
  end generate;


  -- IO Access? ---------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  io_acc   <= '1' when (cpu_bus.addr(15 downto index_size(io_size_c)) = io_base_c(15 downto index_size(io_size_c))) else '0';
  io_rd_en <= cpu_bus.rd_en when (io_acc = '1') else '0';
  io_wr_en <= cpu_bus.wr_en when (io_acc = '1') else "00";


  -- Wishbone Adapter ---------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_wb32_if_inst_true:
  if (wb32_use_c = true) generate
    neo430_wb32_inst: neo430_wb_interface
    port map (
      -- host access --
      clk_i    => clk_i,            -- global clock line
      rden_i   => io_rd_en,         -- read enable
      wren_i   => io_wr_en,         -- write enable
      addr_i   => cpu_bus.addr,     -- address
      data_i   => cpu_bus.wdata,    -- data in
      data_o   => wb_rdata,         -- data out
      -- wishbone interface --
      wb_adr_o => wb_adr_o,         -- address
      wb_dat_i => wb_dat_i,         -- read data
      wb_dat_o => wb_dat_o,         -- write data
      wb_we_o  => wb_we_o,          -- read/write
      wb_sel_o => wb_sel_o,         -- byte enable
      wb_stb_o => wb_stb_o,         -- strobe
      wb_cyc_o => wb_cyc_o,         -- valid cycle
      wb_ack_i => wb_ack_i          -- transfer acknowledge
    );
  end generate;

  neo430_wb32_if_inst_false:
  if (wb32_use_c = false) generate
    wb_rdata <= (others => '0');
    wb_adr_o <= (others => '0');
    wb_dat_o <= (others => '0');
    wb_we_o  <= '0';
    wb_sel_o <= (others => '0');
    wb_stb_o <= '0';
    wb_cyc_o <= '0';
  end generate;


  -- USART --------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_usart_inst_true:
  if (usart_use_c = true) generate
    neo430_usart_inst: neo430_usart
    port map (
      -- host access --
      clk_i       => clk_i,         -- global clock line
      rden_i      => io_rd_en,      -- read enable
      wren_i      => io_wr_en,      -- write enable
      addr_i      => cpu_bus.addr,  -- address
      data_i      => cpu_bus.wdata, -- data in
      data_o      => usart_rdata,   -- data out
      -- clock generator --
      clkgen_en_o => usart_cg_en,   -- enable clock generator
      clkgen_i    => clk_gen,
      -- com lines --
      uart_txd_o  => uart_txd_o,
      uart_rxd_i  => uart_rxd_i,
      spi_sclk_o  => spi_sclk_o,    -- SPI serial clock
      spi_mosi_o  => spi_mosi_o,    -- SPI master out, slave in
      spi_miso_i  => spi_miso_i,    -- SPI master in, slave out
      spi_cs_o    => spi_cs_o,      -- SPI CS 0..5
      -- interrupts --
      usart_irq_o => usart_irq      -- spi transmission done / uart rx/tx interrupt
    );
  end generate;

  neo430_usart_inst_false:
  if (usart_use_c = false) generate
    usart_rdata <= (others => '0');
    usart_irq   <= '0';
    usart_cg_en <= '0';
    uart_txd_o  <= '1';
    spi_sclk_o  <= '0';
    spi_mosi_o  <= '0';
    spi_cs_o    <= (others => '0');
  end generate;


  -- Parallel IO --------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_parallel_io_inst_true:
  if (pio_use_c = true) generate
    neo430_parallel_io_inst: neo430_parallel_io
    port map (
      -- host access --
      clk_i  => clk_i,              -- global clock line
      rden_i => io_rd_en,           -- read enable
      wren_i => io_wr_en,           -- write enable
      addr_i => cpu_bus.addr,       -- address
      data_i => cpu_bus.wdata,      -- data in
      data_o => pio_rdata,          -- data out
      -- parallel io --
      pio_o  => pio_o,
      pio_i  => pio_i,
      -- interrupt --
      irq_o  => pio_irq             -- pin-cahnge interrupt
    );
  end generate;

  neo430_parallel_io_inst_false:
  if (pio_use_c = false) generate
    pio_rdata <= (others => '0');
    pio_o     <= (others => '0');
    pio_irq   <= '0';
  end generate;


  -- High Precision Timer -----------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_timer_inst_true:
  if (timer_use_c = true) generate
  neo430_timer_inst: neo430_timer
    port map (
      -- host access --
      clk_i       => clk_i,         -- global clock line
      rden_i      => io_rd_en,      -- read enable
      wren_i      => io_wr_en,      -- write enable
      addr_i      => cpu_bus.addr,  -- address
      data_i      => cpu_bus.wdata, -- data in
      data_o      => timer_rdata,   -- data out
      -- clock generator --
      clkgen_en_o => timer_cg_en,   -- enable clock generator
      clkgen_i    => clk_gen,
      -- interrupt --
      irq_o       => timer_irq      -- interrupt request
    );
  end generate;

  neo430_timer_inst_false:
  if (timer_use_c = false) generate
    timer_rdata <= (others => '0');
    timer_irq   <= '0';
    timer_cg_en <= '0';
  end generate;


  -- Watchdog Timer -----------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_wdt_inst_true:
  if (wdt_use_c = true) generate
    neo430_wdt_inst: neo430_wdt
    port map(
      -- host access --
      clk_i       => clk_i,         -- global clock line
      rst_i       => ext_rst,       -- external reset, low-active, use as async
      rden_i      => io_rd_en,      -- read enable
      wren_i      => io_wr_en,      -- write enable
      addr_i      => cpu_bus.addr,  -- address
      data_i      => cpu_bus.wdata, -- data in
      data_o      => wdt_rdata,     -- data out
      -- clock generator --
      clkgen_en_o => wdt_cg_en,     -- enable clock generator
      clkgen_i    => clk_gen,       -- clock generator
      -- system reset --
      rst_o       => wdt_rst        -- timeout reset, low-active, use as async
    );
  end generate;

  neo430_wdt_inst_false:
  if (wdt_use_c = false) generate
    wdt_rdata <= (others => '0');
    wdt_rst   <= '1';
    wdt_cg_en <= '0';
  end generate;


  -- System Configuration -----------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_sysconfig_inst: neo430_sysconfig
  generic map (
    USER_CODE => USER_CODE          -- custom user code
  )
  port map (
    clk_i  => clk_i,                -- global clock line
    rden_i => io_rd_en,             -- read enable
    wren_i => io_wr_en,             -- write enable
    addr_i => cpu_bus.addr,         -- address
    data_i => cpu_bus.wdata,        -- data in
    data_o => sysconfig_rdata       -- data out
  );


end neo430_core_rtl;