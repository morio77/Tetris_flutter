import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tetris_app/mino_painter.dart';
import 'package:tetris_app/mino_model.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class MinoState extends ChangeNotifier{
  Timer timer;
  bool isGameOver = false;
  int currentMinoType;
  int currentMinoArg;
  bool hardDropFlag = false;
  double cumulativeLeftDrag = 0; // 左ドラッグした累積距離（左右移動の判定に使う）
  double cumulativeRightDrag = 0; // 右ドラッグした累積距離（左右移動の判定に使う）
  List<List<int>> currentMinoManager = []; // カレントミノのタイプと角度を順番に保持しておく
  List<int> holdMino = [];

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

  /// カレントミノの落下予測位置
  List<List<int>> fallCurrentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));

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
    fallCurrentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
    notifyListeners();
    isGameOver = false;
    holdMino.clear();
    timer = null;
  }

  void generateSevenMinos() {
    // 7種1巡の法則に従ってミノタイプとミノ角度を生成
    List<List<int>> sevenMinos = [];
    for(int i = 1 ; i <= 7 ; i++){
      sevenMinos.add([i, (math.Random().nextInt(4) + 0) * 90]);
    }
    sevenMinos.shuffle();
    sevenMinos.forEach((mino) {
      currentMinoManager.add(mino);
    });
  }

  /// =====================
  /// メインループ 始まり
  /// =====================
  void _mainRoop(Timer timer) {

    /// カレントミノがすべて0だったら、ミノを作成して、落下中のミノ配置図（カレントミノ）に反映する
    if(currentMinoArrangement.every((element) => element.every((element) => element == 0))){
      // ミノを作成して、落下中のミノ配置図（カレントミノ）に反映する
      _createMinoAndReflectCurrentMino();
      _calcCurrentMinoFallPosition(); // 落下予測位置計算
      hardDropFlag = false; // ハードドロップフラグをOFFにしておく
    }
    /// ハードドロップフラグが立っていたらハードドロップしてあげる
    else if (hardDropFlag == true){
      _hardDrop();
      hardDropFlag = false;
    }
    /// カレントミノが落下中で1マス落としても衝突しないなら、1マス落とす
    else {

      /// 1マス落とすと 下端 or フィックスミノ に衝突する場合は、カレントミノをフィックスミノに反映
      if(_isCollideBottomWhen1SquareDown() || _isCollideFixMinoWhen1SquareDown()){

        // カレントミノをフィックスミノに反映
        _reflectCurrentMinoInFixMino();

        // フィックスミノの行がそろっていたら行を消す
        _deleteFixMinoSideLineIfPossible();

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

    // /// ミノ作成（タイプと角度をランダムに）
    // currentMinoType = math.Random().nextInt(7) + 1; // ミノのタイプ
    // currentMinoArg = (math.Random().nextInt(4) + 1) * 90; // ミノの初期角度

    currentMinoType = currentMinoManager[0][0];
    currentMinoArg = currentMinoManager[0][1];

    /// ミノモデルから配列を取得
    List<List<int>> minoModel = minoModelGenerater.generate(currentMinoType, currentMinoArg);
    currentMinoManager.removeAt(0);
    if(currentMinoManager.length < 14){
      generateSevenMinos();
    }

    // /// ミノモデルの行がすべて0の行を削除しておく
    // int deleteLineNumber = 0;
    // minoModel.forEach((sideLine) {
    //   if(sideLine.every((square) => square == 0)){
    //     deleteLineNumber++;
    //   }
    // });
    // for(int i = 0; i < deleteLineNumber ; i++){
    //   minoModel.removeAt(i);
    // }

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
  bool _isCollideBottomWhen1SquareDown() {
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
  bool _isCollideFixMinoWhen1SquareDown() {

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
  /// 削除できる行があるなら、削除する
  /// return：削除したら true, 削除しなかったら false
  /// =====================
  bool _deleteFixMinoSideLineIfPossible() {
    List<int> deleteIndex = List<int>(); // 削除する行番号のリスト

    // 削除できる行(すべてが0以外)番号を抽出
    int yPos = 0;
    for(final sideLine in fixMinoArrangement){
      if(sideLine.every((square) => square != 0)){
        deleteIndex.add(yPos);
      }
      yPos++;
    }

    // 削除実行
    if(deleteIndex.length != 0){
      deleteIndex.forEach((index) {
        fixMinoArrangement.removeAt(index);
        fixMinoArrangement.insert(0, [0,0,0,0,0,0,0,0,0,0,]);
      });
    }
    else{
      return false;
    }
    notifyListeners();
    return true;
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

    _calcCurrentMinoFallPosition(); // 落下予測位置計算

    notifyListeners();
    return true;
  }

  /// =====================
  /// カレントミノを左右に90度回転する
  /// rotateArg：右回転なら90、左回転なら270を指定
  /// return：動かせたらtrue、動かせなかったらfalse
  /// =====================
  bool rotateRightCurrentMino(int rotateArg) {
    /// 回転後の角度を求める
    int argAfterRotation = currentMinoArg + rotateArg;
    if(argAfterRotation == 360){
      argAfterRotation = 0;
    } else if (argAfterRotation > 360){
      argAfterRotation -= 360;
    }

    /// 回転後のミノモデルを取得する
    List<List<int>> rotateMinoModel;
    rotateMinoModel = minoModelGenerater.generate(currentMinoType, argAfterRotation);

    /// 回転軸を取得する
    List<int> axisOfRotation;
    List<int> startApplyPosition;
    switch(currentMinoType){
      case 1: // Iミノ
        startApplyPosition = minoModelGenerater.getStartApplyPositionOfRotation(currentMinoArrangement, currentMinoArg);
        break;

      case 2: // Oミノ
        break;

      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      axisOfRotation = minoModelGenerater.getAxisOfRotation(currentMinoArrangement, currentMinoType, currentMinoArg);
        break;
    }

    /// ミノが回転できるか判定
    switch(currentMinoType){
      case 1: // Iミノ
        if(_isCollideWhenRotateOfIMino(startApplyPosition, rotateMinoModel) == true){
          return false;
        }
        break;

      case 2: // Oミノ
        break;

      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      if(_isCollideWhenRotate(axisOfRotation, rotateMinoModel) == true){
        return false;
      }
        break;
    }

    /// ここまで来たらミノは回転可能なので回転させる
    if (currentMinoType == 2){ // アニメーションをつけるならここで?

    }
    else if (currentMinoType == 1){ // Iミノ
      currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
      int yPos = 0;
      for(final sideLine in rotateMinoModel){
        int xPos = 0;
        for(final square in sideLine){
          if(square != 0){
            currentMinoArrangement[yPos + startApplyPosition[1]][xPos + startApplyPosition[0]] = square;
          }
          xPos++;
        }
        yPos++;
      }
    }
    else{
      currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
      int yPos = 0;
      for(final sideLine in rotateMinoModel){
        int xPos = 0;
        for(final square in sideLine){
          if(square != 0){
            currentMinoArrangement[yPos + axisOfRotation[1] -1][xPos + axisOfRotation[0] -1] = square;
          }
          xPos++;
        }
        yPos++;
      }
    }

    currentMinoArg = argAfterRotation;
    _calcCurrentMinoFallPosition(); // 落下予測位置計算
    notifyListeners();
    return true;
  }

  /// =====================
  /// カレントミノを回転させられるか？（Iミノ、Oミノ以外）
  /// =====================
  bool _isCollideWhenRotate(List<int> axisOfRotation, List<List<int>> rotateMinoModel) {

    try{
      int yPos = 0;
      for(final sideLine in rotateMinoModel){
        int xPos = 0;
        for(final square in sideLine){
          if(square != 0){
            if(fixMinoArrangement[yPos + axisOfRotation[1] -1][xPos + axisOfRotation[0] -1] != 0){
              return true;
            }
          }
          xPos++;
        }
        yPos++;
      }
    }
    catch(e){
      return true;
    }

    return false;
  }

  /// =====================
  /// カレントミノを回転させられるか？（Iミノ）
  /// =====================
  bool _isCollideWhenRotateOfIMino(List<int> startApplyPosition, List<List<int>> rotateMinoModel) {

    try{
      int yPos = 0;
      for(final sideLine in rotateMinoModel){
        int xPos = 0;
        for(final square in sideLine){
          if(square != 0){
            if(fixMinoArrangement[yPos + startApplyPosition[1]][xPos + startApplyPosition[0]] != 0){
              return true;
            }
          }
          xPos++;
        }
        yPos++;
      }
    }
    catch(e){
      return true;
    }

    return false;
  }



  /// =====================
  /// カレントミノの落下予測位置を計算
  /// =====================
  void _calcCurrentMinoFallPosition() {
    // カレントミノを1マス下げてみて、下端・フィックスミノにぶつからないなら、1マス下げる
    // ぶつかるまでループして、ぶつかったら、そこが落下予測位置

    /// まず、カレントミノをコピーしておく。
    int yPos = 0;
    for (final sideLine in currentMinoArrangement){
      int xPos = 0;
      for( final square in sideLine){
        fallCurrentMinoArrangement[yPos][xPos] = square;
        xPos++;
      }
      yPos++;
    }

    /// ここからループ開始
    bool isDoneCalc = false;
    int roopCount = 0;
    while(isDoneCalc != true){
      try{

        // 落下予測位置を1マス下げたマスが、フィックスミノとぶつかるなら終了
        int yPos = 0;
        for (final sideLine in fallCurrentMinoArrangement){
          int xPos = 0;
          for( final square in sideLine){
            if(square != 0){
              if(fixMinoArrangement[yPos + 1][xPos] != 0){
                isDoneCalc = true;
              }
            }
            xPos++;
          }
          yPos++;
        }

        if(isDoneCalc == false){
          // 落下予測位置を1マス下げる
          fallCurrentMinoArrangement.insert(0, [0,0,0,0,0,0,0,0,0,0,]);
          fallCurrentMinoArrangement.removeLast();
        }

        roopCount++;
        if(roopCount >= fallCurrentMinoArrangement.length){
          isDoneCalc = true;
        }
      }
      catch(e) {
        isDoneCalc = true;
      }
    }

    notifyListeners();
  }

  /// =====================
  /// ハードドロップする
  /// =====================
  void _hardDrop() {
    // カレントミノを落下予測位置に落とすだけ。
    int yPos = 0;
    for (final sideLine in fallCurrentMinoArrangement){
      int xPos = 0;
      for( final square in sideLine){
        currentMinoArrangement[yPos][xPos] = square;
        xPos++;
      }
      yPos++;
    }
    // カレントミノをフィックスミノに反映
    _reflectCurrentMinoInFixMino();

    // フィックスミノの行がそろっていたら行を消す
    _deleteFixMinoSideLineIfPossible();

    // カレントミノを0でクリア
    currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));
    notifyListeners();
  }

  /// =====================
  /// カレントミノをHoldする・もしくは、Holdミノとカレントミノを交換する
  /// =====================
  void changeCurrentMinoToHoldMino() {
    if(holdMino.isEmpty){ /// カレントミノをHoldミノに移して、カレントミノを更新
      // カレントミノをHoldミノに移す
      holdMino.add(currentMinoType);
      holdMino.add(currentMinoArg);

      // カレントミノを更新
      currentMinoManager.removeAt(0);
      currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));

      // ミノを作成して、落下中のミノ配置図（カレントミノ）に反映する
      _createMinoAndReflectCurrentMino();
      _calcCurrentMinoFallPosition(); // 落下予測位置計算
    }
    else { /// カレントミノとHoldミノを入れ替える

      // 仮作成
      holdMino.add(currentMinoType);
      holdMino.add(currentMinoArg);

      currentMinoType = holdMino[0];
      currentMinoArg = holdMino[1];

      holdMino.removeRange(0, 2);

      currentMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => 0));

      /// 作成したミノを、落下中のミノ配置図（カレントミノ）に反映する
      int lineNumber = 0;
      int horizontalNumber;

      List<List<int>> minoModel = minoModelGenerater.generate(currentMinoType, currentMinoArg);

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

      
      _calcCurrentMinoFallPosition(); // 落下予測位置計算
      notifyListeners();

      // 未来の自分へのメモ：衝突チェックもお忘れずに
    }
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
    final Size displaySize = MediaQuery.of(context).size;
    final double playWindowHeight = displaySize.height * 0.6;
    final double playWindowWidth = playWindowHeight * 0.5;
    final double nextHoldWindowHeight = displaySize.height * 0.1;
    final double nextHoldWindowWidth = nextHoldWindowHeight;
    final double opacity = 0.1;
    final double horizontalDragThreshold= 15;
    final double verticalDragDownThreshold= 3;

    /// ミノを14個生成しておく
    Provider.of<MinoState>(context, listen: false).generateSevenMinos();
    Provider.of<MinoState>(context, listen: false).generateSevenMinos();

    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<MinoState>(context, listen: true).currentMinoType.toString() + "：" + Provider.of<MinoState>(context, listen: true).currentMinoArg.toString()),
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).startTimer(250);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).reset();
            },
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RaisedButton(
            child: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(-1);
            },
          ),
          RaisedButton(
            child: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(1);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  color: Colors.grey.withOpacity(opacity),
                  height: playWindowHeight,
                  width: playWindowWidth,
                  child: CustomPaint( /// 枠線を描画
                    painter: BoaderPainter(),
                  ),
                ),
                Container(
                  color: Colors.grey.withOpacity(opacity),
                  height: playWindowHeight,
                  width: playWindowWidth,
                  child: CustomPaint( /// フィックスしたミノ配置図
                    painter: MinoPainter(Provider.of<MinoState>(context, listen: true).fixMinoArrangement),
                  ),
                ),
                Container(
                  color: Colors.grey.withOpacity(opacity),
                  height: playWindowHeight,
                  width: playWindowWidth,
                  child: CustomPaint( /// 落下中のミノ配置図
                    painter: MinoPainter(Provider.of<MinoState>(context, listen: true).currentMinoArrangement),
                  ),
                ),
                Container(
                  color: Colors.grey.withOpacity(opacity),
                  height: playWindowHeight,
                  width: playWindowWidth,
                  child: CustomPaint( /// 落下予測位置を描画
                    painter: PredictedFallPosition(Provider.of<MinoState>(context, listen: true).fallCurrentMinoArrangement),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: displaySize.height,
            width: displaySize.width,
            child: GestureDetector(
                onTapUp: (details) { /// タップで回転させる
                  if(details.globalPosition.dx < displaySize.width * 0.5){
                    Provider.of<MinoState>(context, listen: false).rotateRightCurrentMino(270);
                  }
                  else {
                    Provider.of<MinoState>(context, listen: false).rotateRightCurrentMino(90);
                  }
                },
                onHorizontalDragUpdate: (details) { /// ドラッグで左右移動
                  final double deltaX = details.delta.dx;
                  if(deltaX < 0){
                    Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag += deltaX;
                  }
                  else {
                    Provider.of<MinoState>(context, listen: false).cumulativeRightDrag += deltaX;
                  }

                  if(Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag < -horizontalDragThreshold){
                    Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(-1);
                    Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag = 0;
                  }

                  if(Provider.of<MinoState>(context, listen: false).cumulativeRightDrag > horizontalDragThreshold){
                    Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(1);
                    Provider.of<MinoState>(context, listen: false).cumulativeRightDrag = 0;
                  }

                },
              onHorizontalDragEnd: (details) { /// ドラッグ中にが離れたら、累積左右移動距離を0にしておく
                Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag = 0;
                Provider.of<MinoState>(context, listen: false).cumulativeRightDrag = 0;
              },
              onVerticalDragUpdate: (details) { /// ハードドロップ
                  if(details.delta.dy > verticalDragDownThreshold){
                    Provider.of<MinoState>(context, listen: false).hardDropFlag = true;
                  }
              },
              onLongPress: () { /// ソフトドロップON
                Provider.of<MinoState>(context, listen: false).timer.cancel();
                Provider.of<MinoState>(context, listen: false).timer = null;
                Provider.of<MinoState>(context, listen: false).startTimer(50);
              },
              onLongPressEnd: (details) { /// ソフトドロップOFF
                Provider.of<MinoState>(context, listen: false).timer.cancel();
                Provider.of<MinoState>(context, listen: false).timer = null;
                Provider.of<MinoState>(context, listen: false).startTimer(250);
              },
            ),
          ),
          Stack( /// NEXT,HOLD枠
            children: [
              Positioned(
                left: 10.0,
                top: 20.0,
                width: nextHoldWindowWidth,
                height: nextHoldWindowHeight,
                child: GestureDetector(
                  onTap: () { /// Hold機能
                    Provider.of<MinoState>(context, listen: false).changeCurrentMinoToHoldMino();
                  },
                  child: Container(
                    height: nextHoldWindowHeight,
                    width: nextHoldWindowWidth,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: CustomPaint( /// Holdミノを描画
                        painter: Provider.of<MinoState>(context, listen: true).holdMino.isNotEmpty ? NextOrHoldMinoPainter(Provider.of<MinoState>(context, listen: true).holdMino[0], Provider.of<MinoState>(context, listen: true).holdMino[1]) : null
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10.0,
                top: 20.0,
                width: nextHoldWindowWidth,
                height: nextHoldWindowHeight,
                child: Container(
                  height: nextHoldWindowHeight,
                  width: nextHoldWindowWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: CustomPaint( /// Next1ミノを描画
                    painter: NextOrHoldMinoPainter(Provider.of<MinoState>(context, listen: true).currentMinoManager[0][0], Provider.of<MinoState>(context, listen: true).currentMinoManager[0][1]),
                  ),
                ),
              ),
              Positioned(
                right: 10.0,
                top: 20 + nextHoldWindowHeight + 20,
                width: nextHoldWindowWidth,
                height: nextHoldWindowHeight,
                child: Container(
                  height: nextHoldWindowHeight,
                  width: nextHoldWindowWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: CustomPaint( /// Next2ミノを描画
                    painter: NextOrHoldMinoPainter(Provider.of<MinoState>(context, listen: true).currentMinoManager[1][0], Provider.of<MinoState>(context, listen: true).currentMinoManager[1][1]),
                  ),
                ),
              ),
              Positioned(
                right: 10.0,
                top: 20.0 +nextHoldWindowHeight + 20 + nextHoldWindowHeight + 20,
                width: nextHoldWindowWidth,
                height: nextHoldWindowHeight,
                child: Container(
                  height: nextHoldWindowHeight,
                  width: nextHoldWindowWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: CustomPaint( /// Next3ミノを描画
                    painter: NextOrHoldMinoPainter(Provider.of<MinoState>(context, listen: true).currentMinoManager[2][0], Provider.of<MinoState>(context, listen: true).currentMinoManager[2][1]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}