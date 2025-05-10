module    mult_pipeline_a
    #(parameter N=8,
      parameter M=4)
    (
      input                     clk,
      input                     rstn,
      input                     data_rdy ,
      input [N-1:0]             mult1,
      input [M-1:0]             mult2,

      output                    result_rdy ,
      output [N+M-1:0]          result );

    wire [N+M-1:0]       mult1_t [M-1:0] ; //M pipelines
    wire [M-1:0]         mult2_t [M-1:0] ;
    wire [N+M-1:0]       result_t [M-1:0] ;
    wire [M-1:0]         result_rdy_t ;

    //Initialization
    mult_pipeline_b      #(.N(N), .M(M))
    u_mult_pipeline_b
    (
      .clk              (clk),
      .rstn             (rstn),
      .data_rdy         (data_rdy),
      .mult1            ({{(M){1'b0}}, mult1}),
      .mult2            (mult2),
      .result_pre       ({(N+M){1'b0}}),
      //output
      .mult1_shift      (mult1_t[0]),
      .mult2_shift      (mult2_t[0]),
      .result           (result_t[0]),
      .result_rdy       (result_rdy_t[0]) );

    //instantiation of multi modules, using generate
    genvar               i ;
    generate  
        for(i=1; i<=M-1; i=i+1) begin
            mult_pipeline_b     #(.N(N), .M(M))
            u_mult_pipeline_b
            (
              .clk              (clk),
              .rstn             (rstn),
              .data_rdy         (result_rdy_t[i-1]),
              .mult1            (mult1_t[i-1]),
              .mult2            (mult2_t[i-1]),
              .result_pre       (result_t[i-1]), 
              
              //output                                 
              .mult1_shift      (mult1_t[i]),  
              .mult2_shift      (mult2_t[i]),  
              .result           (result_t[i]),   
              .result_rdy       (result_rdy_t[i]) );
        end
    endgenerate

    assign result_rdy       = result_rdy_t[M-1];
    assign result           = result_t[M-1];

endmodule
