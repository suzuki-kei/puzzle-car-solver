# Puzzle Car Solver

Nintendo Switch のゲーム「Puzzle Car」を解くプログラムです.

 * [Puzzle Car](https://store-jp.nintendo.com/list/software/70010000043341.html)

## フィールド定義

    <field> :: フィールド
    <field> ::= <row> (<end-of-line> <row>)*

    <row> :: フィールドの行
    <row> ::= <cell> (" " <cell>)*

    <cell> :: セル
    <cell> ::= <start> | <end> | <street> | <crossing> | <stop> | <tunnel> | <tree> | <waterway>

    <start> :: スタート地点
    <start> ::= "start(" <one-way> ")"

    <end> :: ゴール地点
    <end> ::= "end(" <one-way> ")"

    <street> :: 道路
    <street> ::= "street(" <two-way> ("," <two-way>)? ")"

    <crossing> :: 横断歩道
    <crossing> ::= "crossing(" <one-way> ")"

    <stop> :: 一時停止 (横断歩道の手前に配置する必要がある)
    <stop> ::= "stop(" <one-way> ")"

    <tunnel> :: トンネル (<id> が同じトンネル同士が繋がる)
    <tunnel> ::= "tunnel(" <id> "," <direction> ")"

    <tree> :: 木 (通行不可)
    <tree> ::= "tree"

    <waterway> :: 水路 (通行不可)
    <waterway> ::= "waterway"

    <one-way> :: 一方通行 (<from> から侵入し, <to> から退出可能)
    <one-way> ::= "{" <from> "," <to> "}"

    <two-way> :: 対面通行 (進入/退出の方向に制約がない)
    <two-way> ::= "{" <direction> "," <direction> "}"

    <from> :: 進入可能な方向
    <from> ::= "from=" <direction>

    <to> :: 退出可能な方向
    <to> ::= "to=" <direction>

    <direction> :: 方向
    <direction> ::= "top" | "bottom" | "left" | "right"

    <id> :: 識別子
    <id> ::= <number>

    <number> :: 数値
    <number> ::= <digit-without-zero> <digit-with-zero>*

    <digit-with-zero> :: 0 を含む数字
    <digit-with-zero> ::= "0" | <digit-without-zero>

    <digit-without-zero> :: 0 を含まない数字
    <digit-without-zero> ::= "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"

    <end-of-line> :: 改行
    <end-of-line> ::= %x0D %x0A

