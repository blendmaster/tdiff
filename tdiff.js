// Generated by LiveScript 1.2.0
var $, $q, $$, children, childrenOf, postorder, Tree, D, R, I, HEAP_SIZE, HEAP, nextSize, prgm, EditDistance, BASE, BASE_RENAME, COST, L, supertypeOf, genHtml, textModeParse, slice$ = [].slice, out$ = typeof exports != 'undefined' && exports || this;
$ = bind$(document, 'getElementById');
$q = bind$(document, 'querySelector');
$$ = bind$(document, 'querySelectorAll');
children = {
  AssignmentExpression: function(it){
    return [it.left, it.right];
  },
  ArrayExpression: function(it){
    return it.elements;
  },
  BlockStatement: function(it){
    return it.body;
  },
  BinaryExpression: function(it){
    return [it.left, it.right];
  },
  BreakStatement: function(it){
    return [it.identitifier];
  },
  CallExpression: function(it){
    return [it.callee].concat(it.arguments);
  },
  CatchClause: function(it){
    return [it.param, it.guard, it.body];
  },
  ConditionalExpression: function(it){
    return [it.test, it.alternate, it.consequent];
  },
  ContinueStatement: function(it){
    return [it.identifier];
  },
  DoWhileStatement: function(it){
    return [it.body, it.test];
  },
  DebuggerStatement: function(){
    return [];
  },
  EmptyStatement: function(){
    return [];
  },
  ExpressionStatement: function(it){
    return [it.expression];
  },
  ForStatement: function(it){
    return [it.init, it.test, it.update, it.body];
  },
  ForInStatement: function(it){
    return [it.left, it.right, it.body];
  },
  FunctionDeclaration: function(it){
    return [it.id].concat(it.params, [it.body]);
  },
  FunctionExpression: function(it){
    return [it.id].concat(it.params, [it.body]);
  },
  Identifier: function(){
    return [];
  },
  IfStatement: function(it){
    return [it.test, it.consequent, it.alternate];
  },
  Literal: function(){
    return [];
  },
  LabeledStatement: function(it){
    return [it.body];
  },
  LogicalExpression: function(it){
    return [it.left, it.right];
  },
  MemberExpression: function(it){
    return [it.object, it.property];
  },
  NewExpression: function(it){
    return [it.callee].concat(it.arguments);
  },
  ObjectExpression: function(it){
    return it.properties;
  },
  Program: function(it){
    return it.body;
  },
  Property: function(it){
    return [it.key, it.value];
  },
  ReturnStatement: function(it){
    return [it.argument];
  },
  SequenceExpression: function(it){
    return it.expressions;
  },
  SwitchStatement: function(it){
    return [it.discriminant].concat(it.cases);
  },
  SwitchCase: function(it){
    return [it.test].concat(it.consequent);
  },
  ThisExpression: function(){
    return [];
  },
  ThrowStatement: function(it){
    return [it.argument];
  },
  TryStatement: function(it){
    return [it.block].concat(slice$.call(it.handlers), [it.finalizer]);
  },
  UnaryExpression: function(it){
    return [it.argument];
  },
  UpdateExpression: function(it){
    return [it.argument];
  },
  VariableDeclaration: function(it){
    return it.declarations;
  },
  VariableDeclarator: function(it){
    return [it.id, it.init];
  },
  WhileStatement: function(it){
    return [it.test, it.body];
  },
  WithStatement: function(it){
    return [it.expression, it.body];
  }
};
childrenOf = function(it){
  return children[it.type](it).filter(function(it){
    return it != null;
  });
};
postorder = function(root){
  var n, stack, frame, ref$, node, children, child;
  n = 0;
  stack = [[root, childrenOf(root)]];
  while (stack.length > 0) {
    ref$ = frame = stack.pop(), node = ref$[0], children = ref$[1];
    if (children.length > 0) {
      child = children.shift();
      stack.push(frame, [child, childrenOf(child)]);
    } else {
      node.postorder = n++;
    }
  }
};
Tree = (function(){
  Tree.displayName = 'Tree';
  var prototype = Tree.prototype, constructor = Tree;
  function Tree(root){
    var x$, i$, y$, ref$, len$, n, stack, frame, node, children, child, z$, q, depth, next, level;
    x$ = this.root = root;
    x$.keyRoot = true;
    this.nodes = [];
    this.keyRoots = [root];
    for (i$ = 0, len$ = (ref$ = childrenOf(root).slice(1).reverse()).length; i$ < len$; ++i$) {
      y$ = ref$[i$];
      y$.keyRoot = true;
      this.keyRoots.unshift(y$);
    }
    n = 0;
    stack = [[root, childrenOf(root).slice()]];
    while (stack.length > 0) {
      ref$ = frame = stack.pop(), node = ref$[0], children = ref$[1];
      if (children.length > 0) {
        child = children.shift();
        for (i$ = 0, len$ = (ref$ = childrenOf(child).slice(1).reverse()).length; i$ < len$; ++i$) {
          z$ = ref$[i$];
          z$.keyRoot = true;
          this.keyRoots.unshift(z$);
        }
        stack.push(frame, [child, childrenOf(child)]);
      } else {
        this.nodes.push(node);
        node.postorder = n++;
        node.leftmost = childrenOf(node).length > 0 ? childrenOf(node)[0].leftmost : node;
      }
    }
    this.size = n;
    q = [[root]];
    depth = 0;
    while (q.length > 0) {
      next = [];
      level = q.shift();
      for (i$ = 0, len$ = level.length; i$ < len$; ++i$) {
        node = level[i$];
        next.push.apply(next, childrenOf(node));
        node.depth = depth;
      }
      if (next.length !== 0) {
        q.push(next);
      }
      depth++;
    }
  }
  return Tree;
}());
D = 0;
R = 1;
I = 2;
HEAP_SIZE = 33554432 * 8;
HEAP = new ArrayBuffer(HEAP_SIZE);
nextSize = function(it){
  var size;
  size = 4096;
  while (!(size >= 4 * it)) {
    size *= 2;
  }
  return size;
};
prgm = ZhangShasha(window, {}, HEAP).diff;
EditDistance = (function(){
  EditDistance.displayName = 'EditDistance';
  var prototype = EditDistance.prototype, constructor = EditDistance;
  function EditDistance(a, b, cost){
    var deletion, insertion, renaming, asize, bsize, as, bs, total, tdSize, fdSize, btSize, renamesSize, aStructSize, bStructSize, kraArrSize, krbArrSize, ofs, alloc, td, fd, bt, i$, i, renames, ref$, len$, aa, j$, ref1$, len1$, j, bb, astruct, bstruct, kra, kr1, krb, kr2, res$, lresult$, k;
    deletion = cost.deletion, insertion = cost.insertion, renaming = cost.renaming;
    asize = a.size;
    bsize = b.size;
    as = asize + 1;
    bs = bsize + 1;
    total = nextSize((tdSize = as * bs) + (fdSize = as * bs) + (btSize = as * bs) + (renamesSize = asize * bsize) + (aStructSize = 4 * a.size) + (bStructSize = 4 * b.size) + (kraArrSize = a.keyRoots.length) + (krbArrSize = b.keyRoots.length));
    if (total > HEAP_SIZE) {
      alert('not enough heap space :(');
    }
    ofs = 0;
    alloc = function(size){
      var ptr;
      ptr = ofs;
      ofs += size;
      return new Uint32Array(HEAP, ptr * 4, size);
    };
    td = alloc(tdSize);
    this.td = td;
    fd = alloc(fdSize);
    bt = alloc(fdSize);
    for (i$ = 0; i$ < bs; ++i$) {
      i = i$;
      bt[i] = I;
    }
    renames = alloc(renamesSize);
    for (i$ = 0, len$ = (ref$ = a.nodes).length; i$ < len$; ++i$) {
      i = i$;
      aa = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = b.nodes).length; j$ < len1$; ++j$) {
        j = j$;
        bb = ref1$[j$];
        renames[i * bsize + j] = renaming(a, b, aa, bb);
      }
    }
    astruct = alloc(aStructSize);
    for (i$ = 0, len$ = (ref$ = a.nodes).length; i$ < len$; ++i$) {
      i = i$;
      aa = ref$[i$];
      astruct[i * 3] = aa.postorder;
      astruct[i * 3 + 1] = aa.leftmost.postorder;
      astruct[i * 3 + 2] = aa.leftmost.leftmost.postorder;
    }
    bstruct = alloc(bStructSize);
    for (i$ = 0, len$ = (ref$ = b.nodes).length; i$ < len$; ++i$) {
      i = i$;
      bb = ref$[i$];
      bstruct[i * 3] = bb.postorder;
      bstruct[i * 3 + 1] = bb.leftmost.postorder;
      bstruct[i * 3 + 2] = bb.leftmost.leftmost.postorder;
    }
    kra = alloc(kraArrSize);
    for (i$ = 0, len$ = (ref$ = a.keyRoots).length; i$ < len$; ++i$) {
      i = i$;
      kr1 = ref$[i$];
      kra[i] = kr1.postorder;
    }
    krb = alloc(krbArrSize);
    for (i$ = 0, len$ = (ref$ = b.keyRoots).length; i$ < len$; ++i$) {
      i = i$;
      kr2 = ref$[i$];
      krb[i] = kr2.postorder;
    }
    console.time('main');
    prgm(astruct.byteOffset, asize, kra.byteOffset, kraArrSize, bstruct.byteOffset, bsize, krb.byteOffset, krbArrSize, td.byteOffset, fd.byteOffset, bt.byteOffset, renames.byteOffset, insertion, deletion);
    console.timeEnd('main');
    this.distance = td[asize * bs + bsize];
    this.mapping = [];
    this.amap = {};
    this.bmap = {};
    this.trace = [];
    res$ = [];
    for (i$ = 0; i$ < as; ++i$) {
      i = i$;
      lresult$ = [];
      for (j$ = 0; j$ < bs; ++j$) {
        j = j$;
        lresult$.push(td[i * bs + j] + "");
      }
      res$.push(lresult$);
    }
    this.tmap = res$;
    i = a.size;
    j = b.size;
    k = a.size * b.size;
    while (i >= 0 && j >= 0 && k > 0) {
      --k;
      this.trace.push([i, j]);
      this.tmap[i][j] = "(" + td[i * bs + j] + ")";
      switch (bt[i * bs + j]) {
      case R:
        if (i > 0 && j > 0) {
          this.mapping.push([a.nodes[i - 1], b.nodes[j - 1]]);
          this.amap[i - 1] = j - 1;
          this.bmap[j - 1] = i - 1;
        }
        --i;
        --j;
        break;
      case I:
        if (j > 0) {
          this.mapping.push([null, b.nodes[j - 1]]);
          this.bmap[j - 1] = null;
        }
        --j;
        break;
      case D:
        if (i > 0) {
          this.mapping.push([a.nodes[i - 1], null]);
          this.amap[i - 1] = null;
        }
        --i;
        break;
      default:
        throw [i, j];
      }
    }
  }
  return EditDistance;
}());
BASE = 200;
BASE_RENAME = BASE * 10;
out$.COST = COST = {
  insertion: BASE,
  deletion: BASE,
  renaming: function(lgraph, rgraph, left, right){
    var depthDiff, msize, postorderWeight, exactRename;
    depthDiff = Math.abs(left.depth - right.depth);
    msize = Math.max(lgraph.size, rgraph.size);
    postorderWeight = Math.max((lgraph.size - left.postorder) / msize * BASE, (rgraph.size - right.postorder) / msize * BASE);
    exactRename = depthDiff + postorderWeight;
    if (left.type === right.type) {
      if (left.type === 'Literal') {
        if (left.raw === right.raw) {
          return exactRename;
        } else {
          return BASE_RENAME;
        }
      } else if (left.type === 'Identifier') {
        if (left.name === right.name) {
          return exactRename;
        } else {
          return BASE_RENAME;
        }
      } else {
        return exactRename;
      }
    } else {
      return BASE_RENAME;
    }
  }
};
L = bind$(document, 'createElement');
supertypeOf = function(it){
  if (/Statement/.test(it.type)) {
    return 'Statement';
  } else if (/Declaration/.test(it.type)) {
    return 'Statement';
  } else if (/Expression/.test(it.type)) {
    return 'Expression';
  } else {
    return '';
  }
};
genHtml = function(source, ast){
  var starts, ends, q, node, ref$, start, end, key$, el, frag, text, depth, typeStack, i$, len$, i, c, that, j$, len1$, elem, x$, curType;
  starts = {};
  ends = {};
  q = [ast];
  while ((node = q.pop()) != null) {
    ref$ = node.range, start = ref$[0], end = ref$[1];
    (starts[start] || (starts[start] = [])).push(node);
    (ends[key$ = end - 1] || (ends[key$] = [])).unshift(node);
    q.push.apply(q, childrenOf(node));
  }
  el = frag = document.createDocumentFragment();
  text = '';
  depth = 0;
  typeStack = [];
  for (i$ = 0, len$ = source.length; i$ < len$; ++i$) {
    i = i$;
    c = source[i$];
    if ((that = starts[i]) != null) {
      el.appendChild(document.createTextNode(text));
      text = '';
      for (j$ = 0, len1$ = that.length; j$ < len1$; ++j$) {
        node = that[j$];
        elem = (x$ = L('span'), x$.className = "syntax " + node.type + " " + supertypeOf(node), x$.dataset.postorder = node.postorder, x$);
        typeStack.push(node.type);
        curType = node.type;
        depth++;
        el.appendChild(elem);
        el = elem;
      }
    }
    if (curType === 'BlockStatement') {
      if (!(c === '{' || c === '}')) {
        text += c;
      }
    } else {
      if (c !== '\n') {
        text += c;
      }
    }
    if ((that = ends[i]) != null) {
      el.appendChild(document.createTextNode(text));
      text = '';
      for (j$ = 0, len1$ = that.length; j$ < len1$; ++j$) {
        node = that[j$];
        el = el.parentNode;
        typeStack.pop();
        curType = typeStack[typeStack.length - 1];
        depth--;
      }
    }
  }
  return frag;
};
textModeParse = function(text){
  var fakeJs;
  text == null && (text = '');
  fakeJs = "[" + text.split(/\n/).map(function(it){
    return "'" + it.split(/\s/).map(function(it){
      return it.replace(/'/g, "\\'");
    }).join("','") + "'";
  }).join('];[') + "]";
  return esprima.parse(fakeJs);
};
function bind$(obj, key, target){
  return function(){ return (target || obj)[key].apply(obj, arguments) };
}