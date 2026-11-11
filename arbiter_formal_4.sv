module arbiter_formal;

    (* gclk *) reg clk;

    reg rst_n = 0;

    (* anyseq *) reg [3:0] req;
    (* anyseq *) reg ready;

    wire [3:0] grant;
    wire grant_valid;

    reg past_valid = 0;

    // Release reset after the first clock edge
    always @(posedge clk) begin
        rst_n <= 1'b1;
        past_valid <= 1'b1;
    end

    // Instantiate the arbiter
    arbiter #(
        .N_REQ(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .ready(ready),
        .grant(grant),
        .grant_valid(grant_valid)
    );

    // Formal properties
    always @(posedge clk) begin

        if (past_valid && rst_n) begin

            // Property 1: Grant must be one-hot or zero
            assert ((grant & (grant - 1'b1)) == 4'b0000); 
            // Property 2: grant_valid must match grant
            assert (grant_valid == (|grant));

            // Property 3: Grant must remain stable
            // when the previous cycle experienced backpressure
            if ($past(grant_valid && !ready))
                assert (grant == $past(grant));
                                         

        end
    end

endmodule
