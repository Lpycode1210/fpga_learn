`timescale 1ns/1ns

module tb_mult;
    parameter    N = 8 ;
    parameter    M = 8 ;
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

    //no pipeline
    reg                   data_rdy ;
    reg  [N-1:0]          mult1 ;
    reg  [M-1:0]          mult2 ;
    wire [M+N-1:0]        result ;
    wire                  result_rdy ;

    
    task mult_data_in ;  
        input [M+N-1:0]   mult1_task, mult2_task ;
        begin
            wait(!tb_mult.u_mult.result_rdy);  //not output state
            @(negedge clk ) ;
            data_rdy = 1'b1 ;
            mult1 = mult1_task ;
            mult2 = mult2_task ;
            @(negedge clk ) ;
            data_rdy = 1'b0 ;
            wait(tb_mult.u_mult.result_rdy); //test the output state
        end
    endtask

    
    initial begin
        #20;
        mult_data_in(25, 5 ) ;
        mult_data_in(20, 16 ) ;
        mult_data_in(8, 7 ) ;
        mult_data_in(6, 1) ;
        mult_data_in(12, 12) ;
    end

    mult  #(.N(N), .M(M))
    u_mult
    (
      .clk              (clk),
      .rstn             (rstn),
      .data_rdy         (data_rdy),
      .mult1            (mult1),
      .mult2            (mult2),
      .result_rdy       (result_rdy),
      .result           (result));

   //simulation finish
   initial begin
      forever begin
         #100;
         if ($time >= 1000)  $stop ;
      end
   end

endmodule // test
