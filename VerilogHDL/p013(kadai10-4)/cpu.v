//16bit命令簡易マイクロプロセッサ
module CPU(CK,RST,IA,ID,DA,DD,RW);
	//入出力の割り当て
	input CK,RST;		//クロック / リセット
	input [15:0] ID;	//命令＝オペコード・オペランド列
	output 	RW;			//入力・出力判定
	output [15:0] IA,DA;//命令アドレス / データアドレス
	inout [15:0]  DD; 	//メモリからの読み出しデータ

	//レジスタ・ワイヤー宣言
	reg [15:0] 	PC, INST, FUA, FUB,			//プログラムカウンタ / ？ / 演算ユニット入力① / 演算ユニット入力②
				LSUA, LSUB, FUC, LSUC,		//ロードストアユニット入力① / ロードストアユニット入力② / 演算ユニット出力 /　ロードストアユニット出力
				PCC, PCI;					//プログラムカウンタ出力 / プログラムカウンタ入力
	reg [15:0] 	 RF[0:14];	//15個のレジスタファイル
	reg [1:0] 	 STAGE;		//フェッチ(0)→デコード(1)→実行(2)→格納(3)　の各ステージ
	reg 		 FLAG,RW;	//条件分岐用ジャンプフラグ / 入力・出力判定
	wire [15:0]　　ABUS, BBUS, CBUS;					//入力バス① / 入力バス② / 出力バス
	wire [3:0] 	 OPCODE, OPR1, OPR2, OPR3;			//オペコード / 第一オペランド / 第二オペランド / 第三オペランド 
	wire [7:0] 	 IMM;		//即値
	wire [15:0]  PCn;		//次回プログラムカウンタ

	//ワイヤー接続
	assign PCn = PC + 1;

	assign OPCODE = INST[15:12];
	assign OPR1 = INST[11:8];
	assign OPR2 = INST[7:4];
	assign OPR3 = INST[3:0];
	assign IMM = INST[7:0];
	assign ABUS = (OPR2 == 0 ? 0 : RF[OPR2]);
	assign BBUS = (OPR3 == 0 ? 0 : RF[OPR3]);
	assign DA = LSUB;
	assign IA = PC;
	assign DD =((RW==0)? LSUA : 16'b Z);
	assign CBUS = (OPCODE[3]==0 ? FUC : (OPCODE[3:1]=='b 101 ? LSUC :
					(OPCODE=='b 1100 ? {8'b 0,IMM} : OPCODE=='b 1000 ? PCC : 'b z)));
   
	//組み合わせ回路
	always @(posedge CK) begin
		//初期化
		if( RST == 1 ) begin
			PC <= 0;
			STAGE <= 0;
			RW<=1;

		//STAGE 0 ： フェッチ
		end else if( STAGE == 0 ) begin
			//命令読み込み
			INST <= ID;
			//状態遷移
			STAGE <= 1;

		//STAGE 1 ： デコード
		end else if( STAGE == 1 ) begin
			/***プログラムカウンタ操作***/
			//ジャンプ
			if( (OPCODE[3:0] == 'b 1000) || (OPCODE[3:0] == 'b 1001 && FLAG == 1 ) ) PCI <= BBUS;
			//逐次処理
			else PCI <= PCn;

			/***レジスタ設定***/
			//算術・論理演算
			if( OPCODE[3] == 0 ) begin
				//レジスタ設定
				FUA <= ABUS;
				FUB <= BBUS;
			//ロード・ストア
			end else if( OPCODE[2:1] == 'b01) begin
				//レジスタ設定
				LSUA <= ABUS;
				LSUB <= BBUS;
			end

			//状態遷移
			STAGE <= 2;

		//STAGE 2 ： 実行
		end else if( STAGE == 2 ) begin
			//算術演算
			if( OPCODE[3] == 0 ) begin
				case(OPCODE[2:0])
				  'b 000: FUC<=FUA+FUB;
				  'b 001: FUC<=FUA-FUB;
				  'b 010: FUC<=FUA>>FUB;
				  'b 011: FUC<=FUA<<FUB;
				  'b 100: FUC<=FUA|FUB;
				  'b 101: FUC<=FUA&FUB;
				  'b 110: FUC<=~FUA;
				  'b 111: FUC<=FUA^FUB;
				endcase
			//ロード・ストア
			end else if( OPCODE[3:1] == 'b 101 ) begin
				//ストア
				if( OPCODE[0] == 0 ) begin
					RW <= 0;		//データバス書き出しモード
					DD <= LSUA;
				//ロード
				end else begin
					RW <= 1;		//データバス読み出しモード
					LSUC <= DD;
				end
			//無条件ジャンプ
			end else if( OPCODE[3:0] == 'b 1000 ) PCC <= PCn;

			//状態遷移
			STAGE <= 3;

		//STAGE 3 ： 格納
		end else if( STAGE == 3 ) begin
			RW <= 1;				//レジスタ書き込みモード
			//算術演算
			if( OPCODE[3] == 0 ) begin
				CBUS <= FUC;
				if( CBUS == 0 ) FLAG <= 1;	//jz命令の設定
				else FLAG <= 0;				//jz命令の解除
			end
			//ロード・ストア
			else if( OPCODE[3:1] == 'b 101 )CBUS <= LSUC;
			//下位ビットセット出力
			else if( OPCODE[3:0] == 'b 1100)CBUS <= {8'b 0,IMM};
			//無条件ジャンプ
			else if( OPCODE[3:0] == 'b 1000)CBUS <= PCC;

			//レジスタ操作
			RF[OPR1] <= CBUS;

			//プログラムカウンタ操作
			PC <= PCI;

			//状態遷移
			STAGE <= 0;
		end
	end
endmodule
