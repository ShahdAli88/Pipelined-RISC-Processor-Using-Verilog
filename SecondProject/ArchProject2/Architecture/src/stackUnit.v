module  mux2x1(a,b,select,y);
input a,b,select;
output y;
reg  y;
always @ (select, a , b)
	begin
	if (select == 0)
		begin
			y = a;
		end
	else
		begin
			y = b ;
	end
end
endmodule

module mux_test();
reg a,b,select;
wire y ;
mux2x1 mux_test(a,b,select,y);      
initial
	begin
	select=0;a=0;b=0;
	#100 select=0;a=0;b=1;
	#100 select=0;a=1;b=0;
	#100 select=0;a=1;b=1;
	#100 select=1;a=0;b=0;
	#100 select=1;a=0;b=1;
	#100 select=1;a=1;b=0;
	#100 select=1;a=1;b=1;
	end	
initial
	begin
	$monitor($time,"a=%b,b=%b,select=%b,y=%b",a,b,select,y);
	end
endmodule