module sprite_environment (
    input wire clk,
    input wire video_on,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    
    // Upload Bus
    input wire upload_we,
    input wire [11:0] upload_addr,
    input wire [3:0] upload_data,
    
    output reg [11:0] video_rgb
);

    localparam MAX_SPRITES  = 4;
    localparam SPRITE_SIZE  = 16; // 16x16 Pixel Bounding Box

    // Framebuffer Hardware Register Array for Screen Placements
    reg [9:0] sprite_x   [0:MAX_SPRITES-1];
    reg [9:0] sprite_y   [0:MAX_SPRITES-1];
    reg [3:0] sprite_id  [0:MAX_SPRITES-1];

    // Safe Structural Boot Positions (Initial alignment before you move them)
    initial begin
        sprite_x[0] = 10'd150; sprite_y[0] = 10'd150; sprite_id[0] = 4'd0; // Sprite 0 (Your Bear Slot)
        sprite_x[1] = 10'd320; sprite_y[1] = 10'd240; sprite_id[1] = 4'd0; // Sprite 1
        sprite_x[2] = 10'd450; sprite_y[2] = 10'd120; sprite_id[2] = 4'd0; // Sprite 2
        sprite_x[3] = 10'd200; sprite_y[3] = 10'd350; sprite_id[3] = 4'd0; // Sprite 3
    end

    // Combinational Coordinate Engine
    reg [3:0] active_id;
    reg [3:0] rom_x, rom_y;
    reg sprite_hit;
    
    integer i;
    always @(*) begin
        sprite_hit = 1'b0;
        active_id  = 4'd0;
        rom_x      = 4'd0;
        rom_y      = 4'd0;
        for (i = 0; i < MAX_SPRITES; i = i + 1) begin
            if ((pixel_x >= sprite_x[i]) && (pixel_x < sprite_x[i] + SPRITE_SIZE) &&
                (pixel_y >= sprite_y[i]) && (pixel_y < sprite_y[i] + SPRITE_SIZE)) begin
                sprite_hit = 1'b1;
                active_id  = sprite_id[i];
                rom_x      = pixel_x - sprite_x[i];
                rom_y      = pixel_y - sprite_y[i];
            end
        end
    end

    // Instantiate True Dual-Port Block RAM (VRAM)
    wire [3:0] color_idx;
    sprite_ram vram_inst (
        .clk(clk),
        
        // Port A (Write Interface)
        .we(upload_we),
        .w_addr(upload_addr),
        .w_data(upload_data),
        
        // Port B (Read Interface)
        .sprite_id(active_id),
        .pixel_y(rom_y),
        .pixel_x(rom_x),
        .color_idx(color_idx)
    );

    // Latency Pipeline delay registers to perfectly match sync cycles to BRAM output
    reg pipe_hit, pipe_video;
    always @(posedge clk) begin
        pipe_hit   <= sprite_hit;
        pipe_video <= video_on;
    end

    // Digital Palette Lookup Mapping Configuration
    reg [11:0] palette_rgb;
    always @(*) begin
        case(color_idx)
            4'd0:    palette_rgb = 12'h358; // Background Canvas match color (Acts as Transparency)
            4'd1:    palette_rgb = 12'h733; // Bear Outline Color
            4'd2:    palette_rgb = 12'hC66; // Bear Midtone Color
            4'd3:    palette_rgb = 12'hE77; // Bear Highlight Color
            default: palette_rgb = 12'hFFF; // Default Fallback (White)
        endcase
    end

    // Video Output Compositor Multiplexer
    always @(*) begin
        if (!pipe_video)
            video_rgb = 12'h000; // Screen border margins MUST remain absolute black
        else if (pipe_hit)
            video_rgb = palette_rgb; 
        else
            video_rgb = 12'h358; // Solid Canvas Background (Dark Slate Blue)
    end

endmodule