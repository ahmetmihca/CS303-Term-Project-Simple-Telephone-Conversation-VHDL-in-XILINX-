# CS303-Term-Project-Simple-Telephone-Conversation-VHDL-in-XILINX-

I designed a sequential circuit for a simple two-sided telephone conversation and implemented VHDL. 

Then, I simulated and showed its functional correctness using the Xilinx ISE tool. 

The caller will initiate a telephone conversation with the callee, and the caller will send characters to the callee (and vice versa). 

My circuit will calculate the call cost and send the cost value and the characters (sent from the caller to callee and vice versa) as outputs. 

   # Inputs # 
There will be 8 inputs in my circuitry:

 •  rst will set your circuitry to its initial state.
 
 •  startCall (1-bit) will be used by the caller and it will represent that the caller pressing a button to start a call.
 
 •  answerCall (1-bit) will be used by the callee and it will represent that the callee pressing a button to answer an incoming call.
 
 •  callerEndsCall (1-bit) will be used by the caller and it will represent that the caller pressing a button to end an ongoing/outgoing call.
 
 •  calleeEndsCall (1-bit) will be used by the callee and it will represent that the callee pressing a button to end an ongoing/incoming call.
 
 •  charSent (8-bit) will be used to define 8-bit printable ASCII character to be sent fromthe caller to the callee (and vice versa) according to printable ASCII table.
 
 •  callerSendsChar (1-bit) will be used by the caller and it will represent that the caller pressing a button to send an ASCII character (set by charSent input) to the callee.
 
 •  calleeSendsChar (1-bit) will be used by the callee and it will represent that the callee pressing a button to send an ASCII character (set by charSent input) to the callee.

# Outputs #

There will be 2 outputs in my circuitry:

  • statusMsg (64-bit) will be used to display the status of telephone using 8 printable ASCII character. For example, statusMsg output should be “IDLE “ in its initial state. More details will be provided below.

  • sentMsg (64-bit) will be used to display the last 8 printable ASCII characters sent by caller or callee. More details will be provided below.
  
  ![Screen Shot 2021-12-28 at 20 10 25](https://user-images.githubusercontent.com/58208924/147590296-5f9189ae-8c26-432a-9d11-e813767f7c20.png)

More informations you can see in: 

[TERM PROJECT LAB REPORT.pdf](https://github.com/ahmetmihca/CS303-Term-Project-Simple-Telephone-Conversation-VHDL-in-XILINX-/files/7785724/TERM.PROJECT.LAB.REPORT.pdf)

[term_project_cs303_fall2020.pdf](https://github.com/ahmetmihca/CS303-Term-Project-Simple-Telephone-Conversation-VHDL-in-XILINX-/files/7785727/term_project_cs303_fall2020.pdf)

  

