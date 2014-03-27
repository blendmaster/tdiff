// Generated by LiveScript 1.2.0
var children, childrenOf, label, postorder, Tree, table, tbl, D, I, R, fastMin, EditDistance, COST, L, genHtml, diag, bindTree, $, $q, $$, input1, error1, raw1, output1, input2, error2, raw2, output2, tree1, tree2, calcDiff, parse, parse1, parse2, out$ = typeof exports != 'undefined' && exports || this;
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
    return [it.block, it.handler, it.finalizer];
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
label = {
  AssignmentExpression: function(){
    return '=';
  },
  ArrayExpression: function(){
    return '[]';
  },
  BlockStatement: function(){
    return '{}';
  },
  BinaryExpression: function(it){
    return it.operator;
  },
  BreakStatement: function(){
    return 'break';
  },
  CallExpression: function(){
    return '()';
  },
  CatchClause: function(){
    return 'catch';
  },
  ConditionalExpression: function(){
    return '?:';
  },
  ContinueStatement: function(){
    return 'continue';
  },
  DoWhileStatement: function(){
    return 'do';
  },
  DebuggerStatement: function(){
    return 'debugger';
  },
  EmptyStatement: function(){
    return ';';
  },
  ExpressionStatement: function(){
    return ';';
  },
  ForStatement: function(){
    return 'for';
  },
  ForInStatement: function(){
    return 'for';
  },
  FunctionDeclaration: function(){
    return 'function';
  },
  FunctionExpression: function(){
    return 'function';
  },
  Identifier: function(it){
    return it.name;
  },
  IfStatement: function(){
    return 'if';
  },
  Literal: function(it){
    return it.raw;
  },
  LabeledStatement: function(){
    return 'label';
  },
  LogicalExpression: function(it){
    return it.operator;
  },
  MemberExpression: function(){
    return '.';
  },
  NewExpression: function(){
    return 'new';
  },
  ObjectExpression: function(){
    return '{}';
  },
  Program: function(){
    return '.js';
  },
  Property: function(){
    return ':';
  },
  ReturnStatement: function(){
    return 'return';
  },
  SequenceExpression: function(){
    return ',';
  },
  SwitchStatement: function(){
    return 'switch';
  },
  SwitchCase: function(it){
    if (it.test != null) {
      return 'case';
    } else {
      return 'default';
    }
  },
  ThisExpression: function(){
    return 'this';
  },
  ThrowStatement: function(){
    return 'throw';
  },
  TryStatement: function(){
    return 'try';
  },
  UnaryExpression: function(it){
    return it.operator;
  },
  UpdateExpression: function(it){
    return it.operator;
  },
  VariableDeclaration: function(){
    return 'var';
  },
  VariableDeclarator: function(){
    return 'var';
  },
  WhileStatement: function(){
    return 'while';
  },
  WithStatement: function(){
    return 'with';
  }
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
    var x$, i$, y$, ref$, len$, n, stack, frame, node, children, child, z$;
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
  }
  return Tree;
}());
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
D = -1;
I = 1;
R = 0;
fastMin = ZhangShasha(window).min;
EditDistance = (function(){
  EditDistance.displayName = 'EditDistance';
  var prototype = EditDistance.prototype, constructor = EditDistance;
  function EditDistance(a, b, cost){
    var deletion, insertion, renaming, asize, bsize, as, bs, td, i$, i, j$, j, an, bn, renames, ref$, len$, aa, ref1$, len1$, bb, fd, alp, blp, kr1, p1, lp1, ll1, l1, kr2, p2, lp2, ll2, l2, k$, to$, ix, imx, l$, to1$, del, ins, ren, asub, bsub;
    deletion = cost.deletion, insertion = cost.insertion, renaming = cost.renaming;
    asize = a.size;
    bsize = b.size;
    as = asize + 1;
    bs = bsize + 1;
    this.td = td = new Int32Array(as * bs);
    for (i$ = 0; i$ < as; ++i$) {
      i = i$;
      for (j$ = 0; j$ < bs; ++j$) {
        j = j$;
        td[i * bs + j] = j * insertion;
      }
    }
    an = a.nodes.length;
    bn = b.nodes.length;
    renames = new Int32Array(an * bn);
    for (i$ = 0, len$ = (ref$ = a.nodes).length; i$ < len$; ++i$) {
      i = i$;
      aa = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = b.nodes).length; j$ < len1$; ++j$) {
        j = j$;
        bb = ref1$[j$];
        renames[i * bn + j] = renaming(aa, bb);
      }
    }
    for (i$ = 0; i$ < as; ++i$) {
      i = i$;
      td[i * bs] = i * deletion;
    }
    fd = new Int32Array(as * bs);
    alp = new Int32Array(a.nodes.length);
    for (i$ = 0, len$ = (ref$ = a.nodes).length; i$ < len$; ++i$) {
      i = i$;
      aa = ref$[i$];
      alp[i] = aa.leftmost.postorder;
    }
    blp = new Int32Array(b.nodes.length);
    for (i$ = 0, len$ = (ref$ = b.nodes).length; i$ < len$; ++i$) {
      i = i$;
      bb = ref$[i$];
      blp[i] = bb.leftmost.postorder;
    }
    console.time('main');
    for (i$ = 0, len$ = (ref$ = a.keyRoots).length; i$ < len$; ++i$) {
      kr1 = ref$[i$];
      p1 = kr1.postorder;
      lp1 = kr1.leftmost.postorder;
      ll1 = kr1.leftmost.leftmost;
      l1 = kr1.leftmost;
      for (j$ = 0, len1$ = (ref1$ = b.keyRoots).length; j$ < len1$; ++j$) {
        kr2 = ref1$[j$];
        p2 = kr2.postorder;
        lp2 = kr2.leftmost.postorder;
        ll2 = kr2.leftmost.leftmost;
        l2 = kr2.leftmost;
        fd[lp1 * bs + lp2] = 0;
        for (k$ = lp1 + 1, to$ = p1 + 1; k$ <= to$; ++k$) {
          i = k$;
          fd[i * bs + lp2] = fd[(i - 1) * bs + lp2] + deletion;
        }
        for (k$ = lp2 + 1, to$ = p2 + 1; k$ <= to$; ++k$) {
          j = k$;
          fd[lp1 * bs + j] = fd[lp1 * bs + j - 1] + insertion;
        }
        if (ll1 === l1 && ll2 === l2) {
          for (k$ = lp1 + 1, to$ = p1 + 1; k$ <= to$; ++k$) {
            i = k$;
            ix = i * bs;
            imx = (i - 1) * bs;
            for (l$ = lp2 + 1, to1$ = p2 + 1; l$ <= to1$; ++l$) {
              j = l$;
              del = fd[imx + j] + deletion;
              ins = fd[ix + j - 1] + insertion;
              ren = fd[imx + j - 1] + renames[(i - 1) * bn + j - 1];
              if (del < ins) {
                if (del < ren) {
                  fd[ix + j] = del;
                } else {
                  fd[ix + j] = ren;
                }
              } else {
                if (ins < ren) {
                  fd[ix + j] = ins;
                } else {
                  fd[ix + j] = ren;
                }
              }
              td[ix + j] = fd[ix + j];
            }
          }
        } else {
          for (k$ = lp1 + 1, to$ = p1 + 1; k$ <= to$; ++k$) {
            i = k$;
            ix = i * bs;
            imx = (i - 1) * bs;
            for (l$ = lp2 + 1, to1$ = p2 + 1; l$ <= to1$; ++l$) {
              j = l$;
              asub = alp[i - 1];
              bsub = blp[j - 1];
              del = fd[imx + j] + deletion;
              ins = fd[ix + j - 1] + insertion;
              ren = fd[asub * bs + bsub] + td[ix + j];
              if (del < ins) {
                if (del < ren) {
                  fd[ix + j] = del;
                } else {
                  fd[ix + j] = ren;
                }
              } else {
                if (ins < ren) {
                  fd[ix + j] = ins;
                } else {
                  fd[ix + j] = ren;
                }
              }
            }
          }
        }
      }
    }
    console.timeEnd('main');
    this.distance = td[asize * bs + bsize];
    this.mapping = [];
    this.amap = {};
    this.bmap = {};
    this.trace = [];
    i = a.size;
    j = b.size;
    while (i >= 0 && j >= 0) {
      this.trace.push([i, j]);
      del = td[(i - 1) * bs + j];
      ins = td[i * bs + j - 1];
      ren = td[(i - 1) * bs + j - 1];
      if (ren < del) {
        if (ren < ins) {
          if (i > 0 && j > 0) {
            this.mapping.push([a.nodes[i - 1], b.nodes[j - 1]]);
            this.amap[i - 1] = j - 1;
            this.bmap[j - 1] = i - 1;
          }
          --i;
          --j;
        } else {
          if (j > 0) {
            this.mapping.push([null, b.nodes[j - 1]]);
            this.bmap[j - 1] = null;
          }
          --j;
        }
      } else {
        if (del < ins) {
          if (i > 0) {
            this.mapping.push([null, b.nodes[j - 1]]);
            this.mapping.push([a.nodes[i - 1], null]);
            this.amap[i - 1] = null;
          }
          --i;
        } else {
          if (j > 0) {
            this.mapping.push([null, b.nodes[j - 1]]);
            this.bmap[j - 1] = null;
          }
          --j;
        }
      }
    }
  }
  return EditDistance;
}());
out$.COST = COST = {
  insertion: 1,
  deletion: 1,
  renaming: function(left, right){
    if (left.type === right.type) {
      if (left.type === 'Literal') {
        if (left.raw === right.raw) {
          return 0;
        } else {
          return 10;
        }
      } else if (left.type === 'Identifier') {
        if (left.name === right.name) {
          return 0;
        } else {
          return 10;
        }
      } else {
        return 0;
      }
    } else {
      return 10;
    }
  }
};
L = bind$(document, 'createElement');
genHtml = function(source, ast){
  var starts, ends, q, node, ref$, start, end, key$, el, frag, text, depth, i$, len$, i, c, that, j$, len1$, elem, x$;
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
  for (i$ = 0, len$ = source.length; i$ < len$; ++i$) {
    i = i$;
    c = source[i$];
    if ((that = starts[i]) != null) {
      el.appendChild(document.createTextNode(text));
      text = '';
      for (j$ = 0, len1$ = that.length; j$ < len1$; ++j$) {
        node = that[j$];
        elem = (x$ = L('span'), x$.className = "syntax " + node.type + " ", x$.dataset.postorder = node.postorder, x$);
        depth++;
        el.appendChild(elem);
        el = elem;
      }
    }
    text += c;
    if ((that = ends[i]) != null) {
      el.appendChild(document.createTextNode(text));
      text = '';
      for (j$ = 0, len1$ = that.length; j$ < len1$; ++j$) {
        node = that[j$];
        el = el.parentNode;
        depth--;
      }
    }
  }
  return frag;
};
diag = d3.svg.diagonal().projection(function(it){
  return [it.y, it.x];
});
bindTree = function(ast, code, svg){
  var t, nodes, x$, y$, z$, z1$;
  t = d3.layout.tree().children(childrenOf).size([560, 360]);
  nodes = t.nodes(ast);
  x$ = d3.select(svg);
  y$ = x$.select('.nodes').selectAll('.node').data(nodes);
  y$.exit().remove();
  z$ = y$.enter().append('g').attr({
    'class': 'node'
  });
  z$.append('circle').attr({
    'class': 'node-circle',
    r: 20
  });
  z$.append('text').attr({
    'class': 'node-text'
  });
  y$.attr({
    transform: function(it){
      return "translate(" + it.y + ", " + it.x + ")";
    },
    'data-postorder': function(it){
      return it.postorder;
    },
    title: function(it){
      var ref$, start, end;
      ref$ = it.range, start = ref$[0], end = ref$[1];
      return "" + it.type + "\n\n" + code.substring(start, end);
    }
  });
  y$.select('.node-text').text(function(it){
    return label[it.type](it);
  });
  z1$ = x$.select('.links').selectAll('.link').data(t.links(nodes));
  z1$.exit().remove();
  z1$.enter().append('path').attr('class', 'link');
  z1$.attr('d', diag);
  return x$;
};
$ = bind$(document, 'getElementById');
$q = bind$(document, 'querySelector');
$$ = bind$(document, 'querySelectorAll');
input1 = $('input1');
error1 = $('error1');
raw1 = $('raw1');
output1 = $('output1');
input2 = $('input2');
error2 = $('error2');
raw2 = $('raw2');
output2 = $('output2');
tree1 = $('tree1');
tree2 = $('tree2');
calcDiff = function(){
  var ast1, ast2, e, f1, f2, d, i$, ref$, len$, node;
  try {
    ast1 = esprima.parse(input1.value);
    ast2 = esprima.parse(input2.value);
  } catch (e$) {
    e = e$;
    return;
  }
  console.time('ast1');
  f1 = new Tree(ast1);
  console.timeEnd('ast1');
  console.time('ast2');
  f2 = new Tree(ast2);
  console.timeEnd('ast2');
  console.time('dist');
  d = new EditDistance(f1, f2, COST);
  console.timeEnd('dist');
  console.log(d);
  for (i$ = 0, len$ = (ref$ = $$('#output1 .syntax')).length; i$ < len$; ++i$) {
    node = ref$[i$];
    if (d.amap[node.getAttribute('data-postorder')] != null) {
      node.classList.add('mapped');
    } else {
      node.classList.add('deleted');
    }
  }
  for (i$ = 0, len$ = (ref$ = $$('#output2 .syntax')).length; i$ < len$; ++i$) {
    node = ref$[i$];
    if (d.bmap[node.getAttribute('data-postorder')] != null) {
      node.classList.add('mapped');
    } else {
      node.classList.add('added');
    }
  }
};
parse = function(input, error, raw, output, tree){
  return function(){
    var ast, e, that, normalizedCode, normalizedAst;
    try {
      ast = esprima.parse(input.value, {
        range: true
      });
    } catch (e$) {
      e = e$;
      error.textContent = e;
      input.classList.add('error');
      return;
    }
    postorder(ast);
    raw.textContent = JSON.stringify(ast, void 8, 2);
    while ((that = output.firstChild) != null) {
      output.removeChild(that);
    }
    normalizedCode = escodegen.generate(ast);
    normalizedAst = esprima.parse(normalizedCode, {
      range: true
    });
    postorder(normalizedAst);
    output.appendChild(genHtml(normalizedCode, normalizedAst));
    input.classList.remove('error');
    error.textContent = '';
  };
};
parse1 = parse(input1, error1, raw1, output1, tree1);
parse2 = parse(input2, error2, raw2, output2, tree2);
$('input1').addEventListener('input', parse1);
$('input2').addEventListener('input', parse2);
parse1();
parse2();
$('calc').addEventListener('click', calcDiff);
function bind$(obj, key, target){
  return function(){ return (target || obj)[key].apply(obj, arguments) };
}