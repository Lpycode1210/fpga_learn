// vending-machine
// 2 yuan for a bottle of drink
// only 2 coins supported: 5 jiao and 1 yuan
// finish the function of selling and changing

module  vending_machine_p2  (
    input           clk ,
    input           rstn ,     // low-level reset
    input [1:0]     coin ,     //01 for 0.5 jiao, 10 for 1 yuan

    output [1:0]    change ,
    output          sell    //output the drink
    );

    //machine state decode
    parameter            IDLE   = 3'd0 ;
    parameter            GET05  = 3'd1 ;
    parameter            GET10  = 3'd2 ;
    parameter            GET15  = 3'd3 ;

    //machine variable
    reg [2:0]            st_next ;
    reg [2:0]            st_cur ;

    //(1) state transfer
    always @(posedge clk or negedge rstn) 
    begin
        if (!rstn) begin
            st_cur      <= 'b0 ;
        end
        else begin
            st_cur      <= st_next ;
        end
    end

    //(2) state switch, and output logic
//all using block assignment for combination-logic
reg  [1:0]   change_r ;
reg          sell_r ;

always @(*) begin //all case items need to be displayed completely

    case(st_cur)
        IDLE: 
	begin
            case (coin)
                2'b01:     st_next = GET05 ;
                2'b10:     st_next = GET10 ;
                default:   st_next = IDLE ;
            endcase // case (coin)

            change_r     = 2'b0 ;
            sell_r       = 1'b0 ;
        end

        GET05: 
	begin

            case (coin)
                2'b01:     st_next = GET10 ;
                2'b10:     st_next = GET15 ;
                default:   st_next = GET05 ;
            endcase // case (coin)

            change_r     <= 2'b0 ;
            sell_r       <= 1'b0 ;
        end

        GET10:
            case (coin)
                2'b01:     
		begin
                    st_next      = GET15 ;

                    change_r     = 2'b0 ;
                    sell_r       = 1'b0 ;
                end
                2'b10:     
		begin
                    st_next      = IDLE ;

                    change_r     = 2'b0 ;
                    sell_r       = 1'b1 ;
                end
                default:   
		begin
                    st_next      = GET10 ;
                    change_r     = 2'b0 ;
                    sell_r       = 1'b0 ;
                end
            endcase // case (coin)

        GET15:
            case (coin)
                2'b01: 
		begin
                    st_next     = IDLE ;

                    change_r    = 2'b0 ;
                    sell_r      = 1'b1 ;
                end
                2'b10:     
		begin
                    st_next     = IDLE ;

                    change_r    = 2'b1 ;
                    sell_r      = 1'b1 ;
                end
                default:   
		begin
                    st_next     = GET15 ;

                    change_r    = 2'b0 ;
                    sell_r      = 1'b0 ;
                end
            endcase
        default:  
	begin
            st_next     = IDLE ;

            change_r    = 2'b0 ;
            sell_r      = 1'b0 ;
        end

    endcase
end

    assign       sell    = sell_r ;
    assign       change  = change_r ;

endmodule
