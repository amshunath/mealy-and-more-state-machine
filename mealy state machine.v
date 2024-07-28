module state_machine_mealy(clk, reset, in, out);
parameter zero=0, one1=1, two1s=2;
output out; input clk, reset, in;
reg out; reg [1:0] state, next_state;
// Implement the state register
always @(posedge clk or posedge reset) begin
 if (reset)
 state <= zero;
 else
 state <= next_state;
 end
always @(state or in) begin
 case (state)
 zero: begin //last input was a zero out = 0;
 if (in)
 next_state=one1;
 else
 next_state=zero;
 end
 one1: begin //we've seen one 1 out = 0;
 if (in)
 next_state=two1s;
 else
 next_state=zero;
 end
 two1s: begin //we've seen at least 2 ones out = 1;
 if (in) 
 next_state=two1s;
 else
 next_state=zero;
 end
 default: //in case we reach a bad state out = 0;
 next_state=zero;
 endcase
end
// output logic
always @(state) begin
 case (state)
 zero: out <= 0;
 one1: out <= 0;
 two1s: out <= 1;
 default : out <= 0;
 endcase
end
endmodule

//////////////////////////////////////////////////////////////////////
module state_machine_mealy_tb();

reg clk, reset, in;
wire out;
integer i;

state_machine_mealy dut (
    .clk(clk),
    .reset(reset),
    .in(in),
    .out(out)
);

// Generate clock with a period of 10 time units
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Initial block to apply test vectors
initial begin
    // Initial reset
    reset = 1;
    in = 0;
    #10;
    reset = 0;

    // Apply a sequence of inputs to test the state machine
    // Test case 1: No sequence detected
    in = 0; #10;
    in = 0; #10;
    in = 1; #10;
    in = 0; #10;
    in = 1; #10;
    in = 0; #10;

    // Test case 2: Sequence detected at the beginning
    in = 1; #10;
    in = 1; #10;
    in = 0; #10;
    in = 0; #10;

    // Test case 3: Sequence detected in the middle
    in = 1; #10;
    in = 0; #10;
    in = 1; #10;
    in = 1; #10;
    in = 0; #10;

    // Test case 4: Continuous sequence detection
    in = 1; #10;
    in = 1; #10;
    in = 1; #10;
    in = 0; #10;

    // Test case 5: Random sequence
    for (i = 0; i < 10; i = i + 1) begin
        in = $random % 2;
        #10;
    end

    // End the simulation
    $finish;
end

// Monitor changes
initial begin
    $monitor("Time: %0d, clk: %b, reset: %b, in: %b, out: %b", $time, clk, reset, in, out);
end

endmodule
