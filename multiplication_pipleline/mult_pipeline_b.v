
module    mult_pipeline_b
    #(parameter N=8,
      parameter M=4)
    (
      input                     clk,
      input                     rstn,
      input                     data_rdy,
      input [M+N-1:0]           mult1,      
      input [M-1:0]             mult2,      
      input [M+N-1:0]           result_pre, 

      output reg [M+N-1:0]      mult1_shift,     
      output reg [M-1:0]        mult2_shift,     
      output reg [N+M-1:0]      result,          
      output reg                result_rdy );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            result_rdy     <= 'b0 ;
            mult1_shift    <= 'b0 ;
            result         <= 'b0 ;
            mult2_shift    <= 'b0 ;
        end
        else if (data_rdy) begin
            result_rdy     <= 1'b1 ;
            mult1_shift    <= mult1 << 1 ;
            mult2_shift    <= mult2 >> 1 ;

            if (mult2[0]) begin
                result  <= result_pre + mult1 ;  
            end
            else begin
                result  <= result_pre ; 
            end
        end
        else begin
            result_rdy     <= 'b0 ;
            mult1_shift    <= 'b0 ;
            result         <= 'b0 ;
            mult2_shift    <= 'b0 ;
        end
    end

endmodule