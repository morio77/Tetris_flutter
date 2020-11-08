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
  static getAxisOfRotation(List<List<int>> currentMinoArrangement, int minoType, int minoArg){
    // ①カレントミノを先頭から検査して、初めの0以外の位置を算出
    // ②ミノタイプとミノ角度から、回転軸までの距離を特定
    // ③ ①と②より回転軸を計算して返す

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
    return axisPosition;
  }

  /// カレントミノの回転軸を取得して返す（Iミノのみ）
  static getStartApplyPositionOfRotation(List<List<int>> currentMinoArrangement, int minoArg){
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
    return startApplyPosition;
  }
}