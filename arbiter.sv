
module arbiter #(
    parameter N_REQ = 4,
    parameter PTR_W = (N_REQ <= 1) ? 1 : $clog2(N_REQ)
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic [N_REQ-1:0]     req,
    input  logic                 ready,

    output logic [N_REQ-1:0]     grant,
    output logic                 grant_valid
);

    // Internal registers
    logic [PTR_W-1:0] rr_ptr;
    logic [N_REQ-1:0] grant_hold;
    logic [PTR_W-1:0] hold_idx;
    logic hold_valid;

    // Arbitration signals
    logic [N_REQ-1:0] selected_grant;
    logic [PTR_W-1:0] winner_idx;
    logic accept;

    integer i;
    integer idx;

    // Priority selection logic
    always_comb begin
        selected_grant = '0;
        winner_idx = rr_ptr;

        for (i = 0; i < N_REQ; i = i + 1) begin
            idx = rr_ptr + i;

            if (idx >= N_REQ)
                idx = idx - N_REQ;

            if ((selected_grant == '0) && req[idx]) begin
                selected_grant[idx] = 1'b1;
                winner_idx = idx;
            end
        end
    end

    // Grant output logic
    always_comb begin
        grant = '0;
        grant_valid = 1'b0;

        if (rst_n) begin
            if (hold_valid) begin
                grant = grant_hold;
                grant_valid = 1'b1;
            end
            else if (selected_grant != '0) begin
                grant = selected_grant;
                grant_valid = 1'b1;
            end
        end
    end

    // Handshake detection
    assign accept = grant_valid && ready;

    // Sequential state update
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            rr_ptr     <= '0;
            grant_hold <= '0;
            hold_idx   <= '0;
            hold_valid <= 1'b0;
        end

        else begin

            // Previously selected grant is being held
            if (hold_valid) begin

                if (accept) begin
                    if (hold_idx == N_REQ-1)
                    rr_ptr <= '0;
                    else
                    rr_ptr <= hold_idx + 1'b1;
                    hold_valid <= 1'b0;
                    grant_hold <= '0;
                end

            end

            // No grant is currently being held
            else if (grant_valid) begin

                // Resource is not ready
                if (!ready) begin
                    grant_hold <= selected_grant;
                    hold_idx   <= winner_idx;
                    hold_valid <= 1'b1;
                end

                // Transaction accepted immediately
                else if (accept) begin
                    if (winner_idx == N_REQ-1)
                rr_ptr <= '0;
                else
                rr_ptr <= winner_idx + 1'b1;
                end

            end

        end
    end
`ifdef FORMAL

    reg formal_past_valid = 0;

    always @(posedge clk) begin

        formal_past_valid <= 1'b1;

        if (formal_past_valid && rst_n && $past(rst_n)) begin
if ($past(hold_valid))
    assert ($past(hold_idx) < N_REQ);
  // Property 7: Pointer remains within valid requester range
    assert (rr_ptr < N_REQ);

          // Property 4: Pointer advances after acceptance
if ($past(accept)) begin

    if ($past(hold_valid)) begin
        if ($past(hold_idx) == N_REQ-1)
            assert (rr_ptr == 0);
        else
            assert (rr_ptr == ($past(hold_idx) + 1'b1));
    end
    else begin
        if ($past(winner_idx) == N_REQ-1)
            assert (rr_ptr == 0);
        else
            assert (rr_ptr == ($past(winner_idx) + 1'b1));
    end

end

            // Property 5: Pointer remains unchanged without acceptance
            else begin
                assert (rr_ptr == $past(rr_ptr));
            end

            // Property 6: Held grant clears after acceptance
            if ($past(hold_valid && accept)) begin
                assert (hold_valid == 1'b0);
                assert (grant_hold == '0);
            end

        end
    end

`endif
endmodule
