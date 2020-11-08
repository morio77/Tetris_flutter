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
    isGameOver = false;
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

    /// ミノ作成（タイプと角度をランダムに）
    currentMinoType = math.Random().nextInt(7) + 1; // ミノのタイプ
    currentMinoArg = (math.Random().nextInt(4) + 1) * 90; // ミノの初期角度

    /// ミノモデルから配列を取得
    List<List<int>> minoModel = minoModelGenerater.generate(currentMinoType, currentMinoArg);

    /// ミノモデルの行がすべて0の行を削除しておく
    int deleteLineNumber = 0;
    minoModel.forEach((sideLine) {
      if(sideLine.every((square) => square == 0)){
        deleteLineNumber++;
      }
    });
    for(int i = 0; i < deleteLineNumber ; i++){
      minoModel.removeAt(i);
    }

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

    notifyListeners();
    return true;
  }

  /// =====================
  /// カレントミノを右に90度回転する
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
  /// 回転させたら、カレントミノが左端に衝突するか？
  /// =====================
  bool _isCollideLeftWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
    if(xPos - relativePosition[0] < 0){
      return true;
    }
    else{
      return false;
    }
  }

  /// =====================
  /// 回転させたら、カレントミノが右端に衝突するか？
  /// =====================
  bool _isCollideRightWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
    // カレントミノの0以外の初めての位indexの列番号から適用開始位置を算出して、
    // 回転後のミノの列数を足したものがフィールドからはみ出たら(10を超えたら) false
    if(xPos - relativePosition[0] + rotateMinoModel[0].length > currentMinoArrangement[0].length){
      return true;
    }
    else{
      return false;
    }
  }

  /// =====================
  /// 回転させたら、カレントミノがフィックスミノに衝突するか？
  /// =====================
  bool _isCollideFixMinoWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
    int applyStartXPos = xPos + relativePosition[0];
    int applyStartYPos = yPos + relativePosition[1];
    int adjustYPos = 0; // 適用開始位置からの相対xPos
    try {
      for(final sideLine in rotateMinoModel){
        int adjustXPos = 0; // 適用開始位置からの相対yPos
        for(final square in sideLine){
          if(square != 0 && fixMinoArrangement[applyStartYPos + adjustYPos][applyStartXPos + adjustXPos] != 0){
            return true;
          }
          adjustXPos++;
        }
        adjustYPos++;
      }
    } catch (e) {
      // インデックスエラーとかでエラーしたら回転不可（なんとかせねばなー）
      return true;
    }
    return false;
  }

  // /// =====================
  // /// カレントミノを回転させられるか確認して、回転したミノ配置できるカレントミノからの相対位置を返す
  // /// ToDo：SRSで回せるならどのパターンで回せるかを返す
  // /// Memo：https://tetrisch.github.io/main/srs.html
  // /// =====================
  // List<int> _getRotateMinoPosition(List<List<int>> rotateMinoModel, int rotateArg,) {
  //   // カレントミノを先頭から検査して、初めて0以外があった位置から、決められた相対位置に回転後のミノを適用してみる
  //   // （下端・左右端・上端・フィックスミノにぶつからないかチェックするべき）
  //   // 適用する相対位置は、ミノタイプと今のミノの角度から算出する（のちのちSRSもこのシステムでいけるかも）
  //
  //   List<int> result;
  //
  //   // まずは右回転だけで考える
  //   switch(currentMinoType){
  //     case 1:
  //     // Iミノ
  //       switch(currentMinoArg){
  //         case 0:
  //           result = [2,-1];
  //           break;
  //         case 90:
  //           result = [-2,2];
  //           break;
  //         case 180:
  //           result = [1,-2];
  //           break;
  //         case 270:
  //           result = [-1,1];
  //           break;
  //       }
  //       break;
  //     case 3:
  //     // Sミノ
  //       switch(currentMinoArg){
  //         case 0:
  //           result = [0,0];
  //           break;
  //         case 90:
  //           result = [0,1];
  //           break;
  //         case 180:
  //           result = [-1,-1];
  //           break;
  //         case 270:
  //           result = [1,0];
  //           break;
  //       }
  //       break;
  //
  //     case 4:
  //     // Zミノ
  //       switch(currentMinoArg){
  //         case 0:
  //           result = [2,0];
  //           break;
  //         case 90:
  //           result = [-2,1];
  //           break;
  //         case 180:
  //           result = [1,-1];
  //           break;
  //         case 270:
  //           result = [-1,0];
  //           break;
  //       }
  //       break;
  //
  //     case 5:
  //     // Jミノ
  //       switch(currentMinoArg){
  //         case 0:
  //           result = [1,0];
  //           break;
  //         case 90:
  //           result = [-1,1];
  //           break;
  //         case 180:
  //           result = [1,-1];
  //           break;
  //         case 270:
  //           result = [-1,0];
  //           break;
  //       }
  //       break;
  //
  //     case 6:
  //     // Lミノ
  //       switch(currentMinoArg){
  //         case 0:
  //           result = [-1,0];
  //           break;
  //         case 90:
  //           result = [-1,1];
  //           break;
  //         case 180:
  //           result = [0,-1];
  //           break;
  //         case 270:
  //           result = [2,0];
  //           break;
  //       }
  //       break;
  //
  //     case 7:
  //     // Tミノ
  //       switch(currentMinoArg){
  //         case 0:
  //           result = [0,0];
  //           break;
  //         case 90:
  //           result = [-1,1];
  //           break;
  //         case 180:
  //           result = [1,-1];
  //           break;
  //         case 270:
  //           result = [0,0];
  //           break;
  //       }
  //       break;
  //   }
  //
  //   /// 適用してみて、いけるならその値を返す。無理ならresultをクリアして返す
  //   /// ToDo 無理でも、SRSを試してみる。
  //   int yPos = 0;
  //   for(final sideLine in currentMinoArrangement){
  //     int xPos = 0;
  //     for(final square in sideLine){
  //       if(square != 0){ // ここがカレントミノの初めての0以外の位置
  //         if( _isCollideBottomWhenRotate(xPos, yPos, result, rotateMinoModel ) == true || // 回転後のカレントミノが下端にぶつからないか検査
  //             _isCollideLeftWhenRotate(xPos, yPos, result, rotateMinoModel)    == true || // 回転後のカレントミノが左端にぶつからないか検査
  //             _isCollideRightWhenRotate(xPos, yPos, result, rotateMinoModel)   == true || // 回転後のカレントミノが右端にぶつからないか検査
  //             _isCollideFixMinoWhenRotate(xPos, yPos, result, rotateMinoModel) == true    // 回転後のカレントミノがフィックスミノにぶつからないか検査
  //         ) {
  //           // 回転させたら衝突するので、resultをクリアしてreturn
  //           result.clear();
  //           return result;
  //         }
  //         else{
  //           // 回転しても衝突しない
  //           return result;
  //         }
  //       }
  //       xPos++;
  //     }
  //     yPos++;
  //   }
  // }

  // /// =====================
  // /// 回転させたら、カレントミノが下端に衝突するか？
  // /// xPos：カレントミノの0以外の初めてのindexの列番号
  // /// yPos：カレントミノの0以外の初めてのindexの行番号
  // /// relativePosition：回転後のミノをカレントミノの0意外の先頭位置からどこに適用するか
  // /// =====================
  // bool _isCollideBottomWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
  //   if (yPos + relativePosition[1] + rotateMinoModel.length > currentMinoArrangement.length){
  //     return true;
  //   }
  //   else {
  //     return false;
  //   }
  // }
  //
  // /// =====================
  // /// 回転させたら、カレントミノが左端に衝突するか？
  // /// xPos：カレントミノの0以外の初めてのindexの列番号
  // /// yPos：カレントミノの0以外の初めてのindexの行番号
  // /// relativePosition：回転後のミノをカレントミノの0意外の先頭位置からどこに適用するか
  // /// =====================
  // bool _isCollideLeftWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
  //   if(xPos - relativePosition[0] < 0){
  //     return true;
  //   }
  //   else{
  //     return false;
  //   }
  // }
  //
  // /// =====================
  // /// 回転させたら、カレントミノが右端に衝突するか？
  // /// xPos：カレントミノの0以外の初めてのindexの列番号
  // /// yPos：カレントミノの0以外の初めてのindexの行番号
  // /// relativePosition：回転後のミノをカレントミノの0意外の先頭位置からどこに適用するか
  // /// =====================
  // bool _isCollideRightWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
  //   // カレントミノの0以外の初めての位indexの列番号から適用開始位置を算出して、
  //   // 回転後のミノの列数を足したものがフィールドからはみ出たら(10を超えたら) false
  //   if(xPos - relativePosition[0] + rotateMinoModel[0].length > currentMinoArrangement[0].length){
  //     return true;
  //   }
  //   else{
  //     return false;
  //   }
  // }
  //
  // /// =====================
  // /// 回転させたら、カレントミノがフィックスミノに衝突するか？
  // /// xPos：カレントミノの0以外の初めてのindexの列番号
  // /// yPos：カレントミノの0以外の初めてのindexの行番号
  // /// relativePosition：回転後のミノをカレントミノの0意外の先頭位置からどこに適用するか
  // /// =====================
  // bool _isCollideFixMinoWhenRotate(int xPos, int yPos, List<int> relativePosition, List<List<int>> rotateMinoModel) {
  //   int applyStartXPos = xPos + relativePosition[0];
  //   int applyStartYPos = yPos + relativePosition[1];
  //   int adjustYPos = 0; // 適用開始位置からの相対xPos
  //   try {
  //     for(final sideLine in rotateMinoModel){
  //       int adjustXPos = 0; // 適用開始位置からの相対yPos
  //       for(final square in sideLine){
  //         if(square != 0 && fixMinoArrangement[applyStartYPos + adjustYPos][applyStartXPos + adjustXPos] != 0){
  //           return true;
  //         }
  //         adjustXPos++;
  //       }
  //       adjustYPos++;
  //     }
  //   } catch (e) {
  //     // インデックスエラーとかでエラーしたら回転不可（なんとかせねばなー）
  //     return true;
  //   }
  //   return false;
  // }

  /// =====================
  /// カレントミノを左に90度回転する
  /// return：動かせたらtrue、動かせなかったらfalse
  /// =====================
  bool rotateLeftCurrentMino() {
    // カレントミノのタイプを取得

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
        title: Text(Provider.of<MinoState>(context, listen: true).currentMinoType.toString() + "：" + Provider.of<MinoState>(context, listen: true).currentMinoArg.toString()),
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).startTimer(225);
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "moveLeft",
            child: Icon(Icons.arrow_left),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(-1);
            },
          ),
          FloatingActionButton(
            heroTag: "rotateLeft",
            // child: Text("左回転"),
            child: Icon(Icons.rotate_left),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).rotateRightCurrentMino(270);
            },
          ),
          FloatingActionButton(
            heroTag: "rotateRight",
            // child: Text("右回転"),
            child: Icon(Icons.rotate_right),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).rotateRightCurrentMino(90);
            },
          ),
          FloatingActionButton(
            heroTag: "moveRight",
            child: Icon(Icons.arrow_right),
            onPressed: () {
              Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(1);
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