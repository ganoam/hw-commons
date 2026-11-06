module stream_reg #(
  parameter  int unsigned DataWidth = 32
) (
  input logic clk_i,
  input logic rst_ni,

  input logic in_valid_i,
  output logic in_ready_o,
  input logic [DataWidth-1:0]  in_data_i,

  output logic out_valid_o,
  input logic out_ready_i,
  output logic [DataWidth-1:0]  out_data_o
);

  `include "prim_assert.sv"

  // --- Data types ---
  typedef struct packed{
    logic [DataWidth-1:0]  in_data;
    logic [DataWidth-1:0]  out_data;
  } mem_t;

  typedef struct packed{
    logic in_data_valid;
    logic out_data_valid;
  } reg_t;

  // --- Internal Signals ---
  reg_t reg_d, reg_q;
  mem_t mem_d, mem_q;


  // --- Combinational logic ---
  always_comb begin
    // default: hold state
    reg_d = reg_q;
    mem_d = mem_q;


    unique case({reg_q.in_data_valid, reg_q.out_data_valid})
      2'b00: begin

        mem_d.out_data = in_data_i;

        if (in_valid_i == 1'b1) begin
          reg_d.out_data_valid = 1'b1;
        end

      end

      2'b01: begin

        unique case({in_valid_i, out_ready_i})
          2'b00: ; // nothing
          2'b10: begin
            mem_d.in_data = in_data_i;
            reg_d.in_data_valid = 1'b1;
          end
          2'b11: begin
            mem_d.out_data = in_data_i;
          end
          2'b01: begin
            reg_d.out_data_valid = 1'b0;
          end
        endcase
      end


      2'b11: begin
        if (out_ready_i == 1'b1) begin
          // move buffer register to output; block input.
          mem_d.out_data = mem_q.in_data;
          reg_d.in_data_valid = 1'b0;
        end

      end

      2'b10: $fatal(1, "Should be unreachable!"); // unreachable
      default: ; // handled above.
    endcase
  end


  // --- Output assignments ---
  assign in_ready_o  = ~reg_q.in_data_valid;
  assign out_valid_o = reg_q.out_data_valid;
  assign out_data_o  = mem_q.out_data;


  // --- Flops ---
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      reg_q <= '0;
    end else begin
      reg_q <= reg_d;
    end
  end

  always_ff @(posedge clk_i) begin
    mem_q <= mem_d;
  end

  `ASSERT_KNOWN(OutValidKnown_A, out_valid_o)
  `ASSERT_KNOWN_IF(OutDataKnown_A, out_data_o, out_valid_o)
  `ASSERT(OutValidStable_A, out_valid_o  && !out_ready_i |=> out_valid_o)
  `ASSERT(OutDataStable_A, out_valid_o && !out_ready_i |=> $stable(out_data_o))

endmodule
