module sprite_ram (
    input wire clk,
    
    // Port A: External Write Interface Channel
    input wire we,
    input wire [11:0] w_addr,
    input wire [3:0] w_data,
    
    // Port B: Internal Video Read Interface Channel
    input wire [3:0] sprite_id,
    input wire [3:0] pixel_y,
    input wire [3:0] pixel_x,
    output reg [3:0] color_idx
);

    // 4096 memory positions of 4-bit entries
    reg [3:0] ram [0:4095];
    wire [11:0] r_addr = {sprite_id, pixel_y, pixel_x};

    // Pre-populating RAM with standard color index blocks on boot,
    // so you see colored placeholders before uploading your actual image files.
    integer s, r, c;
    initial begin
        for(s=0; s<16; s=s+1) begin
            for(r=0; r<16; r=r+1) begin
                for(c=0; c<16; c=c+1) begin
                    ram[{s[3:0], r[3:0], c[3:0]}] = ((r==0 || r==15 || c==0 || c==15)) ? 4'd1 : 4'd2;
                end
            end
        end
    end

    // Port A: Synchronous Write Cycle
    always @(posedge clk) begin
        if (we) begin
            ram[w_addr] <= w_data;
        end
    end

    // Port B: Synchronous Read Cycle
    always @(posedge clk) begin
        color_idx <= ram[r_addr];
    end

endmodule