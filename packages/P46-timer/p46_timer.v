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

    // Internal timer registers
    reg [7:0] count;
    reg [7:0] cmp;
    reg ctrl_enable;
    reg ctrl_irq_en;
    reg match_flag; // Sticky match flag (STATUS bit 0)

    // Sequential logic (Registers & Counter)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count       <= 8'd0;
            cmp         <= 8'd0;
            ctrl_enable <= 1'b0;
            ctrl_irq_en <= 1'b0;
            match_flag  <= 1'b0;
        end else begin
            // Increment counter when enabled
            if (ctrl_enable) begin
                count <= count + 1'b1;
            end

            // Set sticky match flag when count equals comparison target
            if (ctrl_enable && (count == cmp)) begin
                match_flag <= 1'b1;
            end

            // Handle memory-mapped bus writes
            if (sel && we) begin
                case (ridx)
                    4'd0: count       <= wdata[7:0]; // COUNT register (offset 0)
                    4'd1: cmp         <= wdata[7:0]; // CMP register (offset 4)
                    4'd2: begin                      // CTRL register (offset 8)
                        ctrl_enable <= wdata[0];
                        ctrl_irq_en <= wdata[1];
                    end
                    4'd3: match_flag  <= wdata[0];   // STATUS register (offset 12)
                    default: ;
                endcase
            end
        end
    end

    // Combinational logic for reading registers from the bus
    always @(*) begin
        rdata = 32'd0;
        case (ridx)
            4'd0: rdata = {24'd0, count};                  // COUNT
            4'd1: rdata = {24'd0, cmp};                    // CMP
            4'd2: rdata = {30'd0, ctrl_irq_en, ctrl_enable}; // CTRL
            4'd3: rdata = {31'd0, match_flag};             // STATUS
            default: rdata = 32'd0;
        endcase
    end

    // Interrupt request line output
    assign irq = match_flag & ctrl_irq_en;

endmodule
