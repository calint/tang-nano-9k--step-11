`timescale 100ps / 100ps
//
// RAMIO + BurstRAM
//
`default_nettype none

module TestBench;
  reg sys_rst_n = 0;
  reg clk = 1;
  localparam clk_tk = 36;
  always #(clk_tk / 2) clk = ~clk;

  localparam RAM_DEPTH_BITWIDTH = 9;  // 2^9 * 8 B = 4096 B

  wire [5:0] led;
  wire uart_tx;
  reg uart_rx;

  //------------------------------------------------------------------------
  wire br_cmd;
  wire br_cmd_en;
  wire [RAM_DEPTH_BITWIDTH-1:0] br_addr;
  wire [63:0] br_wr_data;
  wire [7:0] br_data_mask;
  wire [63:0] br_rd_data;
  wire br_rd_data_valid;
  wire br_init_calib;
  wire br_busy;

  BurstRAM #(
      .DATA_FILE(""),  // initial RAM content
      .DEPTH_BITWIDTH(RAM_DEPTH_BITWIDTH),  // 2 ^ x * 8 B entries
      .BURST_COUNT(4),  // 4 * 64 bit data per burst
      .CYCLES_BEFORE_DATA_VALID(6),
      .CYCLES_BEFORE_INITIATED(0)
  ) burst_ram (
      .clk(clk),
      .rst_n(sys_rst_n),
      .cmd(br_cmd),  // 0: read, 1: write
      .cmd_en(br_cmd_en),  // 1: cmd and addr is valid
      .addr(br_addr),  // 8 bytes word
      .wr_data(br_wr_data),  // data to write
      .data_mask(br_data_mask),  // not implemented (same as 0 in IP component)
      .rd_data(br_rd_data),  // read data
      .rd_data_valid(br_rd_data_valid),  // rd_data is valid
      .init_calib(br_init_calib),
      .busy(br_busy)
  );
  //------------------------------------------------------------------------
  wire ramio_enable;
  wire [1:0] ramio_write_type;
  wire [2:0] ramio_read_type;
  wire [31:0] ramio_address;
  wire [31:0] ramio_data_out;
  wire ramio_data_out_ready;
  wire [31:0] ramio_data_in;
  wire ramio_busy;

  RAMIO #(
      .RAM_DEPTH_BITWIDTH(RAM_DEPTH_BITWIDTH),
      .RAM_ADDRESSING_MODE(3),  // 64 bit word RAM
      .CACHE_LINE_IX_BITWIDTH(1),
      .CLK_FREQ(20_250_000),
      .BAUD_RATE(20_250_000)
  ) ramio (
      .rst_n(sys_rst_n && br_init_calib),
      .clk(clk),
      .enable(ramio_enable),
      .write_type(ramio_write_type),
      .read_type(ramio_read_type),
      .address(ramio_address),
      .data_in(ramio_data_in),
      .data_out(ramio_data_out),
      .data_out_ready(ramio_data_out_ready),
      .busy(ramio_busy),
      .led(led[3:0]),
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),

      // burst RAM wiring; prefix 'br_'
      .br_cmd(br_cmd),  // 0: read, 1: write
      .br_cmd_en(br_cmd_en),  // 1: cmd and addr is valid
      .br_addr(br_addr),  // see 'RAM_ADDRESSING_MODE'
      .br_wr_data(br_wr_data),  // data to write
      .br_data_mask(br_data_mask),  // always 0 meaning write all bytes
      .br_rd_data(br_rd_data),  // data out
      .br_rd_data_valid(br_rd_data_valid)  // rd_data is valid
  );
  //------------------------------------------------------------------------
  output reg flash_clk;
  input wire flash_miso;
  output reg flash_mosi;
  output reg flash_cs;

  Flash #(
      .DATA_FILE("RAM.mem"),
      .DEPTH_BITWIDTH(12)  // in bytes 2^12 = 4096 B
  ) dut (
      .rst_n(sys_rst_n),
      .clk(flash_clk),
      .miso(flash_miso),
      .mosi(flash_mosi),
      .cs(flash_cs)
  );
  //------------------------------------------------------------------------
  Core #(
      .STARTUP_WAIT(0),
      .FLASH_TRANSFER_BYTES_NUM(4096)
  ) core (
      .rst_n(sys_rst_n && br_init_calib),
      .clk  (clk),
      .led  (led[4]),

      .ramio_enable(ramio_enable),
      .ramio_write_type(ramio_write_type),
      .ramio_read_type(ramio_read_type),
      .ramio_address(ramio_address),
      .ramio_data_in(ramio_data_in),
      .ramio_data_out(ramio_data_out),
      .ramio_data_out_ready(ramio_data_out_ready),
      .ramio_busy(ramio_busy),

      .flash_clk (flash_clk),
      .flash_miso(flash_miso),
      .flash_mosi(flash_mosi),
      .flash_cs  (flash_cs)
  );
  //------------------------------------------------------------------------
  assign led[5] = ~ramio_busy;
  //------------------------------------------------------------------------
  initial begin
    $dumpfile("log.vcd");
    $dumpvars(0, TestBench);

    #clk_tk;
    #clk_tk;
    sys_rst_n <= 1;
    #clk_tk;

    // wait for burst RAM to initiate
    while (br_busy) #clk_tk;

    while (core.state != core.STATE_DONE) #clk_tk;

    if (led[4] == 0) $display("Test 1 passed");
    else $display("Test 1 FAILED");

    $finish;

  end

endmodule

`default_nettype wire
