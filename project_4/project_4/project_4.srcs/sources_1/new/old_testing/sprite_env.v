module sprite_environment (
    input wire clk,
    input wire video_on,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    
    // Config interface to upload/change sprite attributes dynamically
    input wire write_en,
    input wire [3:0] reg_addr,   // 0-11 maps configuration registers
    input wire [9:0] write_data,
    
    // Pixel Color Out
    output reg [11:0] video_rgb
);

    // Environment Specs
    localparam MAX_SPRITES  = 4;
    localparam SPRITE_SIZE  = 16; // 16x16 pixels

    // VRAM Registers storing: [X coordinate, Y coordinate, Sprite ID]
    reg [9:0] sprite_x   [0:MAX_SPRITES-1];
    reg [9:0] sprite_y   [0:MAX_SPRITES-1];
    reg [3:0] sprite_id  [0:MAX_SPRITES-1];

    // --- Handle External Uploads/Updates to Framebuffer ---
    always @(posedge clk) begin
        if (write_en) begin
            case(reg_addr)
                // Sprite 0
                4'd0: sprite_x[0]  <= write_data;
                4'd1: sprite_y[0]  <= write_data;
                4'd2: sprite_id[0] <= write_data[3:0];
                // Sprite 1
                4'd3: sprite_x[1]  <= write_data;
                4'd4: sprite_y[1]  <= write_data;
                4'd5: sprite_id[1] <= write_data[3:0];
                // Sprite 2
                4'd6: sprite_x[2]  <= write_data;
                4'd7: sprite_y[2]  <= write_data;
                4'd8: sprite_id[2] <= write_data[3:0];
                // Sprite 3
                4'd9: sprite_x[3]  <= write_data;
                4'd10: sprite_y[3] <= write_data;
                4'd11: sprite_id[3]<= write_data[3:0];
            endcase
        end
    end

    // --- Render Logic Engine ---
    // Check which sprite handles the current scanning position
    reg [3:0] active_id;
    reg [3:0] rom_x, rom_y;
    reg sprite_hit;
    
    integer i;
    always @(*) begin
        sprite_hit = 1'b0;
        active_id  = 4'd0;
        rom_x      = 4'd0;
        rom_y      = 4'd0;
        
        // Loop through registers to see if scanning beam is inside any sprite
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

    // Instantiate Asset ROM
    wire [3:0] color_idx;
    sprite_rom rom_inst (
        .clk(clk),
        .sprite_id(active_id),
        .pixel_y(rom_y),
        .pixel_x(rom_x),
        .color_idx(color_idx)
    );

    // --- Color Palette Decoding LUT ---
    reg [11:0] palette_rgb;
    always @(*) begin
        case(color_idx)
            4'd0:  palette_rgb = 12'h000; // Transparent Code (Don't render)
            4'd1:  palette_rgb = 12'h733; // Bear Outline Color
            4'd2:  palette_rgb = 12'hC66; // Bear Midtone
            4'd3:  palette_rgb = 12'hE77; // Bear Highlight
            default: palette_rgb = 12'hFFF;
        endcase
    end

    // --- Composite Output Mux ---
    always @(*) begin
        if (!video_on)
            video_rgb = 12'h000; // Screen blanking margin must be black
        else if (sprite_hit && (color_idx != 4'd0))
            video_rgb = palette_rgb; // Draw sprite pixel
        else
            video_rgb = 12'h358; // Background canvas color (Dark Slate)
    end

endmodule