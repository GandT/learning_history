module stm(ck,rst,x);

//入出力・レジスタ宣言
input	ck,rst;
output	[3:0] x;
reg [3:0] x;
reg	st;

//状態機械
always @(posedge ck) begin
	//リセット処理
	if( rst == 1 ) begin
		st <= 0;
		x <= 0;

	//本体処理
	end else begin

		//状態0の場合
		if( st == 0 ) begin
			if( x == 0 ) st <= 1;	//状態遷移
			else x <= x-1;		//デクリメント
		end

		//状態1の場合
		else begin
			if( x == 15 ) st <= 0;	//状態遷移
			else  x<= x+1;		//インクリメント
		end
	end
end

//assign x = x;

endmodule
