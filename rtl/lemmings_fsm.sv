module lemmings_fsm(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
    parameter LEFT=0,RIGHT=1,FALL_LEFT=2,FALL_RIGHT=3,DIG_LEFT=5,DIG_RIGHT=6,SPLAT=7;
    reg [2:0] state,next_state;
    reg [10:0] count;
    always @(posedge clk or posedge areset)
        begin
            if(areset)
                begin
                state <= LEFT;
                end
            else 
                begin
                state<=next_state;
                    if((state==FALL_LEFT)|(state==FALL_RIGHT))
                        count <= count + 1;
                    else
                        count <= 0;
                end
        end
    always @(*)
        begin
            case(state)
                LEFT:begin
                    if(!ground) next_state= FALL_LEFT;
                    else if(dig) next_state=DIG_LEFT;
                    else if(bump_left) next_state= RIGHT;
                    else next_state=LEFT;
                end
                RIGHT:begin
                    if(!ground) next_state= FALL_RIGHT;
                    else if(dig) next_state=DIG_RIGHT;
                    else if(bump_right) next_state= LEFT;
                    else next_state=RIGHT;
                end
                FALL_LEFT: begin
                    if(ground & (count < 19)) next_state = LEFT;
                    else if(ground & (count >= 19)) next_state = SPLAT;
                    else next_state = FALL_LEFT;
                    end
                FALL_RIGHT:begin
                    if(ground & (count < 19)) next_state= RIGHT;   
                    else if(ground & (count >= 19)) next_state=SPLAT;
                    else next_state=FALL_RIGHT;
                end
                DIG_LEFT:begin
                    if(!ground) next_state= FALL_LEFT;
                    else next_state=DIG_LEFT;
                end
                DIG_RIGHT:begin
                    if(!ground) next_state= FALL_RIGHT;
                    else next_state=DIG_RIGHT;
                end
                SPLAT: next_state=SPLAT;
            endcase
        end
    assign walk_left=(state==LEFT);
    assign walk_right=(state==RIGHT);
    assign aaah=(state==FALL_LEFT)|(state==FALL_RIGHT);
    assign digging=(state==DIG_LEFT)|(state==DIG_RIGHT);

endmodule
