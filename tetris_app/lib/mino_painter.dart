import 'package:flutter/material.dart';

/// ミノを描画
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

/// 枠線を描画
class BoaderPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / 20; /// 1マスの縦
    double side = size.width / 10;      /// 1マスの横

    // 横線
    for(double y = 0; y < size.height ; y += vertical){
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint());
    }

    // 縦線
    for(double x = 0; x < size.width ; x += side){
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint());
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 落下予測位置を描画
class PredictedFallPosition extends CustomPainter {
  List<List<int>> fallCurrentMinoArrangement = [];
  PredictedFallPosition(this.fallCurrentMinoArrangement);

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / 20; /// 1マスの縦
    double side = size.width / 10;      /// 1マスの横
    var paint = Paint();
    paint.color = Colors.redAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;

    double yPos = 0;
    for (final sideLine in fallCurrentMinoArrangement){
      double xPos = 0;
      for( final square in sideLine){
        if(square != 0){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , side, vertical), paint); /// 1マス分描画
          }
        xPos += side;
        }
      yPos += vertical;
      }
    }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}