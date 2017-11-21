module fpadder(output logic [31:0] sum, output logic ready,
input logic [31:0] a, input logic clock, nreset);

enum {start, loada, loadb , decode , special_cases , align_1 , align_2 ,  add , check_carry , normalize , round ,  write_output} state , next_state;

//Iternal signals ...
logic [31:0] a_int , b_int , s_int ; //to flop the seq input
logic [26:0] a_align , b_align; // 23 bits mantissa + hidden bit (1) + Guard bit + Round bit + Sticky bit = 27 bits
logic [23:0] s_mantissa ; // Sum mantissa including hidden bit, we remove that one later ...
logic [9:0] a_exp , b_exp , s_exp ; //Exponents...
logic a_sign , b_sign , s_sign; //signs..
logic [27:0] add_int; //Internal addition , we need one more bit to detect carry ...
logic guard_bit , sticky_bit , round_bit; //Additional bits for rounding and guarding in substraction. Sticky will be generated in one clock cycle as an or of the aligned operand...
logic [45:0] extended_shift;

//The FSM...
   always_ff @(posedge clock , negedge n_reset) begin : seq_fsm
      if(n_reset == 1'b0)
	state <= start;
	ready <= 1'b0 ; 
	sum <= '0;
      else
	
    case(state)
	
	start: begin
	state <= load_a;
	ready <= 1'b0;
	end
	
	load_a : begin
	a_int <= a;
	state <= load_b;
	end
	
	load_b : begin
	b_int <= a;
	state <= decode;
	end
	
	decode: begin //NOTE: We are always considering normalized numbers as input...
	
	a_align <= {1'b1 , a_int [22:0] , 3'b000};
	b_align <= {1'b1 , b_int [22:0] , 3'b000};
	//Remove bias here as well...
	a_exp <= a_int[30:23] - 127;	
	b_exp <= b_int[30:23] - 127;
	a_sign <= a_int[31];
	b_sign <= b_int[31];
	
	state <= special_cases;
	
	end

	special_cases : begin
	//Special cases handled here : NaN in any case returns NaN, infinity returns infinity with sign , 0(positive or negative) +- 0 returns 0,
    //	0 + anything returns anything.
	//NaN
	state <= align; // if nothing happens down there...
	if((a_exp == 128 && a_align [26:3] != 0 ) || (b_exp == 128 && b_align[26:23] != 0)) begin
	s_int <= '1;		
	state <= write_output;
	end
	//InF
	else if(a_exp == 128) begin
	s_int[31] <= a_sign;
	s_int[30:23] <= '1;
	s_int[22:0] <= '0;
	state <= write_output;
    end	
	else if(b_exp == 128) begin
	s_int[31] <= b_sign;
	s_int[30:23] <= '1;
	s_int[22:0] <= '0;
	state <= write_output;
    end		
	// 0 + 0
	if($signed(a_exp) == -127 && a_align[26:3] == '0 && $signed(b_exp) == -127 && b_align[26:3] == '0) begin
	s_int <= '0; //Just write all 0s ...
	state <= write_output;
	end
	else if	($signed(a_exp) == -127 && a_align[26:3] == '0) begin
	//Write b...
	s_int [31] <= b_sign;
	s_int [30:23] <= b_exp + 127;
	s_int [22:0] <= b_align [26:3];
	state <= write_output;
	end
	else if	($signed(b_exp) == -127 && b_align[26:3] == '0) begin
	//Write a...
	s_int [31] <= a_sign;
	s_int [30:23] <= a_exp + 127;
	s_int [22:0] <= a_align [26:3];
	state <= write_output;
	end	
	
	end // special_cases
	
	align : begin
	
	//This was too complicated to implement here , so we shift in an always_comb block...
    
	a_align <= a_align_int;
	b_align <= b_align_int;
	a_exp <= a_exp_int;
	b_exp <= b_exp_int;
	s_exp <= s_exp_int;
	state <= addition;
		
	end
	
	addition : begin
	
	if(a_sign == b_sign) begin // Same sign just add ...
	add_int <= a_align + b_align;
	s_sign <= a_sign;
    end	
	
	// If they have different sign then we substract the smaller from the bigger. Leading zeroes are removed on normalizing...
	else if(a_align > b_align) begin
	add_int <= a_align - b_align;
	s_sign <= a_sign;
	end
	
	else if(b_align > a_align) begin
	add_int <= b_align - a_align;
	s_sign <= b_sign;	
	end
	
	state <= check_carry;
	
	end	
	
	check_carry : begin
	
	if(add_int [27] == 1'b1) begin //We have a carry in addition, we have to shift right the result and increase the exponent... guard and other bits assigned
	s_mantissa <= add_int [27:4];
	guard_bit  <= add_int [3];
	round_bit  <= add_int [2];
	sticky_bit <= add_int[1] | add_int [0];
	s_exp <= s_exp + 1;
	end
    else begin // we are good to go, just assign the auxiliary bits and move on... (without taking the carry bit into account..)
	s_mantissa <= add_int[26:3];
	guard_bit <= add_int[2];
	round_bit <= add_int[1];
	sticky_bit <= add_int[0];
	end
	state <= normalize;
	end
	
	normalize : begin  // We check for leading 0's, and shift in this state until the result is normalized ...
	
	if(s_mantissa[23] == 1'b0) begin 
	s_mantissa = s_mantissa << 1;
	s_exp <= s_exp -1;
	s_mantissa[0] <= guard;
	guard <= round_bit;
	round_bit <= 1'b0;
	end
	else
	state <= round;	
	end
	
	round : begin 
	//Round to nearest even rules : RS 00 -> exact, do nothing. 01 -> truncate , do nothing. 11 -> add 1 , 10 -> tie , do nothing..
	if(round_bit  == 1'b1 && sticky_bit == 1'b1 )
	s_mantissa <= s_mantissa + 1;
	state <= write_output;
	end
	
	write_output : begin 
	
	sum [31] <= s_sign;
	sum [30:23] <= s_exp + 127;
	sum [22:0] <= s_mantissa [22:0];
	ready <= 1'b1;
	
	state <= start;
	end
	
	
	endcase

	
	
	always_comb begin : shift_logic
	
	extended_shift = '0;
	a_exp_int = '0;
	b_exp_int = '0;
	a_align_int = '0;
	b_align_int = '0;
	s_exp_int = '0;
	
	
	if($signed(a_exp) > $signed(b_exp)) begin
	diff = a_exp - b_exp;
	extended_shift = b_align >> diff;
	b_align_int = {extended_shift[45:23], |extended_shift[22:0]};
	b_exp_int = b_exp + diff;
    a_exp_int = a_exp;
    a_align_int = a_align;
    s_exp_int = a_exp;	
	end
	
	
	if($signed(b_exp) > $signed(a_exp)) begin
	diff = b_exp - a_exp;
	extended_shift = a_align >> diff;
	a_align_int = {extended_shift[45:23], |extended_shift[22:0]};
	a_exp_int = b_exp + diff;
    b_exp_int = b_exp;
    b_align_int = b_align;	
	s_exp_int = b_exp;
	end	
		
			
	if($signed(b_exp) == $signed(a_exp)) begin
    b_exp_int = b_exp;
    b_align_int = b_align;	
    a_exp_int = a_exp;
    a_align_int = a_align;		
	s_exp_int = a_exp;
	end
		
	end

	
   end
   
   
   
