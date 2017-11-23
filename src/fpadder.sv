module fpadder(output logic [31:0] sum, output logic ready,
input logic [31:0] a, input logic clock, nreset);

enum {start, ready_s ,load_a, load_b , decode , special_cases , align ,  addition , check_carry , normalize , round , encode,  write_output} state , nxt_state;

//Flopped data
//Inputs
logic [31:0] a_int , b_int;
//Decoded data...
logic [26:0] a_align , b_align; // 23 bits mantissa + hidden bit (1) + Guard bit + Round bit + Sticky bit = 27 bits
logic [7:0] a_exp , b_exp , s_exp ; //Exponents...
logic a_sign , b_sign , s_sign; //signs..
//Packed output
logic [31:0] s_int;
//Internal sum, we use a 28 bit adder for 23 bits to detect the carry and nomalize ...
logic [27:0] sum_int;
//Auxiliary bits
logic sticky_bit , round_bit, guard_bit;
//Mantissa for the computed sum
logic [23:0] s_m;


//Internal signals
logic [31:0] a_int_nxt , b_int_nxt , s_int_nxt;
logic ready_nxt;
logic [26:0] a_align_nxt , b_align_nxt;
logic [7:0] a_exp_nxt , b_exp_nxt , s_exp_nxt ; //Exponents...
logic a_sign_nxt , b_sign_nxt , s_sign_nxt; //signs..
logic [23:0] s_m_nxt; //Mantissa for the computed sum ..
//logic [7:0] diff; we don't need you anymore, we are doing stuff sequentially not in parallel  :(
logic [27:0] sum_int_nxt;
logic sticky_bit_nxt , guard_bit_nxt , round_bit_nxt;
logic [31:0] sum_nxt;

   always_ff @(posedge clock , negedge nreset) begin : seq_fsm
      if(nreset == 1'b0) begin
	state <= start;
	ready <= 1'b0 ; 
	sum <= '0;
      end
      else begin
	  state <= nxt_state;
	  case(state) 
	  
	  start:
	  ready <= ready_nxt;
	  
	  ready_s:
	  ready <= ready_nxt;
	  
	  load_a : begin
	  a_int <= a_int_nxt;
	  ready <= ready_nxt;
                    end
	  load_b :
	  b_int <= b_int_nxt;	  
	  
	  decode: begin
	   a_align <= a_align_nxt;
	   b_align <= b_align_nxt;
	//Remove bias here as well...
	   a_exp  <= a_exp_nxt;	
	   b_exp  <= b_exp_nxt;
	   a_sign <= a_sign_nxt;
	   b_sign <= b_sign_nxt;
	  end
	  
	  align : begin
	  a_align <= a_align_nxt;
	  b_align <= b_align_nxt;
	  a_exp <= a_exp_nxt;
	  b_exp <= b_exp_nxt;
	  end
	  
	  addition : begin
	  
	  sum_int <= sum_int_nxt;
	  s_exp <= s_exp_nxt;
	  s_sign <= s_sign_nxt;
	  
	  end
	  
	  check_carry : begin
	  
	  guard_bit <= guard_bit_nxt;
	  round_bit <= round_bit_nxt;
	  sticky_bit <= sticky_bit_nxt;
	  s_m <= s_m_nxt;
	  s_exp <= s_exp_nxt;
	  
	  end
	  
	  normalize : begin
	  s_exp <= s_exp_nxt;
	  s_m <= s_m_nxt;
	  round_bit <= round_bit_nxt;
	  guard_bit <= guard_bit_nxt;
	  end
	  
	  round : begin
	  s_exp <= s_exp_nxt;
	  s_m <= s_m_nxt;
	  end
	  
	  encode: begin
	  s_int <= s_int_nxt;
	  end
	  
	  write_output: begin
	  sum <= sum_nxt;
	  end
	  
	  endcase
	  
	  end
    end
	
	
	//Combo logic
	always_comb begin : combo_logic
	
	a_int_nxt = '0;
	b_int_nxt = '0;
	ready_nxt = 1'b0;
	a_align_nxt = '0;
	b_align_nxt = '0;
	a_exp_nxt = '0;
	b_exp_nxt = '0;
	a_sign_nxt = '0;
	b_sign_nxt = '0;
	s_int_nxt = '0;
	//diff = '0;
        sum_int_nxt = '0;   
	guard_bit_nxt = '0;
	sticky_bit_nxt = '0;
	round_bit_nxt = '0;
	s_m_nxt = '0;
	s_exp_nxt = '0;
	s_sign_nxt ='0;
	sum_nxt ='0;
	
	
	
	case (state) 
	
	start: begin
	ready_nxt = 1'b1;
	nxt_state = ready_s;
	end
	
	ready_s : begin
	ready_nxt = 1'b1;
	nxt_state = load_a;
	end
	
	load_a: begin
	a_int_nxt = a;
	ready_nxt = 1'b0;
	nxt_state = load_b;
	end
	
	load_b: begin
	b_int_nxt = a;
	nxt_state = decode;
	end
	
	decode : begin
	
	a_align_nxt = {1'b1 , a_int [22:0] , 3'b000};
	b_align_nxt = {1'b1 , b_int [22:0] , 3'b000};
	//Remove bias here as well...
	a_exp_nxt = a_int[30:23] - 127;	
	b_exp_nxt = b_int[30:23] - 127;
	a_sign_nxt = a_int[31];
	b_sign_nxt = b_int[31];
	
	nxt_state = special_cases;	
	end
	
	
	special_cases : begin
	//Special cases handled here : NaN in any case returns NaN, infinity returns infinity with sign , 0(positive or negative) +- 0 returns 0,
    //	0 + anything returns anything.
	//NaN
	nxt_state = align; // if nothing happens down there...
	if((a_exp == 128 && a_align [26:3] != 0 ) || (b_exp == 128 && b_align[26:23] != 0)) begin
	s_int_nxt = '1;		
	nxt_state = write_output;
	end
	//InF
	else if(a_exp == 128) begin
	s_int_nxt[31] = a_sign;
	s_int_nxt[30:23] = '1;
	s_int_nxt[22:0] = '0;
	nxt_state = write_output;
    end	
	else if(b_exp == 128) begin
	s_int_nxt[31] = b_sign;
	s_int_nxt[30:23] = '1;
	s_int_nxt[22:0] = '0;
	nxt_state = write_output;
    end		
	// 0 + 0
	if($signed(a_exp) == -127 && a_align[26:3] == '0 && $signed(b_exp) == -127 && b_align[26:3] == '0) begin
	s_int_nxt = '0; //Just write all 0s ...
	nxt_state = write_output;
	end
	else if	($signed(a_exp) == -127 && a_align[26:3] == '0) begin
	//Write b...
	s_int_nxt [31] = b_sign;
	s_int_nxt [30:23] = b_exp + 127;
	s_int_nxt [22:0] = b_align [25:3];
	nxt_state = write_output;
	end
	else if	($signed(b_exp) == -127 && b_align[26:3] == '0) begin
	//Write a...
	s_int_nxt [31] = a_sign;
	s_int_nxt [30:23] = a_exp + 127;
	s_int_nxt [22:0] = a_align [25:3];
	nxt_state = write_output;
	end	
	
	end // special_cases	
	
	align : begin
    //Keep shifting until exponents are aligned increasing the exponent of the lesser.
	// The sticky bit remains as an or of the other two guys...
	if($signed(a_exp) > $signed(b_exp)) begin
	   b_exp_nxt = b_exp + 1;
	   b_align_nxt = b_align >> 1; 
	   b_align_nxt[0] = b_align[0] | b_align[1];
       nxt_state = align;	   
	   a_exp_nxt = a_exp;
	   a_align_nxt = a_align;
    end	
	else	if($signed(b_exp) > $signed(a_exp)) begin
	   a_exp_nxt = a_exp + 1;
	   a_align_nxt = a_align >> 1; 
	   a_align_nxt[0] = a_align[0] | a_align[1];
       nxt_state = align;	   
	   b_exp_nxt = b_exp;
	   b_align_nxt = b_align;
	   end
	   else //exponents are aligned... begin
	   begin
	   a_align_nxt = a_align;
	   b_align_nxt = b_align;
	   a_exp_nxt = a_exp;
	   b_exp_nxt = b_exp;
	   nxt_state = addition;
	   end
	   end
	
	addition : begin
    s_exp_nxt = b_exp; // shouldnt matter, at this stage exponents are aligned ...
	//Check the sign, if they are the same just add and put any sign ...
	if(a_sign == b_sign) begin
	s_sign_nxt = a_sign;
	sum_int_nxt = a_align + b_align;
	end
	else if(a_align > b_align) begin
	sum_int_nxt = a_align - b_align;
	s_sign_nxt = a_sign;
	end
	else begin
	sum_int_nxt = b_align - a_align;
	s_sign_nxt = b_sign;
	end
	nxt_state = check_carry;
	
	end
	
	check_carry: begin
	

    //If we have a carry, we take the first 23 bits , increment the exponent and compute the auxiliary bits. Instead of shifting ...
	// If not , we discard the carry bit , leave the 23 bit mantissa bit intact from the sum/subsract and 
    if(sum_int[27] == 1'b1) begin
	s_m_nxt = sum_int [27:4];
	guard_bit_nxt = sum_int [3];
	round_bit_nxt = sum_int [2];
	sticky_bit_nxt = sum_int[1] | sum_int[0];
	s_exp_nxt = s_exp +1;
	end
	else begin
	s_m_nxt = sum_int[26:3];
	guard_bit_nxt = sum_int[2];
	round_bit_nxt = sum_int[1];
	sticky_bit_nxt = sum_int[0];
	end
	nxt_state = normalize;
	
	end
	
   normalize : begin //keep rotating left until a 1 is spotted on the MSB, removing all leading zeroes ...
   if(s_m [23] == 1'b0) begin
   s_exp_nxt = s_exp -1;
   s_m_nxt = s_m << 1;
   s_m_nxt[0] = guard_bit; //Avoid losing one bir of the fraction when we shift...
   guard_bit_nxt = round_bit;
   round_bit_nxt = 1'b0;
   nxt_state = normalize;
   end
   else begin
   s_exp_nxt = s_exp;
   s_m_nxt = s_m;
   nxt_state = round;   
   guard_bit_nxt = guard_bit;
   round_bit_nxt = round_bit;   
   end
   end
   
   round : begin 
   //Follow the rules of round to nearest even with combination of guard , |stick,round : 11 -> add 1 else just tuncate 
   if(guard_bit == 1'b1 && (sticky_bit | round_bit)) begin // Round
   //Consider the case where s_m is all 1's, adding will cause an overflow , therefore we just leave 0's and increment the exponent...
     if(s_m == '1) begin
       s_exp_nxt = s_exp + 1;
	   s_m_nxt = '0;
     end
     else begin
       s_m_nxt = s_m +1;
	   s_exp_nxt = s_exp;
     end
   end
   else  begin //just leave as it is ..
       s_m_nxt = s_m;
       s_exp_nxt = s_exp;
    end
        
    nxt_state = encode;  
   end

   encode : begin
   s_int_nxt[31] = s_sign;
   s_int_nxt[30:23] = s_exp + 127;
   s_int_nxt[22:0] = s_m[22:0];      
   nxt_state = write_output;
   end

   write_output: begin
   
   sum_nxt = s_int;
   nxt_state = start;
   
   end
   
 
 endcase
	
end
	
endmodule
	