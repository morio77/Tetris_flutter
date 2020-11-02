import 'package:flutter/material.dart';

class MinoPainter extends CustomPainter {

  List<List<int>> minoArrangement = [
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
    // [0,0,0,0,0,0,0,0,0,0,],
  ];
  MinoPainter(this.minoArrangement);

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / 20; /// 1マスの縦
    double side = size.width / 10;      /// 1マスの横
    var paint = Paint();
    double yPos = 0;
    double xPos = 0;

    minoArrangement.forEach((lineList) { /// 1行分でループ
      xPos = 0;
      lineList.forEach((square) { /// 1マス分を描画
        switch(square){
          case 0:
            // 描画なし
            break;
          case 1:
          // Iミノ
            paint.color = Colors.lightBlueAccent;
            break;
          case 2:
          // Oミノ
            paint.color = Colors.yellowAccent;
            break;
          case 3:
          // Sミノ
            paint.color = Colors.greenAccent;
            break;
          case 4:
          // Zミノ
            paint.color = Colors.redAccent;
            break;
          case 5:
          // Jミノ
            paint.color = Colors.blue;
            break;
          case 6:
          // Lミノ
            paint.color = Colors.orangeAccent;
            break;
          case 7:
          // Tミノ
            paint.color = Colors.purpleAccent;
            break;
        }
        if(square != 0){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , side, vertical), paint); /// 1マス分描画
        }
        xPos += side; /// 描画位置を右に1マスずらす
      });
      yPos += vertical; /// 描画位置を下に1マスずらす
    });

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}