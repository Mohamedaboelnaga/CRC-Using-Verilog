module CRC(
input        CLK,
input        RST,DATA,
input        ACTIVE,
output reg   CRC,VALID
);


//Parameters and Internal Wires
parameter                    DATA_WIDTH = 8;
parameter  					 SEED = 8'hD8;

reg        [DATA_WIDTH -1:0] Parallel_DATA;
reg        [3:0]             COUNTER ='d0 ;
reg        		             COUNTER_DONE;

wire                         FEEDBACK;


//FEEDBACK Signal;
assign FEEDBACK = DATA ^ Parallel_DATA[0];


//OPERTION and OUTPUT
always@(posedge CLK or negedge RST)
begin
if(!RST)
    begin
       Parallel_DATA<=SEED;
       CRC<=1'b0;
       VALID<=1'b0;
       COUNTER <= 1'b0;
       COUNTER_DONE <= 1'b1;
    end
    

 //OPERATION   
else if(ACTIVE )
    begin
	   Parallel_DATA[7]<=FEEDBACK;
	   Parallel_DATA[6]<=FEEDBACK ^ Parallel_DATA[7]; 
	   Parallel_DATA[5]<=Parallel_DATA[6];
	   Parallel_DATA[4]<=Parallel_DATA[5];
	   Parallel_DATA[3]<=Parallel_DATA[4];
	   Parallel_DATA[2]<=FEEDBACK ^ Parallel_DATA[3]; 
	   Parallel_DATA[1]<=Parallel_DATA[2];
       Parallel_DATA[0]<=Parallel_DATA[1];
        VALID<=1'b0;
      COUNTER_DONE<=0;
       COUNTER<=0;
    end

         else if(!COUNTER_DONE)
         begin
           		VALID <= 1'b1;
         		{Parallel_DATA[6:0],CRC} <= Parallel_DATA; 
	            

	            if(COUNTER =='d8)
	            begin
         		COUNTER_DONE=1'b1;
         		VALID <= 1'b0;
         		end
         		else 
         		begin 
             	COUNTER <= COUNTER + 'b1;
             	end 

         end

end

endmodule