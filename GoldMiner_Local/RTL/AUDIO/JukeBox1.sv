module JukeBox1

    (
    // Declare wires and regs :
  input logic [4:0] noteIndex,         // serial number of current note. ( maximum 31 ). noteIndex determines freqIndex and note_length, via JueBox
 
 output logic [3:0] tone,        // index to toneDecoder
 output logic [3:0] note_length,      // length of notes, in beats
 output logic silenceOutN 
 ); //  a silence note: disable sound
 

 localparam MaxMelodyLength = 6'h35;  // maximum melody length, in notes. 
	

// ************** frequencies: *************************************************************************************************
    typedef enum logic [3:0] {do_, doD, re, reD, mi, fa, faD, sol, solD, la, laD, si, do_H, doDH, re_H, silence } musicNote ;//*
//              Hex value:     0    1    2   3   4    5   6    7     8    9   A   B    C      D    E      F                  //*
// *****************************************************************************************************************************
      
   // type of frequency is musicNote   (enum)  
   // Frequency index is 0....15   
   // length is in beats ( 1 to 15 )
   // length = 0 means end of melody		

musicNote frq[(MaxMelodyLength-1'b1):0]  ;     // frq is the array of frequency indices of the melody. it includes up to 32 notes.  
logic [3:0] len[(MaxMelodyLength-1'b1):0] ;   // len is the array of note lengths , in terms of beats. it includes up to 32 notes.		

assign silenceOutN = !( tone == silence ) ; // disable sound if note is "silence"	 
	 
	 
	 
initial begin	 
    frq = '{default: 0};
	len = '{default: 0}; 

	// Sheet Music of melody: "Wizard Music" by random youtube video							     
	// First phrase
	frq[0]  =  re ;      len[0]  =  2 ;   
	frq[1]  =  la ;      len[1]  =  2 ;   
	frq[2]  =  sol;      len[2]  =  4 ;   
	frq[3]  =  fa ;      len[3]  =  2 ;   
	frq[4]  =  sol;      len[4]  =  2 ;   
	frq[5]  =  la ;      len[5]  =  2 ;   
	frq[6]  =  re ;      len[6]  =  4 ;   
	frq[7]  =  mi ;      len[7]  =  2 ;   
	frq[8]  =  fa ;      len[8]  =  4 ;   
	frq[9]  =  sol;      len[9]  =  2 ;   
	frq[10]  = fa ;     len[10]  =  2 ;   
	frq[11]  = mi ;     len[11]  =  2 ;   
	frq[12]  = re ;     len[12]  =  4 ;   

	  
	// Second phrase (repeat of first with different ending)
	frq[13]  =  re ;      len[13]  =  2 ;   
	frq[14]  =  mi ;      len[14]  =  2 ;   
	frq[15]  =  fa ;      len[15]  =  4 ;   
	frq[16]  = sol ;      len[16]  =  4 ;   
	frq[17]  =  la ;      len[17]  =  4 ;   
	frq[18]  =  la ;      len[18]  =  2 ;   
	frq[19]  = do_H;      len[19]  =  2 ;   
	frq[20]  = re_H;      len[20]  =  4 ;   
	frq[21]  = do_H;      len[21]  =  4 ;   
	frq[22]  =  la ;      len[22]  =  4 ;   
	frq[23]  = sol ;      len[23]  =  2 ;   
	frq[24]  =  la ;      len[24]  =  4 ;   
	frq[25]  = sol ;      len[25]  =  4 ;   
	frq[26]  =  fa ;      len[26]  =  4 ;   
	frq[27]  =  re ;      len[27]  =  4 ;   
	frq[28]  =  do_ ;      len[28]  =  4 ;   
	frq[29]  =  re ;      len[29]  =  4 ;  

	// end of melody:
	frq[30]  =  silence ;      len[30]  =  0 ;   
		
end // always 

assign tone   = frq[noteIndex] ;
assign note_length = len[noteIndex] ; 

 
 
endmodule

