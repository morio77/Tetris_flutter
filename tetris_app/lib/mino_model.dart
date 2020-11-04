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
          case 180:
            minoModel =
            [
              [0,3,3],
              [3,3,0],
            ];
            break;
          case 90:
          case 270:
            minoModel =
            [
              [3,0],
              [3,3],
              [0,3],
            ];
            break;
        }
        break;

      case 4:
      // Zミノ
      switch(minoArg){
        case 0:
        case 180:
        minoModel =
        [
          [4,4,0],
          [0,4,4],
        ];
        break;
        case 90:
        case 270:
          minoModel =
          [
            [0,4],
            [4,4],
            [4,0],
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
          ];
          break;
        case 90:
          minoModel =
          [
            [5,5],
            [5,0],
            [5,0],
          ];
          break;
        case 180:
          minoModel =
          [
            [5,5,5],
            [0,0,5],
          ];
          break;
        case 270:
          minoModel =
          [
            [0,5],
            [0,5],
            [5,5],
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
          ];
          break;
        case 90:
          minoModel =
          [
            [6,0],
            [6,0],
            [6,6],
          ];
          break;
        case 180:
          minoModel =
          [
            [6,6,6],
            [6,0,0],
          ];
          break;
        case 270:
          minoModel =
          [
            [6,6],
            [0,6],
            [0,6],
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
          ];
          break;
        case 90:
          minoModel =
          [
            [7,0],
            [7,7],
            [7,0],
          ];
          break;
        case 180:
          minoModel =
          [
            [7,7,7],
            [0,7,0],
          ];
          break;
        case 270:
          minoModel =
          [
            [0,7],
            [7,7],
            [0,7],
          ];
          break;
      }
        break;
    }
    return minoModel;
  }
}