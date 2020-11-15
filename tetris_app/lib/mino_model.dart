class minoModelGenerater  {
  static List<List<int>> generate (int minoType, int minoArg) {
    List<List<int>> minoModel;
    switch(minoType){
      case 1:
      // Iミノ
      switch(minoArg){
        case 0:
        case 180:
          minoModel =
          [
            [1,1,1,1],
          ];
          break;
        case 90:
        case 270:
          minoModel =
          [
            [1],
            [1],
            [1],
            [1],
          ];
          break;
      }
      break;

      case 2:
      // Oミノ
        minoModel =
        [
          [2,2],
          [2,2],
        ];
        break;

      case 3:
      // Sミノ
        switch(minoArg){
          case 0:
            minoModel =
            [
              [0,3,3],
              [3,3,0],
              [0,0,0],
            ];
            break;
          case 90:
            minoModel =
            [
              [0,3,0],
              [0,3,3],
              [0,0,3],
            ];
            break;
          case 180:
            minoModel =
            [
              [0,0,0],
              [0,3,3],
              [3,3,0],
            ];
            break;
          case 270:
            minoModel =
            [
              [3,0,0],
              [3,3,0],
              [0,3,0],
            ];
            break;
        }
        break;

      case 4:
      // Zミノ
      switch(minoArg){
        case 0:
          minoModel =
          [
            [4,4,0],
            [0,4,4],
            [0,0,0],
          ];
          break;
        case 90:
          minoModel =
          [
            [0,0,4],
            [0,4,4],
            [0,4,0],
          ];
          break;
        case 180:
        minoModel =
        [
          [0,0,0],
          [4,4,0],
          [0,4,4],
        ];
        break;
        case 270:
          minoModel =
          [
            [0,4,0],
            [4,4,0],
            [4,0,0],
          ];
          break;
      }
      break;

      case 5:
      // Jミノ
      switch(minoArg){
        case 0:
          minoModel =
          [
            [5,0,0],
            [5,5,5],
            [0,0,0],
          ];
          break;
        case 90:
          minoModel =
          [
            [0,5,5],
            [0,5,0],
            [0,5,0],
          ];
          break;
        case 180:
          minoModel =
          [
            [0,0,0],
            [5,5,5],
            [0,0,5],
          ];
          break;
        case 270:
          minoModel =
          [
            [0,5,0],
            [0,5,0],
            [5,5,0],
          ];
          break;
      }
      break;

      case 6:
      // Lミノ
      switch(minoArg){
        case 0:
          minoModel =
          [
            [0,0,6],
            [6,6,6],
            [0,0,0],
          ];
          break;
        case 90:
          minoModel =
          [
            [0,6,0],
            [0,6,0],
            [0,6,6],
          ];
          break;
        case 180:
          minoModel =
          [
            [0,0,0],
            [6,6,6],
            [6,0,0],
          ];
          break;
        case 270:
          minoModel =
          [
            [6,6,0],
            [0,6,0],
            [0,6,0],
          ];
          break;
      }
        break;
      case 7:
      // Tミノ
      switch(minoArg){
        case 0:
          minoModel =
          [
            [0,7,0],
            [7,7,7],
            [0,0,0],
          ];
          break;
        case 90:
          minoModel =
          [
            [0,7,0],
            [0,7,7],
            [0,7,0],
          ];
          break;
        case 180:
          minoModel =
          [
            [0,0,0],
            [7,7,7],
            [0,7,0],
          ];
          break;
        case 270:
          minoModel =
          [
            [0,7,0],
            [7,7,0],
            [0,7,0],
          ];
          break;
      }
        break;
    }
    return minoModel;
  }

  /// カレントミノの回転軸を取得して返す（Iミノ、Oミノ以外）
  static List<List<int>> getAxisOfRotationWithSRS(List<List<int>> currentMinoArrangement, int minoType, int minoArg, int rotateArg, int argAfterRotation){
    // ①カレントミノを先頭から検査して、初めの0以外の位置を算出
    // ②ミノタイプとミノ角度から、回転軸までの距離を特定
    // ③ ①と②より回転軸を計算する
    // ④SRSを適用した回転軸リストを構築して返す

    /// まずは通常の回転軸を見つける
    List<int> axisPosition; // [xPos, yPos] 回転軸
    int firstNotZeroXPos;
    int firstNotZeroYPos;
    bool isDoneCheck = false;
    int yPos = 0;
    for(final sideLine in currentMinoArrangement){
      int xPos = 0;
      for(final square in sideLine){
        if(square != 0 && isDoneCheck == false){
          firstNotZeroXPos = xPos;
          firstNotZeroYPos = yPos;
          isDoneCheck = true;
        }
        xPos++;
      }
      yPos++;
    }

    List<int> adjust;
    switch(minoType){
      case 3:
      // Sミノ
        switch(minoArg){
          case 0:
            adjust = [0, 1];
            break;
          case 90:
            adjust = [0, 1];
            break;
          case 180:
            adjust = [0, 0];
            break;
          case 270:
            adjust = [1, 1];
            break;
        }
        break;

      case 4:
      // Zミノ
        switch(minoArg){
          case 0:
            adjust = [1, 1];
            break;
          case 90:
            adjust = [-1, 1];
            break;
          case 180:
            adjust = [1, 0];
            break;
          case 270:
            adjust = [0, 1];
            break;
        }
        break;

      case 5:
      // Jミノ
        switch(minoArg){
          case 0:
            adjust = [1, 1];
            break;
          case 90:
            adjust = [0, 1];
            break;
          case 180:
            adjust = [1, 0];
            break;
          case 270:
            adjust = [0, 1];
            break;
        }
        break;

      case 6:
      // Lミノ
        switch(minoArg){
          case 0:
            adjust = [-1, 1];
            break;
          case 90:
            adjust = [0, 1];
            break;
          case 180:
            adjust = [1, 0];
            break;
          case 270:
            adjust = [1, 1];
            break;
        }
        break;
      case 7:
      // Tミノ
        switch(minoArg){
          case 0:
            adjust = [0, 1];
            break;
          case 90:
            adjust = [0, 1];
            break;
          case 180:
            adjust = [1, 0];
            break;
          case 270:
            adjust = [0, 1];
            break;
        }
        break;
    }
    axisPosition = [firstNotZeroXPos + adjust[0], firstNotZeroYPos + adjust[1]];

    /// ここからSRSを適用した回転軸をリストにつめる
    List<List<int>> axisPositionListWithSRS = List<List<int>>();
    axisPositionListWithSRS.add(axisPosition); // 最初の回転軸をadd

    switch(argAfterRotation){
      case 90:
        axisPositionListWithSRS.add([axisPositionListWithSRS[0][0] - 1, axisPositionListWithSRS[0][1]]);
        axisPositionListWithSRS.add([axisPositionListWithSRS[1][0], axisPositionListWithSRS[1][1] - 1]);
        axisPositionListWithSRS.add([axisPositionListWithSRS[0][0], axisPositionListWithSRS[0][1] - 2]);
        axisPositionListWithSRS.add([axisPositionListWithSRS[3][0] - 1, axisPositionListWithSRS[3][1]]);
        break;
      case 270:
        axisPositionListWithSRS.add([axisPositionListWithSRS[0][0] + 1, axisPositionListWithSRS[0][1]]);
        axisPositionListWithSRS.add([axisPositionListWithSRS[1][0], axisPositionListWithSRS[1][1] - 1]);
        axisPositionListWithSRS.add([axisPositionListWithSRS[0][0], axisPositionListWithSRS[0][1] - 2]);
        axisPositionListWithSRS.add([axisPositionListWithSRS[3][0] + 1, axisPositionListWithSRS[3][1]]);
        break;
      case 0:
      case 180:
        int adjustXPos;
        if(rotateArg == 90){ // 右回転しようとしたとき
          adjustXPos = -1;
        } else if (rotateArg == 270){ // 左回転しようとしたとき
          adjustXPos = 1;
        }
      axisPositionListWithSRS.add([axisPositionListWithSRS[0][0] + adjustXPos, axisPositionListWithSRS[0][1]]);
      axisPositionListWithSRS.add([axisPositionListWithSRS[1][0], axisPositionListWithSRS[1][1] + 1]);
      axisPositionListWithSRS.add([axisPositionListWithSRS[0][0], axisPositionListWithSRS[0][1] + 2]);
      axisPositionListWithSRS.add([axisPositionListWithSRS[3][0] + adjustXPos, axisPositionListWithSRS[3][1]]);
        break;
    }

    return axisPositionListWithSRS;
  }

  /// カレントミノの回転軸を取得して返す（Iミノのみ）
  static List<List<int>> getStartApplyPositionOfRotation(List<List<int>> currentMinoArrangement, int minoArg, int rotateArg, int argAfterRotation){
    List<int> startApplyPosition; // [xPos, yPos] 適用開始位置

    int firstNotZeroXPos;
    int firstNotZeroYPos;
    bool isDoneCheck = false;
    int yPos = 0;
    for(final sideLine in currentMinoArrangement){
      int xPos = 0;
      for(final square in sideLine){
        if(square != 0 && isDoneCheck == false){
          firstNotZeroXPos = xPos;
          firstNotZeroYPos = yPos;
          isDoneCheck = true;
        }
        xPos++;
      }
      yPos++;
    }

    List<int> adjust;
    switch(minoArg){
      case 0:
        adjust = [2, -1];
        break;
      case 90:
        adjust = [-2, 2];
        break;
      case 180:
        adjust = [1, -2];
        break;
      case 270:
        adjust = [-1, 1];
        break;
    }

    startApplyPosition = [firstNotZeroXPos + adjust[0], firstNotZeroYPos + adjust[1]];

    /// ここからSRSを適用した回転適用開始位置をリストにつめる
    List<List<int>> startApplyPositionListWithSRS = List<List<int>>();
    startApplyPositionListWithSRS.add(startApplyPosition); // 最初の回転適用開始位置をadd

    switch(argAfterRotation){
      case 90:
        if(rotateArg == 90){ // 右回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] - 2, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] + 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] + 1]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] - 2]);
        } else if (rotateArg == 270){ // 左回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] + 1, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] - 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] + 2]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] - 1]);
        }
        break;
      case 270:
        if(rotateArg == 90){ // 右回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] + 2, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] - 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] - 1]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] + 2]);
        } else if (rotateArg == 270){ // 左回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] - 1, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] + 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] - 2]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] + 1]);
        }
        break;
      case 0:
        if(rotateArg == 90){ // 右回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] - 2, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] + 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] + 2]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] - 1]);
        } else if (rotateArg == 270){ // 左回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] + 2, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] - 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] - 1]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] + 2]);
        }
        break;
      case 180:
        if(rotateArg == 90){ // 右回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] - 1, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] + 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] - 2]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[2][0], startApplyPositionListWithSRS[2][1] + 1]);
        } else if (rotateArg == 270){ // 左回転しようとしたとき
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[0][0] + 1, startApplyPositionListWithSRS[0][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0] - 3, startApplyPositionListWithSRS[1][1]]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] + 1]);
          startApplyPositionListWithSRS.add([startApplyPositionListWithSRS[1][0], startApplyPositionListWithSRS[1][1] - 2]);
        }
        break;
    }

    return startApplyPositionListWithSRS;
  }
}