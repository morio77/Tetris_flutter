class minoModelGenerater  {
  static List<List<int>> generate (int minoType, int minoArg) {
    List<List<int>> minoModel;
    switch(minoType){
      case 1:
      // Iミノ
        minoModel = [
          [1,1,1,1],
        ];
        break;
      case 2:
      // Oミノ
        minoModel = [
          [2,2],
          [2,2],
        ];
        break;
      case 3:
      // Sミノ
        minoModel = [
          [0,3,3],
          [3,3,0],
        ];
        break;
      case 4:
      // Zミノ
        minoModel = [
          [4,4,0],
          [0,4,4],
        ];
        break;
      case 5:
      // Jミノ
        minoModel = [
          [5,0,0],
          [5,5,5],
        ];
        break;
      case 6:
      // Lミノ
        minoModel = [
          [0,0,6],
          [6,6,6],
        ];
        break;
      case 7:
      // Tミノ
        minoModel = [
          [0,7,0],
          [7,7,7],
        ];
        break;
    }
    return minoModel;
  }
}