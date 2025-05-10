`timescale 1ns/1ns

module tb_mult_pipeline;

    parameter    N=8 ;
    parameter    M=8 ;
    reg          clk, rstn;
 
   //clock
    always begin
        clk = 0 ; #5 ;
        clk = 1 ; #5 ;
    end

   //reset
    initial begin
                  rstn = 1'b0 ;
        #5 ;      rstn = 1'b1 ;
    end


    reg              data_rdy ;
    reg [N-1:0]      mult1 ;
    reg [M-1:0]      mult2 ;
    wire             result_rdy ;
    wire [N+M-1:0]   result ;

    //driver
    initial begin
        #20 ;
        @(negedge clk ) ;
        data_rdy  = 1'b1 ;
        mult1  = 25;      mult2  = 10;

        @(negedge clk ) ;      mult1  = 20;     mult2 = 8;
        @(negedge clk ) ;      mult1  = 15;     mult2 = 7;
        @(negedge clk ) ;      mult1  = 10;     mult2 = 6;
        @(negedge clk ) ;      mult1  = 5;      mult2 = 3;
        @(negedge clk ) ;      mult1  = 3;      mult2 = 2;
    
end

    //module instantiation
    mult_pipeline_a  #(.N(N), .M(M))
     u_mult2_pipeline_a
     (
      .clk              (clk),
      .rstn             (rstn),
      .data_rdy         (data_rdy),
      .mult1            (mult1),
      .mult2            (mult2),
      //output
      .result_rdy       (result_rdy),
      .result           (result ));

   //simulation stop
   initial begin
      forever begin
         #100;
         if ($time >= 1000)  $stop ;
      end
   end

endmodule
