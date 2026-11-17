// P53 Watchdog timer
// Slot 11 registers (ridx): 0 LOAD, 1 CTRL (bit0 enable), 2 STATUS (bit0 = bite),
//                           3 COUNT, 4 KICK, 15 = 53 (package number)
//
// While enabled the counter counts down. When it is 0 it sets the sticky bite
// flag and reloads from LOAD. A write to KICK, or a write to CTRL with bit0 = 1,
// reloads the counter. A write to STATUS clears the bite flag. rst clears all.
// Register contents change only on the rising edge of clk; rdata simply shows
// the register selected by ridx.
module p53_watchdog (
    input  wire clk,
    input  wire rst,
    input  wire sel,
    input  wire we,
    input  wire re,
    input  wire [3:0] ridx,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);

    reg [31:0] load, count;
    reg        en, bite;

    wire wr      = sel & we;
    wire wr_load = wr & (ridx == 4'd0);
    wire wr_ctrl = wr & (ridx == 4'd1);
    wire wr_stat = wr & (ridx == 4'd2);
    wire kick    = wr & (ridx == 4'd4);

    // values the registers will have after this clock edge
    wire [31:0] load_n = wr_load ? wdata : load;
    wire        en_n   = wr_ctrl ? wdata[0] : en;

    always @(posedge clk) begin
        if (rst) begin
            load  <= 32'd0;
            count <= 32'd0;
            en    <= 1'b0;
            bite  <= 1'b0;
        end else begin
            load <= load_n;
            en   <= en_n;

            // counting (uses the new enable and the new LOAD value)
            if (en_n) begin
                if (count == 32'd0) begin
                    bite  <= 1'b1;
                    count <= load_n;
                end else
                    count <= count - 32'd1;
            end

            // reloads requested over the bus
            if (kick)                  count <= load;
            if (wr_ctrl && wdata[0])   count <= load;

            // clear the bite flag (a bite on this same edge wins)
            if (wr_stat && !(en_n && count == 32'd0))
                bite <= 1'b0;
        end
    end

    // read side
    always @(*) begin
        case (ridx)
            4'd0:    rdata = load;
            4'd1:    rdata = {31'd0, en};
            4'd2:    rdata = {31'd0, bite};
            4'd3:    rdata = count;
            4'd15:   rdata = 32'd53;
            default: rdata = 32'd0;
        endcase
    end

endmodule
