`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Sabanci University
// Engineer: 		Ahmet Mihca Aydin
// 
// Create Date:    21:11:02 01/03/2021 
// Design Name: 	 A Simple Telephone Conversation
// Module Name:    tel 
// Project Name:   CS303 Term Project
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module tel( // Everybody should use same variables for these lines!
    
	 input clk,
    input rst,
    input startCall, 					// 1, 0
    input answerCall, 					// 1, 0
    input endCallCaller, 				// 1, 0
    input endCallCallee, 				// 1, 0 
    input sendCharCaller, 				// 1, 0
    input sendCharCallee, 				// 1, 0
    input [7:0] charSent, 				// "a" , "x" (8-bit = 1 char) 
    output reg [63:0] statusMsg, 	// (64-bit) = 8 char "xyzt..."
    output reg [63:0] sentMsg 		// (64-bit) = 8 char "xyzt..."
    );
	 
		
	parameter IDLE = 3'd0;				//000 --> S0: IDLE
	parameter RINGING = 3'd1;			//001 --> S1: RINGING
	parameter REJECTED = 3'd2;  		//010 --> S2: REJECTED
	parameter CALLER_SEND = 3'd3;		//011 --> S3: CALLER SEND
	parameter CALLEE_SEND = 3'd4; 	//100 --> S4: CALLEE SEND
	parameter COST = 3'd5;        	//101 --> S5: COST

// for outputs								
	parameter IDLE_OUT = "IDLE    ";
	parameter RINGING_OUT = "RINGING ";
	parameter REJECTED_OUT = "REJECTED";
	parameter CALLER_OUT = "CALLER  ";
	parameter CALLEE_OUT = "CALLEE  ";
	parameter COST_OUT = "COST    ";
							
	reg [2:0] state = IDLE;							
	reg [2:0] next_state = IDLE;
	reg start_counter = 0;
	reg [3:0] counter = 0;
	reg [1:0] cost_inc = 0;
	reg [31:0] cost = 0;
	//reg [7:0] val; didn't neccessary 


// Sequential Part For State Tranistions
always @(posedge clk or posedge rst)  
begin                      
	if(rst) 
		state <= IDLE; 					// whole code [till *] is received from verilog III - recitation
	else 
		state <= next_state;
end
/*
		IF rst = 1, it will go IDLE from every state
*/

// state transitions to code							
// comb. part for state transitions
always @*
begin
	case(state)
	
	IDLE: //S0
	begin
		start_counter = 0;
		if(startCall)
			next_state = RINGING;
		else 
			next_state = IDLE;
	end
	
	RINGING: //S1
	begin
		start_counter = 1;
		if(endCallCaller | counter >= 9)
			next_state = IDLE;
		
		else if(endCallCallee)
		begin
			next_state = REJECTED;
			start_counter = 0;
		end
		
		else if(answerCall)
		begin
			next_state = CALLER_SEND;
			start_counter = 0;
		end	
		else 
			next_state = RINGING;	
	end
	
	REJECTED: //S2
	begin
		start_counter = 1;
		if(counter >= 9)
			next_state = IDLE;
		else 
			next_state = REJECTED;
	end
	
	CALLER_SEND: //S3
	begin
		start_counter = 0;
		if(endCallCallee | endCallCaller)
			next_state = COST;
		
		else if(charSent == 8'd127 && sendCharCaller)
			next_state = CALLEE_SEND;
			
		else
			next_state = CALLER_SEND;
	
	end
	
	CALLEE_SEND: //S4
	begin
		start_counter = 0;
		if(endCallCallee | endCallCaller)
			next_state = COST;
			
		else if(charSent == 8'd127 && sendCharCallee)
			next_state = CALLER_SEND;
			
		else
			next_state = CALLEE_SEND;
	end
	
	COST: // S5
	begin
		start_counter = 1;
		if(counter >= 4)
			next_state = IDLE;
		else 
			next_state = COST;
	end
	
	default:
	begin
		start_counter = 0;
		next_state = IDLE;
	end
	endcase
end

always @* //for outputs 
begin
	cost_inc = 0;

	case(state)
	IDLE: 
	begin
		statusMsg = IDLE_OUT;
	end
	
	RINGING:
	begin
		statusMsg = RINGING_OUT;
	end 
	
	REJECTED:
	begin
		statusMsg = REJECTED_OUT;
	end
	
	CALLER_SEND:
	begin
		statusMsg = CALLER_OUT;
		if((charSent == 8'd127) & (sendCharCallee)) 
			cost_inc = 2;
		else if(sendCharCaller)
		begin
			if((charSent >= 8'd48) & (charSent <= 8'd57)) // checking if it's numer?
				cost_inc = 1;
			else if(((charSent >= 8'd32) & (charSent <= 8'd47)) || ((charSent >= 8'd58) & (charSent <= 8'd127))) // [IF] - NUMBERS = CHARS COST
				cost_inc = 2;
			else 
				cost_inc = 0;
		end
	
		else
		begin
			cost_inc = 0;
		end
	end
	
	CALLEE_SEND:
	begin
		statusMsg = CALLEE_OUT;
		if((charSent == 8'd127) & (sendCharCaller)) 
			cost_inc = 2;
		else if(sendCharCallee)
		begin
			if((charSent >= 8'd48) & (charSent <= 8'd57)) // checking if it's numer?
				cost_inc = 1;
			else if(((charSent >= 8'd32) & (charSent <= 8'd47)) || ((charSent >= 8'd58) & (charSent <= 8'd127))) // [IF] - NUMBERS = CHARS COST
				cost_inc = 2;
			else 
				cost_inc = 0;
		end
		else
		begin
			cost_inc = 0;
		end
	end
	
	COST:
	begin	
/*    //val: 8-bit
		val = (cost & 8'd15); 
		if ((val <10)) 
			statusMsg[7:0] = val | 8'd48;
		else
			statusMsg[7:0] = (val - 10) | 8'd64;				
		
		val = ((cost >> 4) & 8'd15);
		if ((val <10)) 
			statusMsg[15:8] = val | 8'd48;
		else
			statusMsg[15:8] = (val - 10) | 8'd64;
*/
		//https://stackoverflow.com/questions/12336139/verilog-question-mark-operator 
		// This way is simpler than the upper way!
		
		// Extracted each nibble (4-bit) and converted it to ASCII
		// If the extracted nibble is less than 10, OR it with 8'd48 --> 0011 0000
		// Otherwise I subtract 10 and OR it with 8'd64 --> 0100 0000 
		// extracted each nibble from register cost and put the corresponding ASCII character into statusMSG
		
		statusMsg[7:0] = (cost & 8'd15) < 10 ? (cost & 8'd15) | 8'd48 : ((cost & 8'd15) - 10) | 8'd64;
		statusMsg[15:8] = ((cost>>4) & 8'd15) < 10 ? ((cost>>4) & 8'd15) | 8'd48 : (((cost >> 4) & 8'd15) - 10) | 8'd64;
		statusMsg[23:16] = ((cost>> 8) & 8'd15) < 10 ? ((cost>>8) & 8'd15) | 8'd48 : (((cost >> 8) & 8'd15) - 10) | 8'd64;
		statusMsg[31:24] = ((cost>>12) & 8'd15) < 10 ? ((cost>>12) & 8'd15) | 8'd48 : (((cost >>12) & 8'd15) - 10) | 8'd64;
		statusMsg[39:32] = ((cost>>16) & 8'd15) < 10 ? ((cost>>16) & 8'd15) | 8'd48 : (((cost >>16) & 8'd15) - 10) | 8'd64;
		statusMsg[47:40] = ((cost>>20) & 8'd15) < 10 ? ((cost>>20) & 8'd15) | 8'd48 : (((cost >>20) & 8'd15) - 10) | 8'd64;
		statusMsg[55:48] = ((cost>>24) & 8'd15) < 10 ? ((cost>>24) & 8'd15) | 8'd48 : (((cost >>24) & 8'd15) - 10) | 8'd64;
		statusMsg[63:56] = ((cost>>28) & 8'd15) < 10 ? ((cost>>28) & 8'd15) | 8'd48 : (((cost >>28) & 8'd15) - 10) | 8'd64;
	end
	default: // assignments are needed in combinational always blocks
	begin
		statusMsg = IDLE_OUT;
	end
	endcase
end

always @(posedge clk or posedge rst) // cost and msg is updating process
begin
	if(rst)
	begin
		cost <= 0;
		sentMsg <= 0;
	end
	else
		begin
			cost <= cost + cost_inc;
			if(cost_inc)
				sentMsg <= {sentMsg[55:0], charSent};
			else
				sentMsg <= sentMsg;
		end
end

//the counter!
always @(posedge clk)
begin
	if(start_counter)
		counter = counter + 1;
	else
		counter = 0;
end
endmodule