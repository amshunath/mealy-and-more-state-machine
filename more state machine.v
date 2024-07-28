module state_machine_moore(clk, reset, in, out);
    parameter zero=0, one1=1, two1s=2;
    output out;
    input clk, reset, in;
    
    reg out;
    reg [1:0] state, next_state;
    
    // Implement the state register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= zero;
        else
            state <= next_state;
    end
    
    // Next state logic
    always @(state or in) begin
        case (state)
            zero: begin // Last input was a zero
                if (in)
                    next_state = one1;
                else
                    next_state = zero;
            end
            one1: begin // We've seen one 1
                if (in)
                    next_state = two1s;
                else
                    next_state = zero;
            end
            two1s: begin // We've seen at least 2 ones
                if (in)
                    next_state = two1s;
                else
                    next_state = zero;
            end
            default: // In case we reach a bad state
                next_state = zero;
        endcase
    end
    
    // Output logic
    always @(state) begin
        case (state)
            zero: out <= 0;
            one1: out <= 0;
            two1s: out <= 1;
            default: out <= 0;
        endcase
    end
endmodule


////tb//////


module state_machine_moore_tb();
    reg clk, reset, in;
    wire out;
    integer i;

    // Instantiate the Moore state machine
    state_machine_moore dut(clk, reset, in, out);

    // Generate clock signal with a period of 10 time units
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initial block to apply test vectors
    initial begin
        reset = 1'b1; // Assert reset
        clk = 1'b0;
        in = 0;
        #6;
        reset = 1'b0; // Deassert reset

        // Apply a sequence of random inputs
        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk); #1;
            in = $random;
            if (out == 1'b1)
                $display("PASS: Sequence 11 detected i = %d\n", i);
        end
        #50;
        $finish;
    end
endmodule
