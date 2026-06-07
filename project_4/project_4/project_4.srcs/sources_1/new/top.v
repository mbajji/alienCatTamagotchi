module top(
    input clk,
    input btnL, // Eat
    input btnR, // Shower
    input btnD, // Sleep
    input btnU, // Fingerprint Scanner / Start Game
    input btnC, // Reset to Idle
    output hsync,
    output vsync,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue
);

    // VGA signals
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

    // States
    localparam STATE_SCANNING = 3'b000;
    localparam STATE_IDLE     = 3'b001;
    localparam STATE_EAT      = 3'b010;
    localparam STATE_SHOWER   = 3'b011;
    localparam STATE_SLEEP    = 3'b100;
    localparam STATE_CRY      = 3'b101;
    localparam STATE_DIE      = 3'b110;
    localparam STATE_WELCOME  = 3'b111; // Added structural starting state
    
    reg [2:0] current_state = STATE_WELCOME; 
    
    reg [11:0] area51 [0:4095];
    reg [11:0] bond [0:4095];
    
    reg [11:0] frame0 [0:4095];
    reg [11:0] frame1 [0:4095];

    // Eating animation memories (8 frames)
    reg [11:0] eat0 [0:4095]; reg [11:0] eat1 [0:4095]; reg [11:0] eat2 [0:4095]; reg [11:0] eat3 [0:4095];
    reg [11:0] eat4 [0:4095]; reg [11:0] eat5 [0:4095]; reg [11:0] eat6 [0:4095]; reg [11:0] eat7 [0:4095];

    // Shower animation memories (12 frames)
    reg [11:0] shower0  [0:4095]; reg [11:0] shower1  [0:4095]; reg [11:0] shower2  [0:4095]; reg [11:0] shower3  [0:4095];
    reg [11:0] shower4  [0:4095]; reg [11:0] shower5  [0:4095]; reg [11:0] shower6  [0:4095]; reg [11:0] shower7  [0:4095];
    reg [11:0] shower8  [0:4095]; reg [11:0] shower9  [0:4095]; reg [11:0] shower10 [0:4095]; reg [11:0] shower11 [0:4095];

    // Sleeping animation memories (7 frames)
    reg [11:0] sleep0 [0:4095]; reg [11:0] sleep1 [0:4095]; reg [11:0] sleep2 [0:4095];
    reg [11:0] sleep3 [0:4095]; reg [11:0] sleep4 [0:4095]; reg [11:0] sleep5 [0:4095];
    reg [11:0] sleep6 [0:4095];

    // Health animation memories
    reg [11:0] h1 [0:4095]; reg [11:0] h2 [0:4095]; reg [11:0] h3 [0:4095]; reg [11:0] h4 [0:4095];
    reg [11:0] h5 [0:4095]; reg [11:0] h6 [0:4095]; reg [11:0] h7 [0:4095]; reg [11:0] h8 [0:4095];

    // Food Bar animation memories (22 frames total)
    reg [11:0] food0  [0:4095]; // Included food0
    reg [11:0] food1  [0:4095]; reg [11:0] food2  [0:4095]; reg [11:0] food3  [0:4095]; reg [11:0] food4  [0:4095];
    reg [11:0] food5  [0:4095]; reg [11:0] food6  [0:4095]; reg [11:0] food7  [0:4095]; reg [11:0] food8  [0:4095];
    reg [11:0] food9  [0:4095]; reg [11:0] food10 [0:4095]; reg [11:0] food11 [0:4095]; reg [11:0] food12 [0:4095];
    reg [11:0] food13 [0:4095]; reg [11:0] food14 [0:4095]; reg [11:0] food15 [0:4095]; reg [11:0] food16 [0:4095];
    reg [11:0] food17 [0:4095]; reg [11:0] food18 [0:4095]; reg [11:0] food19 [0:4095]; reg [11:0] food20 [0:4095];
    reg [11:0] food21 [0:4095];
    
    // Shower Bar animation memories
    reg [11:0] showerBar0  [0:4095]; reg [11:0] showerBar1  [0:4095]; reg [11:0] showerBar2  [0:4095]; reg [11:0] showerBar3  [0:4095];
    reg [11:0] showerBar4  [0:4095]; reg [11:0] showerBar5  [0:4095]; reg [11:0] showerBar6  [0:4095]; reg [11:0] showerBar7  [0:4095];
    reg [11:0] showerBar8  [0:4095]; reg [11:0] showerBar9  [0:4095]; reg [11:0] showerBar10  [0:4095]; reg [11:0] showerBar11  [0:4095];
    reg [11:0] showerBar12  [0:4095]; reg [11:0] showerBar13  [0:4095]; reg [11:0] showerBar14  [0:4095]; reg [11:0] showerBar15  [0:4095];
    reg [11:0] showerBar16  [0:4095]; reg [11:0] showerBar17  [0:4095]; reg [11:0] showerBar18  [0:4095]; reg [11:0] showerBar19  [0:4095];
    reg [11:0] showerBar20  [0:4095]; reg [11:0] showerBar21  [0:4095]; reg [11:0] showerBar22  [0:4095]; reg [11:0] showerBar23  [0:4095];

    // Sleep Bar animation memories
    reg [11:0] sleepBar0  [0:4095]; reg [11:0] sleepBar1  [0:4095]; reg [11:0] sleepBar2  [0:4095]; reg [11:0] sleepBar3  [0:4095];
    reg [11:0] sleepBar4  [0:4095]; reg [11:0] sleepBar5  [0:4095]; reg [11:0] sleepBar6  [0:4095]; reg [11:0] sleepBar7  [0:4095];
    reg [11:0] sleepBar8  [0:4095]; reg [11:0] sleepBar9  [0:4095]; reg [11:0]  sleepBar10  [0:4095]; reg [11:0] sleepBar11  [0:4095];
    reg [11:0] sleepBar12  [0:4095]; reg [11:0] sleepBar13  [0:4095]; reg [11:0] sleepBar14  [0:4095]; reg [11:0] sleepBar15  [0:4095];
    reg [11:0] sleepBar16  [0:4095]; reg [11:0] sleepBar17  [0:4095]; reg [11:0] sleepBar18  [0:4095]; reg [11:0] sleepBar19  [0:4095];
    reg [11:0] sleepBar20  [0:4095]; reg [11:0] sleepBar21  [0:4095]; reg [11:0] sleepBar22  [0:4095]; reg [11:0] sleepBar23  [0:4095];
    
    // Cry / Sad Memories
    reg [11:0] sad0 [0:4095]; reg [11:0] sad1 [0:4095]; reg [11:0] sad2 [0:4095]; reg [11:0] sad3 [0:4095];
    reg [11:0] sad4 [0:4095]; reg [11:0] sad5 [0:4095]; reg [11:0] sad6 [0:4095];
       
    // Die memory
    reg [11:0] die  [0:4095];
       
    // Rule Instruction Static Memory
    reg [11:0] ins  [0:4095];
    
    // Fingerprint Scanner memories
    reg [11:0] scan1 [0:4095]; reg [11:0] scan2 [0:4095]; reg [11:0] scan3 [0:4095]; 
    reg [11:0] scan4 [0:4095]; reg [11:0] scan5 [0:4095]; reg [11:0] scan6 [0:4095]; 
    reg [11:0] scan7 [0:4095];

    // Load memory files
    initial begin
        $readmemh("idle_1.mem", frame0);
        $readmemh("idle_2.mem", frame1);
        
        $readmemh("bond.mem", bond);
        $readmemh("area51.mem", area51);

        $readmemh("eat_01.mem", eat0);
        $readmemh("eat_02.mem", eat1);
        $readmemh("eat_03.mem", eat2);
        $readmemh("eat_04.mem", eat3);
        $readmemh("eat_05.mem", eat4);
        $readmemh("eat_06.mem", eat5);
        $readmemh("eat_07.mem", eat6);
        $readmemh("eat_08.mem", eat7);
        
        $readmemh("shower_01.mem", shower0);
        $readmemh("shower_02.mem", shower1);
        $readmemh("shower_03.mem", shower2);
        $readmemh("shower_04.mem", shower3);
        $readmemh("shower_05.mem", shower4);
        $readmemh("shower_06.mem", shower5);
        $readmemh("shower_07.mem", shower6);
        $readmemh("shower_08.mem", shower7);
        $readmemh("shower_09.mem", shower8);
        $readmemh("shower_10.mem", shower9);
        $readmemh("shower_11.mem", shower10);
        $readmemh("shower_12.mem", shower11);

        $readmemh("sleep_0.mem", sleep0);
        $readmemh("sleep_1.mem", sleep1);
        $readmemh("sleep_2.mem", sleep2);
        $readmemh("sleep_3.mem", sleep3);
        $readmemh("sleep_4.mem", sleep4);
        $readmemh("sleep_5.mem", sleep5);
        $readmemh("sleep_6.mem", sleep6);

        $readmemh("h_1.mem", h1); $readmemh("h_2.mem", h2); $readmemh("h_3.mem", h3); $readmemh("h_4.mem", h4);
        $readmemh("h_5.mem", h5); $readmemh("h_6.mem", h6); $readmemh("h_7.mem", h7); $readmemh("h_8.mem", h8);

        $readmemh("food_00.mem", food0);
        $readmemh("food_01.mem", food1);   $readmemh("food_02.mem", food2);   $readmemh("food_03.mem", food3);
        $readmemh("food_04.mem", food4);   $readmemh("food_05.mem", food5);   $readmemh("food_06.mem", food6);
        $readmemh("food_07.mem", food7);   $readmemh("food_08.mem", food8);   $readmemh("food_09.mem", food9);
        $readmemh("food_10.mem", food10);  $readmemh("food_11.mem", food11);  $readmemh("food_12.mem", food12);
        $readmemh("food_13.mem", food13);  $readmemh("food_14.mem", food14);  $readmemh("food_15.mem", food15);
        $readmemh("food_16.mem", food16);  $readmemh("food_17.mem", food17);  $readmemh("food_18.mem", food18);
        $readmemh("food_19.mem", food19);  $readmemh("food_20.mem", food20);  $readmemh("food_21.mem", food21);
        
        $readmemh("barShower00.mem", showerBar0);  $readmemh("barShower01.mem", showerBar1);  $readmemh("barShower02.mem", showerBar2);
        $readmemh("barShower03.mem", showerBar3);  $readmemh("barShower04.mem", showerBar4);  $readmemh("barShower05.mem", showerBar5);
        $readmemh("barShower06.mem", showerBar6);  $readmemh("barShower07.mem", showerBar7);  $readmemh("barShower08.mem", showerBar8);
        $readmemh("barShower09.mem", showerBar9);  $readmemh("barShower10.mem", showerBar10); $readmemh("barShower11.mem", showerBar11);
        $readmemh("barShower12.mem", showerBar12); $readmemh("barShower13.mem", showerBar13); $readmemh("barShower14.mem", showerBar14);
        $readmemh("barShower15.mem", showerBar15); $readmemh("barShower16.mem", showerBar16); $readmemh("barShower17.mem", showerBar17);
        $readmemh("barShower18.mem", showerBar18); $readmemh("barShower19.mem", showerBar19); $readmemh("barShower20.mem", showerBar20);
        $readmemh("barShower21.mem", showerBar21); $readmemh("barShower22.mem", showerBar22); $readmemh("barShower23.mem", showerBar23);
        
        $readmemh("barSleep00.mem", sleepBar0);  $readmemh("barSleep01.mem", sleepBar1);  $readmemh("barSleep02.mem", sleepBar2);
        $readmemh("barSleep03.mem", sleepBar3);  $readmemh("barSleep04.mem", sleepBar4);  $readmemh("barSleep05.mem", sleepBar5);
        $readmemh("barSleep06.mem", sleepBar6);  $readmemh("barSleep07.mem", sleepBar7);  $readmemh("barSleep08.mem", sleepBar8);
        $readmemh("barSleep09.mem", sleepBar9);  $readmemh("barSleep10.mem", sleepBar10); $readmemh("barSleep11.mem", sleepBar11);
        $readmemh("barSleep12.mem", sleepBar12); $readmemh("barSleep13.mem", sleepBar13); $readmemh("barSleep14.mem", sleepBar14);
        $readmemh("barSleep15.mem", sleepBar15); $readmemh("barSleep16.mem", sleepBar16); $readmemh("barSleep17.mem", sleepBar17);
        $readmemh("barSleep18.mem", sleepBar18); $readmemh("barSleep19.mem", sleepBar19); $readmemh("barSleep20.mem", sleepBar20);
        $readmemh("barSleep21.mem", sleepBar21); $readmemh("barSleep22.mem", sleepBar22); $readmemh("barSleep23.mem", sleepBar23);

        $readmemh("scan_1.mem", scan1);
        $readmemh("scan_2.mem", scan2);
        $readmemh("scan_3.mem", scan3);
        $readmemh("scan_4.mem", scan4);
        $readmemh("scan_5.mem", scan5);
        $readmemh("scan_6.mem", scan6);
        $readmemh("scan_7.mem", scan7);
        
        $readmemh("sad0.mem", sad0); $readmemh("sad1.mem", sad1); $readmemh("sad2.mem", sad2); $readmemh("sad3.mem", sad3);
        $readmemh("sad4.mem", sad4); $readmemh("sad5.mem", sad5); $readmemh("sad6.mem", sad6);

        $readmemh("die.mem", die);
        $readmemh("instructions1.mem", ins);
    end

    // Sprite dimensions & scaling
    parameter WIDTH  = 64;
    parameter HEIGHT = 64;
    parameter SCALE  = 2;

    // Fixed Positioning variables
    parameter SPRITE_X  = 200; parameter SPRITE_Y  = 80;
    parameter HEALTH_X  = 40;  parameter HEALTH_Y  = 260;
    parameter FOOD_X    = 440; parameter FOOD_Y    = 260;
    parameter SCAN_X    = 288; parameter SCAN_Y    = 176; 
    parameter SHOWER_X  = 40;  parameter SHOWER_Y  = 350; 
    parameter SLEEP_X   = 440; parameter SLEEP_Y   = 350; 
    parameter IN_X      = 240; parameter IN_Y      = 305; 
    
    // Welcome coordinates placement
    parameter AREA51_X  = 200; parameter AREA51_Y  = 120;
    parameter BOND_X    = 288; parameter BOND_Y    = 260;

    // Sprite region flags
    wire sprite_on, health_on, food_on, scan_on, showerbar_on, sleepbar_on, in_on;
    wire area51_on, bond_on;

    assign sprite_on    = (x >= SPRITE_X)  && (x < SPRITE_X + WIDTH * SCALE)  && (y >= SPRITE_Y)  && (y < SPRITE_Y + HEIGHT * SCALE);
    assign health_on    = (x >= HEALTH_X)  && (x < HEALTH_X + WIDTH * SCALE)  && (y >= HEALTH_Y)  && (y < HEALTH_Y + HEIGHT * SCALE);
    assign food_on      = (x >= FOOD_X)    && (x < FOOD_X + WIDTH * SCALE)    && (y >= FOOD_Y)    && (y < FOOD_Y + HEIGHT * SCALE);
    assign scan_on      = (x >= SCAN_X)    && (x < SCAN_X + WIDTH * SCALE)    && (y >= SCAN_Y)    && (y < SCAN_Y + HEIGHT * SCALE);
    assign showerbar_on = (x >= SHOWER_X)  && (x < SHOWER_X + WIDTH * SCALE)  && (y >= SHOWER_Y)  && (y < SHOWER_Y + HEIGHT * SCALE);
    assign sleepbar_on  = (x >= SLEEP_X)   && (x < SLEEP_X + WIDTH * SCALE)   && (y >= SLEEP_Y)   && (y < SLEEP_Y + HEIGHT * SCALE);
    assign in_on        = (x >= IN_X)      && (x < IN_X + WIDTH * SCALE)      && (y >= IN_Y)      && (y < IN_Y + HEIGHT * SCALE);
    
    // Welcome Matrix Region Decoders
    assign area51_on    = (x >= AREA51_X)  && (x < AREA51_X + WIDTH * SCALE)  && (y >= AREA51_Y)  && (y < AREA51_Y + HEIGHT * SCALE);
    assign bond_on      = (x >= BOND_X)    && (x < BOND_X + WIDTH * SCALE)    && (y >= BOND_Y)    && (y < BOND_Y + HEIGHT * SCALE);

    // Local coordinates & Memory addresses
    wire [5:0] sx = (x - SPRITE_X) / SCALE;       wire [5:0] sy = (y - SPRITE_Y) / SCALE;
    wire [5:0] hx = (x - HEALTH_X) / SCALE;       wire [5:0] hy = (y - HEALTH_Y) / SCALE;
    wire [5:0] fx = (x - FOOD_X)   / SCALE;       wire [5:0] fy = (y - FOOD_Y)   / SCALE;
    wire [5:0] scanx = (x - SCAN_X) / SCALE;      wire [5:0] scany = (y - SCAN_Y) / SCALE;
    wire [5:0] showerx = (x - SHOWER_X) / SCALE;  wire [5:0] showery = (y - SHOWER_Y) / SCALE;
    wire [5:0] sleepx = (x - SLEEP_X) / SCALE;    wire [5:0] sleepy = (y - SLEEP_Y) / SCALE;
    wire [5:0] insx = (x - IN_X) / SCALE;         wire [5:0] insy = (y - IN_Y) / SCALE;
    
    wire [5:0] a51x = (x - AREA51_X) / SCALE;     wire [5:0] a51y = (y - AREA51_Y) / SCALE;
    wire [5:0] bndx = (x - BOND_X) / SCALE;       wire [5:0] bndy = (y - BOND_Y) / SCALE;

    wire [11:0] addr       = sy * WIDTH + sx;
    wire [11:0] haddr      = hy * WIDTH + hx;
    wire [11:0] faddr      = fy * WIDTH + fx;
    wire [11:0] scanaddr   = scany * WIDTH + scanx;
    wire [11:0] showeraddr = showery * WIDTH + showerx;
    wire [11:0] sleepaddr  = sleepy * WIDTH + sleepx;
    wire [11:0] insaddr    = insy * WIDTH + insx;
    
    wire [11:0] a51addr    = a51y * WIDTH + a51x;
    wire [11:0] bndaddr    = bndy * WIDTH + bndx;

    reg [27:0] scan_clk = 0;
    reg [2:0] scan_frame = 0;
    reg [25:0] slow_clk = 0;
    reg [3:0] frame = 0;        
    
    reg [4:0] food_level = 0;   
    reg [4:0] shower_level = 0; 
    reg [4:0] sleep_level = 0;
    
    reg [28:0] shower_decay_clk = 0; 
    reg [28:0] food_decay_clk = 0; 
    reg [28:0] sleep_decay_clk = 0; 

    reg btnL_delayed = 0;
    reg btnR_delayed = 0;
    reg btnD_delayed = 0;
    reg btnU_delayed = 0;
    wire btnL_pressed, btnR_pressed, btnD_pressed, btnU_pressed;
    
    assign btnL_pressed = (btnL && !btnL_delayed);
    assign btnR_pressed = (btnR && !btnR_delayed);
    assign btnD_pressed = (btnD && !btnD_delayed);
    assign btnU_pressed = (btnU && !btnU_delayed);

    // Reg and Clock for handling Health ticking inside main loop
    reg [27:0] health_clk = 0;
    reg [2:0] health_frame = 0;

    always @(posedge clk) begin
        btnL_delayed <= btnL; 
        btnR_delayed <= btnR;
        btnD_delayed <= btnD;
        btnU_delayed <= btnU;

        if (btnC) begin
            current_state <= STATE_IDLE;
            frame         <= 0;
            health_frame  <= 0;
        end 
        else if (btnU_pressed) begin
            current_state    <= STATE_SCANNING;
            scan_frame       <= 0;
            scan_clk         <= 0;
            
            food_level       <= 0;
            shower_level     <= 0;
            sleep_level      <= 0;
            health_frame     <= 0;
            
            food_decay_clk   <= 0;
            shower_decay_clk <= 0;
            sleep_decay_clk  <= 0;
            health_clk       <= 0;
        end 
        else if (current_state == STATE_IDLE || current_state == STATE_CRY) begin
            if (btnL_pressed) begin
                current_state  <= STATE_EAT;
                frame          <= 0;
                food_decay_clk <= 0; 
                
                if (food_level > 3) 
                    food_level <= food_level - 3;
                else
                    food_level <= 0;
                
                if (health_frame > 0) begin
                    health_frame <= 0;
                    health_clk   <= 0;
                end
            end
            else if (btnR_pressed) begin 
                current_state    <= STATE_SHOWER; 
                frame            <= 0; 
                shower_level     <= 0; 
                shower_decay_clk <= 0; 
                
                if (health_frame > 0) begin
                    health_frame <= 0;
                    health_clk   <= 0;
                end
            end
            else if (btnD_pressed) begin 
                current_state   <= STATE_SLEEP;  
                frame           <= 0; 
                sleep_level     <= 0; 
                sleep_decay_clk <= 0; 
                
                if (health_frame > 0) begin
                    health_frame <= 0;
                    health_clk   <= 0;
                end
            end
        end

        if (current_state != STATE_WELCOME && current_state != STATE_SCANNING && current_state != STATE_DIE) begin
            // Shower Decay Logic
            shower_decay_clk <= shower_decay_clk + 1;
            if (shower_decay_clk == 400_000_000) begin 
                shower_decay_clk <= 0;
                if (shower_level < 23)
                    shower_level <= shower_level + 1;
            end

            // Food Decay Logic (Increments toward empty limit 21)
            food_decay_clk <= food_decay_clk + 1;
            if (food_decay_clk == 300_000_000) begin 
                food_decay_clk <= 0;
                if (food_level < 21)
                    food_level <= food_level + 1;
            end
            
            // Sleep Decay Logic
            sleep_decay_clk <= sleep_decay_clk + 1;
            if (sleep_decay_clk == 500_000_000) begin 
                sleep_decay_clk <= 0;
                if (sleep_level < 23)
                     sleep_level <=  sleep_level + 1;
            end

            // Health Ticker Control Logic (Hurts when any bar hits completely empty)
            health_clk <= health_clk + 1;
            if (health_clk == 200_000_000) begin
                health_clk   <= 0;
                if (food_level == 21 || shower_level == 23 || sleep_level == 23) begin
                    if (health_frame < 7) 
                        health_frame <= health_frame + 1;
                end
            end

            // Process Emergency State Overrides
            if (health_frame == 7) begin
                current_state <= STATE_DIE;
            end 
            else if (health_frame == 0 && current_state == STATE_CRY) begin
                current_state <= STATE_IDLE;
            end
            else if (health_frame > 0 && health_frame < 7 && current_state == STATE_IDLE) begin
                current_state <= STATE_CRY;
                frame         <= 0;
            end
        end

        // Animation state processing execution blocks
        case (current_state)
            STATE_WELCOME: begin
                // Holds statically until btnU transitions out
            end

            STATE_SCANNING: begin
                scan_clk <= scan_clk + 1;
                if (scan_clk == 50_000_000) begin 
                    scan_clk <= 0;
                    if (scan_frame == 6) current_state <= (health_frame > 0) ? STATE_CRY : STATE_IDLE;
                    else                 scan_frame <= scan_frame + 1;
                end
            end

            STATE_IDLE: begin
                slow_clk <= slow_clk + 1;
                if (slow_clk == 8_000_000) begin
                    slow_clk <= 0;
                    frame    <= (frame == 1) ? 0 : frame + 1; 
                end
            end

            STATE_EAT: begin
                slow_clk <= slow_clk + 1;
                if (slow_clk == 8_000_000) begin
                    slow_clk <= 0;
                    if (frame == 7) begin
                        frame         <= 0;
                        current_state <= (health_frame > 0) ? STATE_CRY : STATE_IDLE; 
                    end else begin
                        frame <= frame + 1;
                    end
                end
            end
            
            STATE_SHOWER: begin
                slow_clk <= slow_clk + 1;
                if (slow_clk == 8_000_000) begin
                    slow_clk <= 0;
                    if (frame == 11) begin 
                        frame         <= 0;
                        current_state <= (health_frame > 0) ? STATE_CRY : STATE_IDLE; 
                    end else begin
                        frame <= frame + 1;
                    end
                end
            end

            STATE_SLEEP: begin
                slow_clk <= slow_clk + 1;
                if (slow_clk == 8_000_000) begin
                    slow_clk <= 0;
                    if (frame == 6) begin 
                        frame         <= 0;
                        current_state <= (health_frame > 0) ? STATE_CRY : STATE_IDLE;
                    end else begin
                        frame <= frame + 1;
                    end
                end
            end
            
            STATE_CRY: begin
                slow_clk <= slow_clk + 1;
                if (slow_clk == 8_000_000) begin
                    slow_clk <= 0;
                    frame    <= (frame == 6) ? 0 : frame + 1; 
                end
            end
            
            STATE_DIE: begin
                frame <= 0; 
            end
            
            default: current_state <= STATE_WELCOME;
        endcase
    end

    // Memory Multiplexers
    reg [11:0] health_rgb;
    reg [11:0] food_rgb;
    reg [11:0] scan_rgb;
    reg [11:0] shower_rgb;
    reg [11:0] sleep_rgb;
    reg [11:0] ins_rgb;

    always @(*) begin
        case(health_frame)
            0: health_rgb = h1[haddr]; 1: health_rgb = h2[haddr]; 2: health_rgb = h3[haddr]; 3: health_rgb = h4[haddr];
            4: health_rgb = h5[haddr]; 5: health_rgb = h6[haddr]; 6: health_rgb = h7[haddr]; 7: health_rgb = h8[haddr];
            default: health_rgb = 12'h000;
        endcase
    end

    always @(*) begin
        case(food_level) 
            0:  food_rgb = food0[faddr];
            1:  food_rgb = food1[faddr];   2:  food_rgb = food2[faddr];   3:  food_rgb = food3[faddr];   4:  food_rgb = food4[faddr];
            5:  food_rgb = food5[faddr];   6:  food_rgb = food6[faddr];   7:  food_rgb = food7[faddr];   8:  food_rgb = food8[faddr];
            9:  food_rgb = food9[faddr];   10: food_rgb = food10[faddr];  11: food_rgb = food11[faddr];  12: food_rgb = food12[faddr];
            13: food_rgb = food13[faddr];  14: food_rgb = food14[faddr];  15: food_rgb = food15[faddr];  16: food_rgb = food16[faddr];
            17: food_rgb = food17[faddr];  18: food_rgb = food18[faddr];  19: food_rgb = food19[faddr];  20: food_rgb = food20[faddr];
            21: food_rgb = food21[faddr];
            default: food_rgb = food21[faddr]; 
        endcase
    end
    
    always @(*) begin
        case(shower_level) 
            0:  shower_rgb = showerBar0[showeraddr];   1:  shower_rgb = showerBar1[showeraddr];   2:  shower_rgb = showerBar2[showeraddr];   3:  shower_rgb = showerBar3[showeraddr];
            4:  shower_rgb = showerBar4[showeraddr];   5:  shower_rgb = showerBar5[showeraddr];   6:  shower_rgb = showerBar6[showeraddr];   7:  shower_rgb = showerBar7[showeraddr];
            8:  shower_rgb = showerBar8[showeraddr];   9:  shower_rgb = showerBar9[showeraddr];   10: shower_rgb = showerBar10[showeraddr];  11: shower_rgb = showerBar11[showeraddr];
            12: shower_rgb = showerBar12[showeraddr];  13: shower_rgb = showerBar13[showeraddr];  14: shower_rgb = showerBar14[showeraddr];  15: shower_rgb = showerBar15[showeraddr];
            16: shower_rgb = showerBar16[showeraddr];  17: shower_rgb = showerBar17[showeraddr];  18: shower_rgb = showerBar18[showeraddr];  19: shower_rgb = showerBar19[showeraddr];
            20: shower_rgb = showerBar20[showeraddr];  21: shower_rgb = showerBar21[showeraddr];  22: shower_rgb = showerBar22[showeraddr];  23: shower_rgb = showerBar23[showeraddr];
            default: shower_rgb = showerBar23[showeraddr]; 
        endcase
    end

    always @(*) begin
        case(sleep_level) 
            0:  sleep_rgb = sleepBar0[sleepaddr];   1:  sleep_rgb = sleepBar1[sleepaddr];   2:  sleep_rgb = sleepBar2[sleepaddr];   3:  sleep_rgb = sleepBar3[sleepaddr];
            4:  sleep_rgb = sleepBar4[sleepaddr];   5:  sleep_rgb = sleepBar5[sleepaddr];   6:  sleep_rgb = sleepBar6[sleepaddr];   7:  sleep_rgb = sleepBar7[sleepaddr];
            8:  sleep_rgb = sleepBar8[sleepaddr];   9:  sleep_rgb = sleepBar9[sleepaddr];   10: sleep_rgb = sleepBar10[sleepaddr];  11: sleep_rgb = sleepBar11[sleepaddr];
            12: sleep_rgb = sleepBar12[sleepaddr];  13: sleep_rgb = sleepBar13[sleepaddr];  14: sleep_rgb = sleepBar14[sleepaddr];  15: sleep_rgb = sleepBar15[sleepaddr];
            16: sleep_rgb = sleepBar16[sleepaddr];  17: sleep_rgb = sleepBar17[sleepaddr];  18: sleep_rgb = sleepBar18[sleepaddr];  19: sleep_rgb = sleepBar19[sleepaddr];
            20: sleep_rgb = sleepBar20[sleepaddr];  21: sleep_rgb = sleepBar21[sleepaddr];  22: sleep_rgb = sleepBar22[sleepaddr];  23: sleep_rgb = sleepBar23[sleepaddr];
            default: sleep_rgb = sleepBar23[sleepaddr]; 
        endcase
    end

    always @(*) begin
        case(scan_frame)
            0: scan_rgb = scan1[scanaddr]; 1: scan_rgb = scan2[scanaddr]; 2: scan_rgb = scan3[scanaddr];
            3: scan_rgb = scan4[scanaddr]; 4: scan_rgb = scan5[scanaddr]; 5: scan_rgb = scan6[scanaddr];
            6: scan_rgb = scan7[scanaddr];
            default: scan_rgb = 12'h000;
        endcase
    end

    always @(*) begin
        ins_rgb = ins[insaddr];
    end

    reg [11:0] main_sprite_rgb;

    always @(*) begin
        main_sprite_rgb = 12'h000;
        case (current_state)
            STATE_IDLE: begin
                main_sprite_rgb = (frame == 0) ? frame0[addr] : frame1[addr];
            end
            
            STATE_EAT: begin
                case(frame)
                    0: main_sprite_rgb = eat0[addr];
                    1: main_sprite_rgb = eat1[addr];
                    2: main_sprite_rgb = eat2[addr];
                    3: main_sprite_rgb = eat3[addr];
                    4: main_sprite_rgb = eat4[addr];
                    5: main_sprite_rgb = eat5[addr];
                    6: main_sprite_rgb = eat6[addr];
                    7: main_sprite_rgb = eat7[addr];
                    default: main_sprite_rgb = eat0[addr];
                endcase
            end
            
            STATE_SHOWER: begin
                case(frame)
                    0:  main_sprite_rgb = shower0[addr];
                    1:  main_sprite_rgb = shower1[addr];
                    2:  main_sprite_rgb = shower2[addr];
                    3:  main_sprite_rgb = shower3[addr];
                    4:  main_sprite_rgb = shower4[addr];
                    5:  main_sprite_rgb = shower5[addr];
                    6:  main_sprite_rgb = shower6[addr];
                    7:  main_sprite_rgb = shower7[addr];
                    8:  main_sprite_rgb = shower8[addr];
                    9:  main_sprite_rgb = shower9[addr];
                    10: main_sprite_rgb = shower10[addr];
                    11: main_sprite_rgb = shower11[addr];
                    default: main_sprite_rgb = shower0[addr];
                endcase
            end
            
            STATE_SLEEP: begin
                case(frame)
                    0: main_sprite_rgb = sleep0[addr];
                    1: main_sprite_rgb = sleep1[addr];
                    2: main_sprite_rgb = sleep2[addr];
                    3: main_sprite_rgb = sleep3[addr];
                    4: main_sprite_rgb = sleep4[addr];
                    5: main_sprite_rgb = sleep5[addr];
                    6: main_sprite_rgb = sleep6[addr];
                    default: main_sprite_rgb = sleep0[addr];
                endcase
            end
            
            STATE_CRY: begin 
                case(frame)
                    0: main_sprite_rgb = sad0[addr];
                    1: main_sprite_rgb = sad1[addr];
                    2: main_sprite_rgb = sad2[addr];
                    3: main_sprite_rgb = sad3[addr];
                    4: main_sprite_rgb = sad4[addr];
                    5: main_sprite_rgb = sad5[addr];
                    6: main_sprite_rgb = sad6[addr];
                    default: main_sprite_rgb = sad0[addr];
                endcase
            end

            STATE_DIE: begin 
                 main_sprite_rgb = die[addr];
            end
            default: main_sprite_rgb = 12'h000;
        endcase
    end

    // Final Display Mixer
    reg [11:0] rgb;

    always @(*) begin
        rgb = 12'h000; 

        if (current_state == STATE_WELCOME) begin
            if (area51_on) rgb = area51[a51addr];
            if (bond_on)   rgb = bond[bndaddr];
        end
        else if (current_state == STATE_SCANNING) begin
            if (scan_on) rgb = scan_rgb;
        end 
        else begin
            if (sprite_on)    rgb = main_sprite_rgb;
            if (health_on)    rgb = health_rgb;
            if (food_on)      rgb = food_rgb;
            if (showerbar_on) rgb = shower_rgb; 
            if (sleepbar_on)  rgb = sleep_rgb; 
            if (in_on)        rgb = ins_rgb; 
        end
    end

    // VGA outputs
    assign vgaRed   = video_on ? rgb[11:8] : 4'b0000;
    assign vgaGreen = video_on ? rgb[7:4]  : 4'b0000;
    assign vgaBlue  = video_on ? rgb[3:0]  : 4'b0000;

endmodule