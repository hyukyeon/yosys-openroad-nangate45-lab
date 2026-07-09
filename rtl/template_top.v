module template_top (
  input  wire       clk,
  input  wire       rst_n,
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] y
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y <= 8'h00;
    end else begin
      y <= a + b;
    end
  end

endmodule
