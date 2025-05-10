module    mult
    #(parameter N = 4,
      parameter M = 4)
     (
      input                     clk,
      input                     rstn,       // NOT reset
      input                     data_rdy ,  //input come
      input [N-1:0]             mult1,      
      input [M-1:0]             mult2,      

      output                    result_rdy ,   //output come
      output [N+M-1:0]          result         
      );

    //calculate counter
    reg [31:0]           cnt ;
    
    wire [31:0]          cnt_temp = (cnt == M)? 'b0 : cnt + 1'b1 ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt    <= 'b0 ;
        end
        else if (data_rdy) begin    //data come, counter starts
            cnt    <= cnt_temp ;
        end
        else if (cnt != 0 ) begin  
            cnt    <= cnt_temp ;
        end
        else begin
            cnt    <= 'b0 ;
        end
    end

    //multiply
    reg [M-1:0]          mult2_shift ;
    reg [M+N-1:0]        mult1_shift ;
    reg [M+N-1:0]        mult1_acc ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mult2_shift    <= 'b0 ;
            mult1_shift    <= 'b0 ;
            mult1_acc      <= 'b0 ;
        end
        else if (data_rdy && cnt=='b0) begin  //initialization
            mult1_shift    <= {{(M){1'b0}}, mult1} << 1 ;  
            mult2_shift    <= mult2 >> 1 ;  
            mult1_acc      <= mult2[0] ? {{(M){1'b0}}, mult1} : 'b0 ;
        end
        else if (cnt != M) begin
            mult1_shift    <= mult1_shift << 1 ;  
            mult2_shift    <= mult2_shift >> 1 ;  
            
            mult1_acc      <= mult2_shift[0] ? mult1_acc + mult1_shift : mult1_acc ;
        end
        else begin
            mult2_shift    <= 'b0 ;
            mult1_shift    <= 'b0 ;
            mult1_acc      <= 'b0 ;
        end
    end

    //results
    reg [M+N-1:0]        result_temp ;
    reg                  result_rdy_temp ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            result_temp          <= 'b0 ;
            result_rdy_temp      <= 'b0 ;
        end  
        else if (cnt == M) begin
            result_temp          <= mult1_acc ;  //???????????
            result_rdy_temp      <= 1'b1 ;
        end
        else begin
            result_temp          <= 'b0 ;
            result_rdy_temp      <= 'b0 ;
        end
    end

    assign result_rdy       = result_rdy_temp;
    assign result           = result_temp;

endmodule
