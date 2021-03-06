// ***************************************************************************
// ***************************************************************************
// Copyright 2011(c) Analog Devices, Inc.
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//    
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
// RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module util_rfifo (

  rstn,
  clk,

  m_rd,
  m_rdata,
  m_runf,
  s_rd,
  s_rdata,
  s_runf,

  fifo_rst,
  fifo_wr,
  fifo_wdata,
  fifo_wfull,
  fifo_rd,
  fifo_rdata,
  fifo_rempty,
  fifo_runf);

  // parameters (S) bus width must be greater than (M)

  parameter M_DATA_WIDTH = 32;
  parameter S_DATA_WIDTH = 64;
  parameter READ_SELECT = 1;
 
  // common clock

  input                           rstn;
  input                           clk;

  // master/slave write 

  input                           m_rd;
  output  [M_DATA_WIDTH-1:0]      m_rdata;
  output                          m_runf;
  output                          s_rd;
  input   [S_DATA_WIDTH-1:0]      s_rdata;
  input                           s_runf;

  // fifo interface

  output                          fifo_rst;
  output                          fifo_wr;
  output  [S_DATA_WIDTH-1:0]      fifo_wdata;
  input                           fifo_wfull;
  output                          fifo_rd;
  input   [M_DATA_WIDTH-1:0]      fifo_rdata;
  input                           fifo_rempty;
  input                           fifo_runf;

  // internal registers

  reg                             fifo_rst = 'd0;
  reg     [READ_SELECT-1:0]       s_rd_cnt = 'd0;
  reg                             m_runf = 'd0;

  // defaults

  always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
      fifo_rst <= 1'b1;
    end else begin
      fifo_rst <= 1'b0;
    end
  end

  // write depends on bus width change

  assign s_rd = s_rd_cnt[READ_SELECT-1];
  assign fifo_wr = s_rd_cnt[READ_SELECT-1];

  genvar s;
  generate
  for (s = 0; s < S_DATA_WIDTH; s = s + 1) begin: g_wdata
  assign fifo_wdata[s] = s_rdata[(S_DATA_WIDTH-1)-s];
  end
  endgenerate

  always @(posedge clk) begin
    if (m_rd == 1'b1) begin
      s_rd_cnt <= s_rd_cnt + 1'b1;
    end
  end

  // read is non-destructive

  assign fifo_rd = m_rd;

  always @(posedge clk) begin
    m_runf <= s_runf | fifo_wfull | fifo_runf | fifo_rempty;
  end
  
  genvar m;
  generate
  for (m = 0; m < M_DATA_WIDTH; m = m + 1) begin: g_rdata
  assign m_rdata[m] = fifo_rdata[(M_DATA_WIDTH-1)-m];
  end
  endgenerate

endmodule

// ***************************************************************************
// ***************************************************************************
