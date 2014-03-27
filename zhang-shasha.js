function ZhangShasha(stdlib, foreign, heap) {
  "use asm";

  function min(a, b, c) {
    a = a|0;
    b = b|0;
    c = c|0;
    var r = 0;
    if ((a|0) < (b|0)) {
      if ((a|0) < (c|0)) {
        r = a;
      } else {
        r = c;
      }
    } else {
      if ((b|0) < (c|0)) {
        r = b;
      } else {
        r = c;
      }
    }

    return r|0;
  }

  return {
    min: min
  };
}
