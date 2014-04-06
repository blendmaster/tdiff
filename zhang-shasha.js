"use strict"

var table, tbl;
table = function(it){
  return it.map(function(it){
    return it.join('\t');
  }).join('\n');
};
tbl = function(it, a, b){
  var arr, res$, i$, i, lresult$, j$, j;
  res$ = [];
  for (i$ = 0; i$ < a; ++i$) {
    i = i$;
    lresult$ = [];
    for (j$ = 0; j$ < b; ++j$) {
      j = j$;
      lresult$.push(it[i * b + j]);
    }
    res$.push(lresult$);
  }
  arr = res$;
  return table(arr);
};

function ZhangShasha(stdlib, foreign, heap) {
  "use asm";

  var HEAP = new stdlib.Uint32Array(heap)
    , imul = stdlib.Math.imul;

  // on heap:
  // td[a.size + 1][b.size + 1]
  // fd[a.size + 1][a.size + 1]
  // bt[a.size + 1][a.size + 1]
  // renames[a.size][b.size]
  //
  // a[], b[] struct {
  //   postorder: int
  //   leftmost_postorder: int
  //   leftmost_leftmost_postorder: int
  // }
  //
  // int[] kra, krb // key roots
  //
  // on stack: 
  //
  // insertion cost
  // deletion cost
  function diff(
    a, asize, kra, krasize,
    b, bsize, krb, krbsize,
    td, fd, bt,
    renames, insertion, deletion
  ) {
    a = a|0;
    asize = asize|0;
    kra = kra|0;
    krasize = krasize|0;
    b = b|0;
    bsize = bsize|0;
    krb = krb|0;
    krbsize = krbsize|0;
    td = td|0;
    fd = fd|0;
    bt = bt|0;
    renames = renames|0;
    insertion = insertion|0;
    deletion = deletion|0;

    var i = 0, j = 0, as = 0, bs = 0, f = 0, kr1 = 0, kr2 = 0, r = 0, s = 0
      , p1 = 0, lp1 = 0, llp1 = 0
      , p2 = 0, lp2 = 0, llp2 = 0
      , ix = 0, imx = 0
      , del = 0, ins = 0, ren = 0
      , alp = 0, blp = 0;

    as = (asize + 1)|0;
    bs = (bsize + 1)|0;

    for (i = 0; (i|0) < (as|0); i = (i + 1)|0) {
      HEAP[(td + ((imul(i, bs)|0) << 2)) >> 2] = imul(i, deletion)|0;

      for (j = 1; (j|0) < (bs|0); j = (j + 1)|0) {
        HEAP[(td + (((imul(i, bs)|0) + j) << 2)) >> 2] = imul(j, insertion)|0;
      }
    }

    for (r = 0; (r|0) < (krasize|0); r = (r + 1)|0) {
      kr1 = ((a >> 2) + (imul(3, ~~(HEAP[(kra + (r << 2)) >> 2]))|0))|0;
      // + 1 for indices
      p1   = (1 + ~~HEAP[((kr1    ) << 2) >> 2])|0;
      lp1  = (1 + ~~HEAP[((kr1 + 1) << 2) >> 2])|0;
      llp1 = (1 + ~~HEAP[((kr1 + 2) << 2) >> 2])|0;

      for (s = 0; (s|0) < (krbsize|0); s = (s + 1)|0) {
        kr2 = ((b >> 2) + (imul(3, ~~(HEAP[(krb + (s << 2)) >> 2]))|0))|0;

        p2   = (1 + ~~HEAP[((kr2    ) << 2) >> 2])|0;
        lp2  = (1 + ~~HEAP[((kr2 + 1) << 2) >> 2])|0;
        llp2 = (1 + ~~HEAP[((kr2 + 2) << 2) >> 2])|0;

        // reinitialize fd
        HEAP[fd >> 2] = 0;
        for (i = lp1|0; (i|0) <= (p1|0); i = (i + 1)|0) {
          HEAP[(fd + (((imul(i, bs)|0) + lp2 - 1) << 2)) >> 2] = 
           (~~HEAP[(fd + (((imul(i - 1, bs)|0) + lp2 - 1) << 2)) >> 2] + deletion)|0;
        }
        for (j = lp2|0; (j|0) <= (p2|0); j = (j + 1)|0) {
          HEAP[(fd + (((imul((lp1-1)|0, bs)|0) + j) << 2)) >> 2] = 
            (~~HEAP[(fd + (((imul(lp1 - 1, bs)|0) + j-1) << 2)) >> 2] + insertion)|0;
        }
        
        if (((llp1|0) == (lp1|0)) & ((llp2|0) == (lp2|0))) {
          for (i = lp1; (i|0) <= (p1|0); i = (i + 1)|0) {
            ix = imul(i, bs)|0;
            imx = imul(i - 1, bs)|0;

            for (j = lp2; (j|0) <= (p2|0); j = (j + 1)|0) {
              del = (~~HEAP[(fd + ((imx + j) << 2)) >> 2] + deletion)|0;
              ins = (~~HEAP[(fd + ((ix + j-1) << 2)) >> 2] + insertion)|0;
              ren = (~~HEAP[(fd + ((imx + j-1) << 2)) >> 2] + 
                       ~~HEAP[(renames + 
                         (((imul(i - 1, bsize)|0) + j-1) << 2)) >> 2])|0;

              if ((del|0) < (ins|0)) {
                if ((ren|0) < (del|0)) {
                  HEAP[(bt + ((ix + j) << 2)) >> 2] = 1;
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = ren;
                } else {
                  HEAP[(bt + ((ix + j) << 2)) >> 2] = 0;
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = del;
                }
              } else {
                if ((ren|0) < (ins|0)) {
                  HEAP[(bt + ((ix + j) << 2)) >> 2] = 1;
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = ren;
                } else {
                  HEAP[(bt + ((ix + j) << 2)) >> 2] = 2;
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = ins;
                }
              }

              HEAP[(td + ((ix + j) << 2)) >> 2] = 
                (~~(HEAP[(fd + ((ix + j) << 2)) >> 2]))|0;
            }
          }
        } else {
          for (i = lp1; (i|0) <= (p1|0); i = (i + 1)|0) {
            ix = imul(i, bs)|0;
            imx = imul(i - 1, bs)|0;

            alp = (~~(HEAP[(a + (((imul(i-1, 3)|0) + 1) << 2)) >> 2]))|0;

            for (j = lp2; (j|0) <= (p2|0); j = (j + 1)|0) {
              blp = (~~(HEAP[(b + (((imul(j-1, 3)|0) + 1) << 2)) >> 2]))|0;

              del = (~~HEAP[(fd + ((imx + j) << 2)) >> 2] + deletion)|0;
              ins = (~~HEAP[(fd + ((ix + j-1) << 2)) >> 2] + insertion)|0;
              ren = (~~HEAP[(fd + (((imul(alp, bs)|0) + blp) << 2)) >> 2] + 
                       ~~HEAP[(td + ((ix + j) << 2)) >> 2])|0;

              if ((del|0) < (ins|0)) {
                if ((ren|0) < (del|0)) {
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = ren;
                } else {
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = del;
                }
              } else {
                if ((ren|0) < (ins|0)) {
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = ren;
                } else {
                  HEAP[(fd + ((ix + j) << 2)) >> 2] = ins;
                }
              }
            }
          }
        }
      }
    }

    return;
  }

  return {
    diff: diff
  };
}
