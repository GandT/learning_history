module  count4r2(out,ck,res);
	//レジスタ・ワイヤー宣言
	output		[3:0] out;
	input		ck, res;
	reg		[3:0] q;

	//状態機械
	always @(posedge ck or negedge res) begin
		if( !res)	q<= 0;
		else		q <= q+2;
	end
	assign out = q;
endmodule
