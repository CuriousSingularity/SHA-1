module sha_1_core(
	input logic clk, enable,
	input logic [31:0] data [15:0],
	output logic [31:0] q_result[4:0],
	output logic q_done
	);

	typedef struct {
		int unsigned Hash[5];
		int unsigned Wi;
		int unsigned Ki;
		int 			 Block;
	} HashEntry_t;
	
	function automatic void datainit(ref HashEntry_t hash, int unsigned K[4], int unsigned H[5]);
	
	hash.Block = -1;
	K[0] = 32'h5A827999;
	K[1] = 32'h6ED9EBA1;
	K[2] = 32'h8F1BBCDC;
	K[3] = 32'hCA62C1D6;

	H[0] = 32'h67452301;
	H[1] = 32'hEFCDAB89;
	H[2] = 32'h98BADCFE;
	H[3] = 32'h10325476;
	H[4] = 32'hC3D2E1F0;
	
	endfunction
	
	function automatic void stringdataclear(ref byte unsigned data[64]);
	
		for(int i = 0; i < 64; i++) begin
			data[i] = 8'd0;
		end
		
	endfunction
	
	
	function automatic void asciidataclear(ref int unsigned value[80]);
	
		for(int i = 0; i < 80; i++) begin
			value[i] = 32'd0;
		end
	
	endfunction

	
	function automatic void stringvaluator(ref byte unsigned data[64], input string str);
	
		if (str.len() != 0)
			begin 
				data[63] = (str.len()) * 8;
				for(int index = 0; index < str.len(); index++) begin
					data[index] = str[index];
				end
			end
		else
			$display("Enter Valid String");
	
	endfunction
	
	
	function automatic void bitpadding(ref byte unsigned data[64]);
	
		data[data[63]/8] = 8'h80;
	
	endfunction
	
	
	function automatic void bytetomessagepack(ref logic [31:0] data[15:0], ref int unsigned message[80]);
	
		int unsigned Index = 0, temp = 0;
		
		for(int Index = 0; Index < 80; ++Index) begin
			
			if(Index < 16)
				begin
					message[Index] = data[Index];
				end
			else
				begin
					temp = (message[Index - 3] ^ message[Index - 8] ^ message[Index - 14] ^ message[Index - 16]);
					message[Index] = ROTL(temp, 1);
				end
			
		end
		
	
	endfunction
	
	
	function int unsigned  Function_Iteration1(int unsigned  Hash1, Hash2, Hash3);

		return ((Hash1 & Hash2) ^ (~(Hash1) & Hash3));

	endfunction


	function int unsigned  Function_Iteration2(int unsigned  Hash1, Hash2, Hash3);

		return (Hash1 ^ Hash2 ^ Hash3);

	endfunction


	function int unsigned  Function_Iteration3(int unsigned  Hash1, Hash2, Hash3);

		return ((Hash1 & Hash2) ^ (Hash2 & Hash3) ^ (Hash3 & Hash1));

	endfunction


	function int unsigned  Function_Iteration4(int unsigned  Hash1, Hash2, Hash3);

		return (Hash1 ^ Hash2 ^ Hash3);

	endfunction

	
	function int unsigned  ROTL(int unsigned  NumberToRotate, integer RotateBy);

		RotateBy = RotateBy % 32;
	
		if (RotateBy)
			return ((NumberToRotate << RotateBy) | (NumberToRotate >> (32 - RotateBy)));
		else
			return NumberToRotate;

	endfunction
	
	function automatic void hashduplicate(ref int unsigned H[5], ref HashEntry_t hash);
	
	for(int i = 0; i < 5; i++) begin
		hash.Hash[i] = H[i];
	end
	
	endfunction
	
	function automatic void completeiterations(ref integer iteration, ref HashEntry_t hash, ref int unsigned ASCII[80], ref int unsigned K[4]);
	
		if(((iteration - 1) % 20) == 0)
			hash.Block = (hash.Block += 1) % 4;
		
		hash.Wi 	= ASCII[(iteration - 1)];
		hash.Ki 	= K[hash.Block];
		
		SHA_Kernel(hash);
		
	endfunction
	
	function automatic void addition_with_mainhash(ref HashEntry_t hash, ref int unsigned H[5]);
	
	for(int i = 0; i < 5; i++) begin
		hash.Hash[i] += H[i];
	end
	
	endfunction
	
	function automatic void Print(ref HashEntry_t hash);
	
	for(int i = 0; i < 5; i++) begin
		$display("%h",hash.Hash[i]);
	end
	
	endfunction
	
	function automatic void SHA_Kernel(ref HashEntry_t myHash);

		int unsigned temp_hash;
		HashEntry_t LocalHash = myHash;
		
		myHash.Hash[1]	= LocalHash.Hash[0];
		myHash.Hash[2]	= ROTL(LocalHash.Hash[1], 30);
		myHash.Hash[3]	= LocalHash.Hash[2];
		myHash.Hash[4]	= LocalHash.Hash[3];
		
		case (myHash.Block)
			0:begin
				temp_hash 		= LocalHash.Hash[4] + myHash.Wi + myHash.Ki + Function_Iteration1(LocalHash.Hash[1], LocalHash.Hash[2], LocalHash.Hash[3]);
			end
			
			1:begin
				temp_hash 		= LocalHash.Hash[4] + myHash.Wi + myHash.Ki + Function_Iteration2(LocalHash.Hash[1], LocalHash.Hash[2], LocalHash.Hash[3]);
			end
			
			2:begin
				temp_hash 		= LocalHash.Hash[4] + myHash.Wi + myHash.Ki + Function_Iteration3(LocalHash.Hash[1], LocalHash.Hash[2], LocalHash.Hash[3]);
			end
			
			3:begin
				temp_hash 		= LocalHash.Hash[4] + myHash.Wi + myHash.Ki + Function_Iteration4(LocalHash.Hash[1], LocalHash.Hash[2], LocalHash.Hash[3]);
			end
			
			default: begin
			end
		endcase
		
		myHash.Hash[0] = temp_hash + ROTL(LocalHash.Hash[0], 5);
		
	endfunction
	
	
	int unsigned K[4];
	
	int unsigned H[5];
	
	byte unsigned InputString[64];

	int unsigned ASCII[80];
	
	HashEntry_t myHash;
	
	static integer iteration = 0;
		
	always_ff@(posedge clk)
	begin
		
		if (iteration == 0)
			begin
				
				if (enable)
					begin
						q_done <= 1'b0;
						datainit(myHash,K,H);
						asciidataclear(ASCII);
						bytetomessagepack(data,ASCII);		
						hashduplicate(H, myHash);
						iteration += 1;
					end
			end
			
		else if (iteration >=1 && iteration <= 80)
			begin
				completeiterations(iteration, myHash,ASCII,K);
				iteration += 1;
			
			end
			
		else
			begin
				
				addition_with_mainhash(myHash,H);
				q_result[0] = myHash.Hash[0];
				q_result[1] = myHash.Hash[1];
				q_result[2] = myHash.Hash[2];
				q_result[3] = myHash.Hash[3];
				q_result[4] = myHash.Hash[4];
				iteration = 0;
				q_done <= 1'b1;
				
			end
	end
		
endmodule

