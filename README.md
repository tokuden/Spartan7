# 特電Spartan7 FPGA評価ボード
特殊電子回路㈱では、産業用途の機器開発やIoT機器のプロトタイピングに最適な、Sparatn-7 FPGA評価ボードを開発しています。FPGA単体で俊敏に動く装置の開発や、MicroBlazeやRISC-Vを用いたFPGA内マイコンによるアプリの開発を応援しています。

<img src="https://github.com/tokuden/Spartan7/blob/master/img/pcball.png" width="320">

## 特徴
FPGAのほかDDR3メモリやLAN、USBなどを高密度に集積しているのに**5cm×7cm**と非常にコンパクトで、組み込み機器を開発するときに邪魔になりません。

2.54mmピッチのピンヘッダで容易に拡張できるので、拡張ボードするために基板を作成するという必要がありません。**I/Oからは64本**と、多くのアプリケーションにとって十分な数の配線を取り出すことができます。また、このI/Oは**32組のLVDS**としても使用できます。

USB2.0で毎秒40Mバイトという高速な通信を実現します。

USBのデバイスドライバと、C#で開発可能なDLLとAPIは弊社から提供します。

## 用途
- 産業用機器、組み込み機器、IoT機器のプロトタイピング
- MicroBlazeの実験・評価
- RISC-Vの実験・評価
- ZYNQより低消費電力なFPGA＆マイコン搭載機器の開発

## 仕様
### FPGA
- XC7S50-1/2/3 CSGA324Cを搭載
	- ロジックセル 52,160
	- DSPスライス 120
	- メモリ Max 2,700kb (18kb:180個 36kb:90個)

### メモリ
- DDR3L SDRAM 512MByte、666MHzアクセス
- SPI ROM 128Mbit

### USB
- ターゲット機能
- USB 2.0 HighSpeedインタフェース。In/Outともに30～40MByte/sでホストPCと通信可能
- USB-JTAG機能搭載。専用ソフトおよびMITOUJTAGからコンフィグ可能
- 曲げ力に強いUSB Mini-Bを採用

### 電源

- 5V単一電源
	- 5V USB給電 (最大500mA T.B.D.)
	- 5V ACアダプタ
	- コネクタから5V直接供給
- USB逆流防止機能付き
- FPGAの動作に必要な3.3V,1.8V,1.0V,1.5V,2.5Vをオンボードのスイッチング電源で生成
- LVDSのための2.5Vもオンボードで生成

### 汎用I/Oポート

- 64本(LVDS 32ch)
- 基板上側と基板下側でVCCIOを1.8V～3.3Vで変更可能
- 2.54mmピッチのピンヘッダを採用。万能基板やブレッドボードに挿さる。
- 5cm×7cmのカードサイズ

### その他のインタフェース

- MIPI CSI (Raspbery Piカメラなどを接続可能)
- Micro SDカードスロット
- 100BASE-TX LAN用コネクタ

# 図面
## 基板 表面

![](https://github.com/tokuden/Spartan7/blob/master/pcb/TOP.pdf)
<a href="https://github.com/tokuden/Spartan7/blob/master/pcb/TOP.pdf">クリックでPDFをダウンロード<br><img src="https://github.com/tokuden/Spartan7/blob/master/img/pcbtop.png"></a>

## 基板 裏面

![](https://github.com/tokuden/Spartan7/blob/master/pcb/BOT.pdf)
<a href="https://github.com/tokuden/Spartan7/blob/master/pcb/BOT.pdf">クリックでPDFをダウンロード<br><img src="https://github.com/tokuden/Spartan7/blob/master/img/pcbbot.png"></a>

# FPGAの設計

FPGAの設計データはここからダウンロードできます。
![](https://github.com/tokuden/Spartan7/fpga)
<a href="https://github.com/tokuden/Spartan7/fpga">クリックでプロジェクトの元をダウンロード<br><img src="https://github.com/tokuden/Spartan7/blob/master/img/fpga_design.png"></a>

## プロジェクトの作成
このアーカイブの中に、Vivadoのプロジェクト(*.xpr)やブロックデザインは含まれていません。プロジェクトとBDファイル、MIG設定ファイルはTCLスクリプトによって自動的に生成されます。

まず、以下のCMDファイルをメモ帳などで開き、Vivadoをインストールしたパスと、バージョンを書き換えます。Vivadoのバージョンは2018.3以降が必須です。

```SEGGINGS.CMD:
@SET VIVADO_PATH=D:\Xilinx\Vivado\
@SET VIVADO_VERSION=2018.3
```

もし、2018.3ではないバージョンのVivadoで開発する場合には、fpga/src/design_1_bd.tclの23行目に書かれているバージョンを書き換えてください

```
################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

open_project_gui.cmd をダブルクリックすると、Vivadoが開き、プロジェクトとBlock Designが生成されます

## プロジェクトの論理合成
VivadoでGenerate Bitstremを行うか、TCLコマンドラインに、```NahiRun```と入力してください。
