// P46 Timer
// Keep the module name and the port list exactly as they are.
// You may change 'output wire' to 'output reg' if you assign an output in an always block.
// Delete the placeholder assigns and write your design.
module p46_timer (
    input  wire clk,
    input  wire rst,
    input  wire sel,
    input  wire we,
    input  wire re,
    input  wire [3:0] ridx,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    output wire irq
);

    localparam [3:0] R_COUNT  = 4'd0;
    localparam [3:0] R_CMP    = 4'd1;
    localparam [3:0] R_CTRL   = 4'd2;
    localparam [3:0] R_STATUS = 4'd3;

    reg [31:0] count;
    reg [31:0] cmp;
    reg        en;
    reg        match;

    wire wr  = sel & we;
    wire rd  = sel & re;
    wire hit = en & (count == cmp);

    assign irq = match;

    always @(posedge clk) begin
        if (rst) begin
            count <= 32'd0;
            cmp   <= 32'd0;
            en    <= 1'b0;
            match <= 1'b0;
            rdata <= 32'd0;
        end else begin
            if (wr && ridx == R_COUNT)
                count <= wdata;
            else if (en)
                count <= count + 32'd1;

            if (wr && ridx == R_CMP)
                cmp <= wdata;
            if (wr && ridx == R_CTRL)
                en <= wdata[0];

            if (wr && ridx == R_STATUS)
                match <= 1'b0;
            else if (hit)
                match <= 1'b1;

            rdata <= 32'd0;
            if (rd) begin
                case (ridx)
                    R_COUNT:  rdata <= count;
                    R_CMP:    rdata <= cmp;
                    R_CTRL:   rdata <= {31'd0, en};
                    R_STATUS: rdata <= {31'd0, match};
                    default:  rdata <= 32'd0;
                endcase
            end
        end
    end

endmodule

