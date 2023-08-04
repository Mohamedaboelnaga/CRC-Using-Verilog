`timescale 1ns/1ps

module CRC_tb();


///////////////////// Parameters ///////////////////////

parameter DATA_WIDTH = 8 ;
parameter Clock_PERIOD = 100 ; //10 MHZ..... 100 nsec
parameter Test_Cases = 10 ;
parameter SEED = 8'hD8; //1101_1000

//////////////////// DUT Signals ////////////////////////

reg                           CLK_tb;
reg                           RST_tb;
reg                           ACTIVE_tb;
//reg                           enable_out_tb;
reg                           DATA_tb;
wire                          CRC_tb;
wire                          VALID_tb;

//reg [DATA_WIDTH-1:0]          SEED_REGISTER;


///////////////// Loops Variables ///////////////////////

integer                       Iteration ;


/////////////////////// Memories ////////////////////////

reg    [DATA_WIDTH-1:0]   DATA_HEXA  [Test_Cases-1:0] ;
reg    [DATA_WIDTH-1:0]   Expec_Out  [Test_Cases-1:0] ;



////////////////// initial block /////////////////////// 

initial 
 begin
 
     // System Functions
     $dumpfile("CRC_tb.vcd") ;       
     $dumpvars; 
 
     // Read Input Files
     $readmemh("DATA_h.txt", DATA_HEXA);
     $readmemh("Expec_Out_h.txt", Expec_Out);

     // initialization
     initialize() ;
    // #Clock_PERIOD;

     // Test Cases
     for (Iteration=0;Iteration<Test_Cases;Iteration=Iteration+1)
       begin
           CRC_Operation(DATA_HEXA[Iteration]) ;                       // do_shift_and_XOR_operation....TASK
           Check_Out(Expec_Out[Iteration],Iteration) ;                // check output response..........TASK
       end

 #1000
 $finish ;

  end


/////////////////////// TASKS //////////////////////////


/////////////// Signals Initialization //////////////////

task initialize ;
 begin
  CLK_tb  = 'b0;
  RST_tb  = 'b0;
  ACTIVE_tb = 'b0;  
  //DATA_tb='b0;
 end
endtask


///////////////////////// RESET /////////////////////////

task reset ;
 begin
  RST_tb =  'b1;
  #(Clock_PERIOD)
  RST_tb  = 'b0;
  #(Clock_PERIOD)
  RST_tb  = 'b1;
 end
endtask


////////////////// Do CRC_Operation  ////////////////////

task CRC_Operation ;
 input  [DATA_WIDTH-1:0]     IN_Seed ;
 integer k;
 begin
   reset ();
   #(Clock_PERIOD)
   ACTIVE_tb=1'b1;
   for(k=0;k<DATA_WIDTH;k=k+1)
    begin
     	DATA_tb=IN_Seed[k];
     	#(Clock_PERIOD);
    end

    $display("Finished shifting");
    ACTIVE_tb=1'b0;
 end
endtask

////////////////// Check Out Response  ////////////////////

task Check_Out ;
 input  reg     [DATA_WIDTH-1:0]     expec_out ;
 input  integer                      Test_Num ; 

 integer i ;
 
 reg    [DATA_WIDTH-1:0]     gener_out ;

 begin
  ACTIVE_tb = 1'b0;  
  //#(Clock_PERIOD) ;
 // enable_out_tb=1;
  @(posedge VALID_tb)
  for(i=0; i<DATA_WIDTH; i=i+1)
   begin
    #(Clock_PERIOD) gener_out[i] = CRC_tb ;
   end
   if(gener_out == expec_out) 
    begin
     $display("Test Case %d is succeeded",Test_Num);
    end
   else
    begin
     $display("Test Case %d is failed", Test_Num);
    end
     //ACTIVE_tb = 1'b1;
      // enable_out_tb=0;

 end
endtask


////////////////// Clock Generator  ////////////////////

always #(Clock_PERIOD/2)  CLK_tb = ~CLK_tb ;


/////////////////// DUT Instantation ///////////////////

CRC MY_CRC(
.CLK(CLK_tb),
.RST(RST_tb),
.ACTIVE(ACTIVE_tb),
.DATA(DATA_tb),
.CRC(CRC_tb),
.VALID(VALID_tb)
//.enable_out(enable_out_tb)
);

endmodule

