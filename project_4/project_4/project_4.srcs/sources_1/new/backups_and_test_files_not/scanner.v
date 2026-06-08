module top(
    input clk,
    input btnC,
    output hsync,
    output vsync,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue
);

    //-----------------------------------------------------
    // VGA
    //-----------------------------------------------------
    wire video_on;
    wire [9:0] x;
    wire [9:0] y;

    vga_controller vc(
        .clk(clk),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(x),
        .y(y)
    );

    //-----------------------------------------------------
    // STATES
    //-----------------------------------------------------
    parameter SCAN_SCREEN = 0;
    parameter PET_SCREEN  = 1;

    reg screen_state = SCAN_SCREEN;

    //-----------------------------------------------------
    // SPRITE SETTINGS
    //-----------------------------------------------------
    parameter WIDTH  = 64;
    parameter HEIGHT = 64;
    parameter SCALE  = 2;

    //-----------------------------------------------------
    // POSITIONS
    //-----------------------------------------------------
    parameter SPRITE_X = 200;
    parameter SPRITE_Y = 80;

    parameter HEALTH_X = 40;
    parameter HEALTH_Y = 260;

    parameter FOOD_X = 440;
    parameter FOOD_Y = 260;

    //-----------------------------------------------------
    // LLAMA MEMORIES
    //-----------------------------------------------------
    reg [11:0] frame0 [0:4095];
    reg [11:0] frame1 [0:4095];
    reg [11:0] frame2 [0:4095];

    //-----------------------------------------------------
    // HEALTH MEMORIES
    //-----------------------------------------------------
    reg [11:0] h1 [0:4095];
    reg [11:0] h2 [0:4095];
    reg [11:0] h3 [0:4095];
    reg [11:0] h4 [0:4095];
    reg [11:0] h5 [0:4095];
    reg [11:0] h6 [0:4095];
    reg [11:0] h7 [0:4095];
    reg [11:0] h8 [0:4095];

    //-----------------------------------------------------
    // FOOD MEMORIES
    //-----------------------------------------------------
    reg [11:0] food1  [0:4095];
    reg [11:0] food2  [0:4095];
    reg [11:0] food3  [0:4095];
    reg [11:0] food4  [0:4095];
    reg [11:0] food5  [0:4095];
    reg [11:0] food6  [0:4095];
    reg [11:0] food7  [0:4095];
    reg [11:0] food8  [0:4095];
    reg [11:0] food9  [0:4095];
    reg [11:0] food10 [0:4095];
    reg [11:0] food11 [0:4095];
    reg [11:0] food12 [0:4095];
    reg [11:0] food13 [0:4095];
    reg [11:0] food14 [0:4095];
    reg [11:0] food15 [0:4095];
    reg [11:0] food16 [0:4095];
    reg [11:0] food17 [0:4095];
    reg [11:0] food18 [0:4095];
    reg [11:0] food19 [0:4095];
    reg [11:0] food20 [0:4095];
    reg [11:0] food21 [0:4095];

    //-----------------------------------------------------
    // SCANNER MEMORIES
    //-----------------------------------------------------
    reg [11:0] scan1 [0:4095];
    reg [11:0] scan2 [0:4095];
    reg [11:0] scan3 [0:4095];
    reg [11:0] scan4 [0:4095];
    reg [11:0] scan5 [0:4095];
    reg [11:0] scan6 [0:4095];
    reg [11:0] scan7 [0:4095];

    //-----------------------------------------------------
    // LOAD MEMORIES
    //-----------------------------------------------------
    initial begin

        //---------------------------------------------
        // LLAMA
        //---------------------------------------------
        $readmemh("eat_01.mem", frame0);
        $readmemh("eat_07.mem", frame1);
        $readmemh("eat_08.mem", frame2);

        //---------------------------------------------
        // HEALTH
        //---------------------------------------------
        $readmemh("h_1.mem", h1);
        $readmemh("h_2.mem", h2);
        $readmemh("h_3.mem", h3);
        $readmemh("h_4.mem", h4);
        $readmemh("h_5.mem", h5);
        $readmemh("h_6.mem", h6);
        $readmemh("h_7.mem", h7);
        $readmemh("h_8.mem", h8);

        //---------------------------------------------
        // FOOD
        //---------------------------------------------
        $readmemh("food_01.mem", food1);
        $readmemh("food_02.mem", food2);
        $readmemh("food_03.mem", food3);
        $readmemh("food_04.mem", food4);
        $readmemh("food_05.mem", food5);
        $readmemh("food_06.mem", food6);
        $readmemh("food_07.mem", food7);
        $readmemh("food_08.mem", food8);
        $readmemh("food_09.mem", food9);
        $readmemh("food_10.mem", food10);
        $readmemh("food_11.mem", food11);
        $readmemh("food_12.mem", food12);
        $readmemh("food_13.mem", food13);
        $readmemh("food_14.mem", food14);
        $readmemh("food_15.mem", food15);
        $readmemh("food_16.mem", food16);
        $readmemh("food_17.mem", food17);
        $readmemh("food_18.mem", food18);
        $readmemh("food_19.mem", food19);
        $readmemh("food_20.mem", food20);
        $readmemh("food_21.mem", food21);

        //---------------------------------------------
        // SCANNER
        //---------------------------------------------
        $readmemh("scan_1.mem", scan1);
        $readmemh("scan_2.mem", scan2);
        $readmemh("scan_3.mem", scan3);
        $readmemh("scan_4.mem", scan4);
        $readmemh("scan_5.mem", scan5);
        $readmemh("scan_6.mem", scan6);
        $readmemh("scan_7.mem", scan7);

    end

    //-----------------------------------------------------
    // SPRITE REGIONS
    //-----------------------------------------------------
    wire sprite_on;
    wire health_on;
    wire food_on;

    assign sprite_on =
        (x >= SPRITE_X) &&
        (x < SPRITE_X + WIDTH * SCALE) &&
        (y >= SPRITE_Y) &&
        (y < SPRITE_Y + HEIGHT * SCALE);

    assign health_on =
        (x >= HEALTH_X) &&
        (x < HEALTH_X + WIDTH * SCALE) &&
        (y >= HEALTH_Y) &&
        (y < HEALTH_Y + HEIGHT * SCALE);

    assign food_on =
        (x >= FOOD_X) &&
        (x < FOOD_X + WIDTH * SCALE) &&
        (y >= FOOD_Y) &&
        (y < FOOD_Y + HEIGHT * SCALE);

    //-----------------------------------------------------
    // LOCAL COORDINATES
    //-----------------------------------------------------
    wire [5:0] sx;
    wire [5:0] sy;

    wire [5:0] hx;
    wire [5:0] hy;

    wire [5:0] fx;
    wire [5:0] fy;

    assign sx = (x - SPRITE_X) / SCALE;
    assign sy = (y - SPRITE_Y) / SCALE;

    assign hx = (x - HEALTH_X) / SCALE;
    assign hy = (y - HEALTH_Y) / SCALE;

    assign fx = (x - FOOD_X) / SCALE;
    assign fy = (y - FOOD_Y) / SCALE;

    //-----------------------------------------------------
    // ADDRESSES
    //-----------------------------------------------------
    wire [11:0] addr;
    wire [11:0] haddr;
    wire [11:0] faddr;

    assign addr  = sy * WIDTH + sx;
    assign haddr = hy * WIDTH + hx;
    assign faddr = fy * WIDTH + fx;

    //-----------------------------------------------------
    // LLAMA ANIMATION
    //-----------------------------------------------------
    reg [25:0] slow_clk = 0;
    reg [1:0] frame = 0;

    always @(posedge clk) begin

        slow_clk <= slow_clk + 1;

        if(slow_clk == 8_000_000) begin

            slow_clk <= 0;

            if(frame == 2)
                frame <= 0;
            else
                frame <= frame + 1;

        end
    end

    //-----------------------------------------------------
    // HEALTH ANIMATION
    //-----------------------------------------------------
    reg [31:0] health_clk = 0;
    reg [2:0] health_frame = 0;

    always @(posedge clk) begin

        health_clk <= health_clk + 1;

        if(health_clk == 200_000_000) begin

            health_clk <= 0;

            if(health_frame == 7)
                health_frame <= 0;
            else
                health_frame <= health_frame + 1;

        end
    end

    //-----------------------------------------------------
    // FOOD ANIMATION
    //-----------------------------------------------------
    reg [31:0] food_clk = 0;
    reg [4:0] food_frame = 0;

    always @(posedge clk) begin

        food_clk <= food_clk + 1;

        if(food_clk == 120_000_000) begin

            food_clk <= 0;

            if(food_frame == 20)
                food_frame <= 0;
            else
                food_frame <= food_frame + 1;

        end
    end

    //-----------------------------------------------------
    // SCAN ANIMATION
    //-----------------------------------------------------
    reg [26:0] scan_clk = 0;
    reg [2:0] scan_frame = 0;

    always @(posedge clk) begin

        scan_clk <= scan_clk + 1;

        if(scan_clk == 15_000_000) begin

            scan_clk <= 0;

            if(scan_frame == 6)
                scan_frame <= 0;
            else
                scan_frame <= scan_frame + 1;

        end
    end

    //-----------------------------------------------------
    // SCAN CONTROL
    //-----------------------------------------------------
    reg [31:0] scan_timer = 0;
    reg scanning = 0;

    always @(posedge clk) begin

        if(screen_state == SCAN_SCREEN) begin

            //-----------------------------------------
            // Start scan after center button press
            //-----------------------------------------
            if(btnC)
                scanning <= 1;

            //-----------------------------------------
            // While scanning
            //-----------------------------------------
            if(scanning) begin

                scan_timer <= scan_timer + 1;

                //-------------------------------------
                // Go to pet screen
                //-------------------------------------
                if(scan_timer >= 200_000_000) begin

                    screen_state <= PET_SCREEN;

                    scan_timer <= 0;
                    scanning <= 0;

                end
            end
        end
    end

    //-----------------------------------------------------
    // RGB REGISTERS
    //-----------------------------------------------------
    reg [11:0] rgb;
    reg [11:0] health_rgb;
    reg [11:0] food_rgb;
    reg [11:0] scan_rgb;

    //-----------------------------------------------------
    // HEALTH RGB
    //-----------------------------------------------------
    always @(*) begin

        case(health_frame)

            0: health_rgb = h1[haddr];
            1: health_rgb = h2[haddr];
            2: health_rgb = h3[haddr];
            3: health_rgb = h4[haddr];
            4: health_rgb = h5[haddr];
            5: health_rgb = h6[haddr];
            6: health_rgb = h7[haddr];
            7: health_rgb = h8[haddr];

            default:
                health_rgb = 12'h000;

        endcase
    end

    //-----------------------------------------------------
    // FOOD RGB
    //-----------------------------------------------------
    always @(*) begin

        case(food_frame)

            0:  food_rgb = food1[faddr];
            1:  food_rgb = food2[faddr];
            2:  food_rgb = food3[faddr];
            3:  food_rgb = food4[faddr];
            4:  food_rgb = food5[faddr];
            5:  food_rgb = food6[faddr];
            6:  food_rgb = food7[faddr];
            7:  food_rgb = food8[faddr];
            8:  food_rgb = food9[faddr];
            9:  food_rgb = food10[faddr];
            10: food_rgb = food11[faddr];
            11: food_rgb = food12[faddr];
            12: food_rgb = food13[faddr];
            13: food_rgb = food14[faddr];
            14: food_rgb = food15[faddr];
            15: food_rgb = food16[faddr];
            16: food_rgb = food17[faddr];
            17: food_rgb = food18[faddr];
            18: food_rgb = food19[faddr];
            19: food_rgb = food20[faddr];
            20: food_rgb = food21[faddr];

            default:
                food_rgb = 12'h000;

        endcase
    end

    //-----------------------------------------------------
    // SCAN RGB
    //-----------------------------------------------------
    always @(*) begin

        case(scan_frame)

            0: scan_rgb = scan1[addr];
            1: scan_rgb = scan2[addr];
            2: scan_rgb = scan3[addr];
            3: scan_rgb = scan4[addr];
            4: scan_rgb = scan5[addr];
            5: scan_rgb = scan6[addr];
            6: scan_rgb = scan7[addr];

            default:
                scan_rgb = 12'h000;

        endcase
    end

    //-----------------------------------------------------
    // FINAL DRAW
    //-----------------------------------------------------
    always @(*) begin

        rgb = 12'h000;

        //---------------------------------------------
        // SCAN SCREEN
        //---------------------------------------------
        if(screen_state == SCAN_SCREEN) begin

            if(sprite_on) begin

                //-------------------------------------
                // Before button press
                //-------------------------------------
                if(!scanning)
                    rgb = scan1[addr];

                //-------------------------------------
                // Animate after button press
                //-------------------------------------
                else
                    rgb = scan_rgb;

            end
        end

        //---------------------------------------------
        // PET SCREEN
        //---------------------------------------------
        else begin

            //-----------------------------------------
            // LLAMA
            //-----------------------------------------
            if(sprite_on) begin

                case(frame)

                    0: rgb = frame0[addr];
                    1: rgb = frame1[addr];
                    2: rgb = frame2[addr];

                    default:
                        rgb = 12'h000;

                endcase
            end

            //-----------------------------------------
            // HEALTH
            //-----------------------------------------
            if(health_on)
                rgb = health_rgb;

            //-----------------------------------------
            // FOOD
            //-----------------------------------------
            if(food_on)
                rgb = food_rgb;

        end
    end

    //-----------------------------------------------------
    // VGA OUTPUTS
    //-----------------------------------------------------
    assign vgaRed   = video_on ? rgb[11:8] : 0;
    assign vgaGreen = video_on ? rgb[7:4]  : 0;
    assign vgaBlue  = video_on ? rgb[3:0]  : 0;

endmodule