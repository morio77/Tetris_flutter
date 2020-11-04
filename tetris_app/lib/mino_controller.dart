import 'package:flutter/material.dart';
import 'package:tetris_app/mino_painter.dart';
import 'package:tetris_app/mino_model.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class MinoState extends ChangeNotifier{
  Timer timer;
  bool isGameOver = false;
  /// 落下して位置が決まったすべてのミノ（フィックスミノ）
  List<List<int>> fixMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
  // ↓こんな感じなのができる
  // [
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  // ];

  /// 現在落下中のミノ（カレントミノ）
  List<List<int>> currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));

  void startTimer(int millisecond) {
      timer = timer == null ? Timer.periodic(Duration(milliseconds: millisecond), _mainRoop,) : timer;
  }

  void stopTimer() {
    timer.cancel();
  }

  void reset() {
    timer.cancel();
    fixMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
    currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
    notifyListeners();
    timer = null;
  }

  /// =====================
  /// メインループ 始まり
  /// =====================
  void _mainRoop(Timer timer){

    /// カレントミノがすべて0だったら、ミノを作成して、落下中のミノ配置図（カレントミノ）に反映する
    if(currentMinoArrangement.every((element) => element.every((element) => element == 0))){
      // ミノを作成して、落下中のミノ配置図（カレントミノ）に反映する
      _createMinoAndReflectCurrentMino();
    }
    /// カレントミノが落下中で1マス落としても衝突しないなら、1マス落とす
    else {

      /// 1マス落とすと 下端 or フィックスミノ に衝突する場合は、カレントミノをフィックスミノに反映
      if(_isCollideBottom() || _isCollideFixMino()){

        // カレントミノをフィックスミノに反映
        _reflectCurrentMinoInFixMino();

        // カレントミノを0でクリア
        currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
      }
      /// 1マス落としても大丈夫なら1マス落とす
      else{
        // カレントミノを1マス落とす
        currentMinoArrangement.insert(0, [0,0,0,0,0,0,0,0,0,0,]);
        currentMinoArrangement.removeAt(currentMinoArrangement.length -1);
      }
    }

    notifyListeners();

    /// ゲームオーバーだったら終了する
    if(isGameOver){
      stopTimer();
    }
  }
  /// =====================
  /// メインループ 終わり
  /// =====================


  /// =====================
  /// ミノを作成して、落下中のミノ配置図（カレントミノ）に反映する
  /// =====================
  void _createMinoAndReflectCurrentMino() {

    /// ミノ作成（タイプと角度をランダムに）
    int minoType = math.Random().nextInt(6) + 1; // ミノのタイプ
    int minoArg = (math.Random().nextInt(4) + 1) * 90; // ミノの初期角度

    /// ミノモデルから配列を取得
    List<List<int>> minoModel = minoModelGenerater.generate(minoType, minoArg);

    /// 作成したミノを、落下中のミノ配置図（カレントミノ）に反映する
    int lineNumber = 0;
    int horizontalNumber;
    minoModel.forEach((lineList) {
      horizontalNumber = 4;
      lineList.forEach((square) {
        if(currentMinoArrangement[lineNumber][horizontalNumber] == 0){
          currentMinoArrangement[lineNumber][horizontalNumber] = square;
        }
        horizontalNumber++;
      });
      lineNumber++;
    });
  }

  /// =====================
  /// 1マス落下させたら、カレントミノが下端に衝突するか？
  /// =====================
  bool _isCollideBottom() {
    if(currentMinoArrangement[currentMinoArrangement.length -1].every((square) => square == 0)){
      return false;
    }
    else {
      return true;
    }
  }

  /// =====================
  /// 1マス落下させたら、カレントミノがフィックスミノに衝突するか？
  /// =====================
  bool _isCollideFixMino() {

    // 1マス下げカレントミノの0以外の場所が、フィックスミノの0以外の場所とかぶったら true を返す
    int xPos = 1;
    for (final sideLine in currentMinoArrangement){
      int yPos = 0;
      for (final square in sideLine){
        if(fixMinoArrangement[xPos][yPos] != 0){
          if(square != 0) {
            return true;
          }
        }
        yPos++;
      }
      xPos++;
      if(xPos >= 20){
        return false;
      }
    }

    // 1マス下げても大丈夫なら false を返す
    return false;
  }

  /// =====================
  /// カレントミノをフィックスミノに反映
  /// =====================
  void _reflectCurrentMinoInFixMino() {
    // カレントミノをフィックスミノに反映する
    int xPos = 0;
    fixMinoArrangement.forEach((sideLine) { ///カレントミノで回したほうがいいか・・・？（TBD）
      int yPos = 0;
      sideLine.forEach((square) {
        if(currentMinoArrangement[xPos][yPos] != 0){
          if(square != 0) {
            isGameOver = true;
          }
          else {
            fixMinoArrangement[xPos][yPos] = currentMinoArrangement[xPos][yPos];
          }
        }
        yPos++;
      });
      xPos++;
    });
  }

  /// =====================
  /// 指定された方向・マス数だけ、カレントミノを左(右)に動かせたら動かす
  /// moveXPos（方向）：左に動かすなら負、右に動かすなら正
  /// moveXPos（マス）：動かしたいマス分、絶対数を大きくする（現状1マスだけで使用する）
  /// return：動かせたらtrue、動かせなかったらfalse
  /// =====================
  bool moveCurrentMinoHorizon(int moveXPos) {
    /// カレントミノをmoveXPos移動させて、左右端にぶつかるなら return false
    if(moveXPos > 0){
      // カレントミノを右にmoveXPos移動させて右端にぶつかるなら return false
      for (final sideLine in currentMinoArrangement){
        for(int i = sideLine.length - 1 ; i >= sideLine.length - moveXPos ; i--){
          if(sideLine[i] != 0){
            return false;
          }
        }
      }
    }
    else if(moveXPos < 0){
      // カレントミノを右にmoveXPos移動させて右端にぶつかるなら return false
      for (final sideLine in currentMinoArrangement){
        for(int i = 0 ; i < moveXPos.abs() ; i++){
          if(sideLine[i] != 0){
            return false;
          }
        }
      }
    }
    else if(moveXPos == 0){ // ここに来るということは呼ぶ側が悪い
      return false;
    }


    /// カレントミノをmoveXPos移動させたらフィックスミノとぶつかるなら return false
    if(moveXPos > 0){
      // カレントミノを右にmoveXPos移動させてフィックスミノにぶつかるなら return false
      int yPos = 0;
      for (final sideLine in currentMinoArrangement){
        for (int i = 0 ; i < sideLine.length - moveXPos ; i ++){
          if(sideLine[i] != 0){
            if(fixMinoArrangement[yPos][i + moveXPos] != 0){
              return false;
            }
          }
        }
        yPos++;
      }
    }
    else if (moveXPos < 0){
      // カレントミノを左にmoveXPos移動させてフィックスミノにぶつかるなら return false
      int yPos = 0;
      for (final sideLine in currentMinoArrangement){
        for (int i = sideLine.length -1  ; i >= moveXPos.abs() ; i --){
          if(sideLine[i] != 0){
            if(fixMinoArrangement[yPos][i - moveXPos.abs()] != 0){
              return false;
            }
          }
        }
        yPos++;
      }
    }

    /// ここまで来たら、左右に動かせるはずなので、動かす
    if(moveXPos > 0){ // 右に動かす
      int yPos = 0;
      currentMinoArrangement.forEach((sideLine) {
        for(int i = 0 ; i < moveXPos ; i++){
          currentMinoArrangement[yPos].removeLast(); // y行目の末尾を取り除く
          currentMinoArrangement[yPos].insert(0, 0); // y行目の先頭に0を追加
        }
        yPos++;
      });
    }
    else if (moveXPos < 0){ // 左に動かす
      int yPos = 0;
      currentMinoArrangement.forEach((sideLine) {
        for(int i = 0 ; i < moveXPos.abs() ; i++){
          currentMinoArrangement[yPos].removeAt(0); // y行目の先頭を取り除く
          currentMinoArrangement[yPos].add(0); // y行目の末尾に0を追加
        }
        yPos++;
      });
    }

    notifyListeners();
    return true;
  }

  /// =====================
  /// カレントミノを右に90度回転する
  /// return：動かせたらtrue、動かせなかったらfalse
  /// =====================
  bool rotateRightCurrentMino() {

  }

  /// =====================
  /// カレントミノを左に90度回転する
  /// return：動かせたらtrue、動かせなかったらfalse
  /// =====================
  bool rotateLeftCurrentMino() {

  }
}

class MinoController extends StatelessWidget {

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MinoState>(
      create: (_) => MinoState(),
      child: TetrisPage(),
    );
  }
}

class TetrisPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    // Provider.of<MinoState>(context, listen: false).startTimer(2000);

    final Size displaySize = MediaQuery.of(context).size;
    final double height = displaySize.height * 0.7;
    final double width = height * 0.5;
    return Scaffold(
      appBar: AppBar(
        title: Text("角度のついたミノが生成"),
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).startTimer(150);
              // Provider.of<MinoState>(context, listen: false).rotateRight("ss");
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).reset();
              // Provider.of<MinoState>(context, listen: false).rotateRight("ss");
            },
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "moveLeft",
            child: Icon(Icons.arrow_left),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(-1);
            },
          ),
          FloatingActionButton(
            heroTag: "moveRight",
            child: Icon(Icons.arrow_right),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(1);
            },
          ),
          FloatingActionButton(
            heroTag: "rotateRight",
            child: Icon(Icons.rotate_90_degrees_ccw),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).rotateRightCurrentMino();
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              color: Colors.grey.withOpacity(0.3),
              height: height,
              width: width,
              child: CustomPaint( /// フィックスしたミノ配置図
                painter: MinoPainter(Provider.of<MinoState>(context, listen: true).fixMinoArrangement),
              ),
            ),
            Container(
              color: Colors.grey.withOpacity(0.3),
              height: height,
              width: width,
              child: CustomPaint( /// 落下中のミノ配置図
                painter: MinoPainter(Provider.of<MinoState>(context, listen: true).currentMinoArrangement),
              ),
            ),
          ],
        ),
      ),
    );
  }
}