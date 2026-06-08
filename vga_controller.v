module vga_controller(
    input clk, // 100 MHz
    output hsync,
    output vsync,
    output video_on,
    output [9:0] x,
    output [9:0] y
);

    //----------------------------------------
    // 25 MHz pixel clock
    //----------------------------------------
    reg [1:0] p_clk_divider = 0;

    always @(posedge clk)
        p_clk_divider <= p_clk_divider + 1;

    wire p_clk = p_clk_divider[1];

    //----------------------------------------
    // VGA counters
    //----------------------------------------
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge p_clk) begin

        if(h_count == 799) begin

            h_count <= 0;

            if(v_count == 524)
                v_count <= 0;
            else
                v_count <= v_count + 1;

        end
        else begin
            h_count <= h_count + 1;
        end

    end

    //----------------------------------------
    // Sync signals (ACTIVE LOW)
    //----------------------------------------
    assign hsync =
        ~((h_count >= 656) && (h_count < 752));

    assign vsync =
        ~((v_count >= 490) && (v_count < 492));

    //----------------------------------------
    // Visible screen area
    //----------------------------------------
    assign video_on =
        (h_count < 640) &&
        (v_count < 480);

    //----------------------------------------
    // Pixel coordinates
    //----------------------------------------
    assign x = h_count;
    assign y = v_count;

endmodule