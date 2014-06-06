
module forward(  src1_addrEX,src2_addrEX,reg_writeMEM,reg_waddrMEM,
	             reg_writeFB,reg_waddrFB,is_ForwordA,sel_ForwordA,is_ForwordB,sel_ForwordB );
	
    //input output list
    //-----------------------------------------------------------------------------------------------------------	
    input [`REGADDR_WIDTH-1:0]src1_addrEX;
	input [`REGADDR_WIDTH-1:0]src2_addrEX;
	input reg_writeMEM;
	input [`REGADDR_WIDTH-1:0]reg_waddrMEM;
	input reg_writeFB;
	input [`REGADDR_WIDTH-1:0]reg_waddrFB;
    
	output reg is_ForwordA;
	output reg sel_ForwordA;
	output reg is_ForwordB;
	output reg sel_ForwordB;
	
	//===========================================================================================================
    //forwarding seletion for src1
    //-----------------------------------------------------------------------------------------------------------
	always@(src1_addrEX,reg_writeMEM,reg_waddrMEM,reg_writeFB,reg_waddrFB)begin
	    if(reg_writeMEM&&src1_addrEX==reg_waddrMEM)begin
		    is_ForwordA=`TRUE;
			sel_ForwordA=0;
			end
		else if(reg_writeFB&&src1_addrEX==reg_waddrFB)begin
		    is_ForwordA=`TRUE;
			sel_ForwordA=1;
		    end
		else begin
		    is_ForwordA=`FALSE;
			sel_ForwordA=0;
		end
	end
    //===========================================================================================================
	
	//===========================================================================================================
    //forwarding seletion for src2
    //-----------------------------------------------------------------------------------------------------------
	always@(src2_addrEX,reg_writeMEM,reg_waddrMEM,reg_writeFB,reg_waddrFB)begin
	    if(reg_writeMEM&&src2_addrEX==reg_waddrMEM)begin
		    is_ForwordB=`TRUE;
			sel_ForwordB=0;
			end
		else if(reg_writeFB&&src2_addrEX==reg_waddrFB)begin
		    is_ForwordB=`TRUE;
			sel_ForwordB=1;
		    end
		else begin
		    is_ForwordB=`FALSE;
			sel_ForwordB=0;
		end
	end
	//===========================================================================================================
	
endmodule
