children =
  AssignmentExpression:  -> [it.left, it.right]
  ArrayExpression:       -> it.elements
  BlockStatement:        -> it.body
  BinaryExpression:      -> [it.left, it.right]
  BreakStatement:        -> [it.identitifier]
  CallExpression:        -> [it.callee] ++ it.arguments
  CatchClause:           -> [it.param, it.guard, it.body]
  ConditionalExpression: -> [it.test, it.alternate, it.consequent]
  ContinueStatement:     -> [it.identifier]
  DoWhileStatement:      -> [it.body, it.test]
  DebuggerStatement:     -> []
  EmptyStatement:        -> []
  ExpressionStatement:   -> [it.expression]
  ForStatement:          -> [it.init, it.test, it.update, it.body]
  ForInStatement:        -> [it.left, it.right, it.body]
  FunctionDeclaration:   -> [it.id] ++ it.params ++ [it.body]
  FunctionExpression:    -> [it.id] ++ it.params ++ [it.body]
  Identifier:            -> []
  IfStatement:           -> [it.test, it.consequent, it.alternate]
  Literal:               -> []
  LabeledStatement:      -> [it.body]
  LogicalExpression:     -> [it.left, it.right]
  MemberExpression:      -> [it.object, it.property]
  NewExpression:         -> [it.callee] ++ it.arguments
  ObjectExpression:      -> it.properties
  Program:               -> it.body
  Property:              -> [it.key, it.value]
  ReturnStatement:       -> [it.argument]
  SequenceExpression:    -> it.expressions
  SwitchStatement:       -> [it.discriminant] ++ it.cases
  SwitchCase:            -> [it.test] ++ it.consequent
  ThisExpression:        -> []
  ThrowStatement:        -> [it.argument]
  TryStatement:          -> [it.block, it.handler, it.finalizer]
  UnaryExpression:       -> [it.argument]
  UpdateExpression:      -> [it.argument]
  VariableDeclaration:   -> it.declarations
  VariableDeclarator:    -> [it.id, it.init]
  WhileStatement:        -> [it.test, it.body]
  WithStatement:         -> [it.expression, it.body]

children-of = -> children[it.type] it .filter (?)

label =
  AssignmentExpression:  -> '='
  ArrayExpression:       -> '[]'
  BlockStatement:        -> '{}'
  BinaryExpression:      -> it.operator
  BreakStatement:        -> 'break'
  CallExpression:        -> '()'
  CatchClause:           -> 'catch'
  ConditionalExpression: -> '?:'
  ContinueStatement:     -> 'continue'
  DoWhileStatement:      -> 'do'
  DebuggerStatement:     -> 'debugger'
  EmptyStatement:        -> ';'
  ExpressionStatement:   -> ';'
  ForStatement:          -> 'for'
  ForInStatement:        -> 'for'
  FunctionDeclaration:   -> 'function'
  FunctionExpression:    -> 'function'
  Identifier:            -> it.name
  IfStatement:           -> 'if'
  Literal:               -> it.raw
  LabeledStatement:      -> 'label'
  LogicalExpression:     -> it.operator
  MemberExpression:      -> '.'
  NewExpression:         -> 'new'
  ObjectExpression:      -> '{}'
  Program:               -> '.js'
  Property:              -> ':'
  ReturnStatement:       -> 'return'
  SequenceExpression:    -> ','
  SwitchStatement:       -> 'switch'
  SwitchCase:            -> if it.test? then 'case' else 'default'
  ThisExpression:        -> 'this'
  ThrowStatement:        -> 'throw'
  TryStatement:          -> 'try'
  UnaryExpression:       -> it.operator
  UpdateExpression:      -> it.operator
  VariableDeclaration:   -> 'var'
  VariableDeclarator:    -> 'var'
  WhileStatement:        -> 'while'
  WithStatement:         -> 'with'

postorder = (root) !->
  n = 0
  stack = [[root, children-of root]]

  while stack.length > 0
    [node, children] = frame = stack.pop!
    if children.length > 0
      child = children.shift!
      stack.push frame, [child, children-of child]
    else
      node.postorder = n++

class Tree
  (root) ->
    @root = root
      ..key-root = true
    @nodes = []
    @key-roots = [root]

    # reverse + unshift keeps the @key-roots array in ascending order
    # by postorder traversal
    for children-of(root).slice 1 .reverse!
      ..key-root = true
      @key-roots.unshift ..

    # postorder labeling, while also discovering key roots
    # i.e. a node which has left siblings or the root
    # and leftmost-decendents
    n = 0
    stack = [[root, children-of(root).slice!]]
    while stack.length > 0
      [node, children] = frame = stack.pop!
      if children.length > 0
        child = children.shift!

        # all non-left-siblings are key roots. if there
        # is only one child, then the slice is empty
        for children-of(child)slice 1 .reverse!
          ..key-root = true
          @key-roots.unshift ..

        stack.push frame, [child, children-of(child)]
      else
        @nodes.push node
        node.postorder = n++

        # since we're postorder traversal, our children's leftmost-decendent
        # is already calculated
        node.leftmost =
          if children-of(node).length > 0
            children-of(node).0.leftmost
          else
            node

    @size = n

table = ->
  it.map (.join \\t) .join \\n

tbl = (it, a, b) ->
  arr = for i til a
    for j til b
      it[i * b + j]

  table arr

D = -1
I = 1
R = 0

fast-min = ZhangShasha window .min

class EditDistance
  (a, b, {deletion, insertion, renaming}: cost) ->
    asize = a.size
    bsize = b.size
    as = asize + 1
    bs = bsize + 1
    # distance array, (a.size, b.size)
    @td = td = new Int32Array as * bs
    for i til as
      for j til bs
        td[i * bs + j] = j * insertion

    an = a.nodes.length
    bn = b.nodes.length
    renames = new Int32Array an * bn
    for aa, i in a.nodes
      for bb, j in b.nodes
        renames[i * bn + j] = renaming aa, bb

    for i til as
      td[i * bs] = i * deletion

    # array (lmd[kr1]-1 .. kr1, lmd[kr2]-1 .. kr2)
    # where lmd = leftmost-decendent
    # reset per iteration
    fd = new Int32Array as * bs

    # precalculate leftmost.postorder for an index
    alp = new Int32Array a.nodes.length
    for aa, i in a.nodes
      alp[i] = aa.leftmost.postorder

    blp = new Int32Array b.nodes.length
    for bb, i in b.nodes
      blp[i] = bb.leftmost.postorder

    console.time \main
    for kr1 in a.key-roots
      p1 = kr1.postorder
      lp1 = kr1.leftmost.postorder
      ll1 = kr1.leftmost.leftmost
      l1 = kr1.leftmost
      for kr2 in b.key-roots
        p2 = kr2.postorder
        lp2 = kr2.leftmost.postorder
        ll2 = kr2.leftmost.leftmost
        l2 = kr2.leftmost

        # initialize "origin" and edges
        # add 1 to all postorders to prevent use of index -1
        fd[lp1 * bs + lp2] = 0
        for i from (lp1 + 1) to (p1 + 1)
          fd[i * bs + lp2] =
            fd[(i-1) * bs + lp2] + deletion
        for j from (lp2 + 1) to (p2 + 1)
          fd[lp1 * bs + j] =
            fd[lp1 * bs + j-1] + insertion

        if ll1 is l1 and ll2 is l2
          # add 1 to all postorders to prevent use of index -1
          for i from (lp1 + 1) to (p1 + 1)
            ix = i * bs
            imx = (i-1) * bs
            for j from (lp2 + 1) to (p2 + 1)
              del = fd[imx + j  ] + deletion
              ins = fd[ix  + j-1] + insertion
              ren = fd[imx + j-1] + renames[(i-1) * bn + j-1]

              if del < ins
                if del < ren
                  fd[ix + j] = del
                else # ren < del < ins
                  fd[ix + j] = ren
              else # ins < del
                if ins < ren
                  fd[ix + j] = ins
                else # ren < ins < del
                  fd[ix + j] = ren

              td[ix + j] = fd[ix + j]
        else
          # add 1 to all postorders to prevent use of index -1
          for i from (lp1 + 1) to (p1 + 1)
            ix = i * bs
            imx = (i-1) * bs
            for j from (lp2 + 1) to (p2 + 1)
              asub = alp[i-1]
              bsub = blp[j-1]

              del = fd[imx + j  ] + deletion
              ins = fd[ix  + j-1] + insertion
              ren = fd[asub * bs + bsub] + td[ix + j]

              if del < ins
                if del < ren
                  fd[ix + j] = del
                else # ren < del < ins
                  fd[ix + j] = ren
              else # ins < del
                if ins < ren
                  fd[ix + j] = ins
                else # ren < ins < del
                  fd[ix + j] = ren

    console.time-end \main
    @distance = td[asize * bs + bsize]
    @mapping = []
    @amap = {}
    @bmap = {}
    @trace = []
    i = a.size
    j = b.size
    while i >= 0 and j >= 0 # row/col 0 is dummy data
      @trace.push [i, j]
      # walk backwards from final distance and check
      # 3 possibilities, choosing the smallest.
      # this should trace back to 0,0 and provide a
      # valid mapping for the minimum cost without having
      # to explicitly store the backtrace.
      del = td[(i-1) * bs + j    ]
      ins = td[i     * bs + j - 1]
      ren = td[(i-1) * bs + j - 1]

      if ren < del
        if ren < ins # ren < del, ins
          if i > 0 and j > 0
            @mapping.push [a.nodes[i-1], b.nodes[j-1]]
            @amap[i-1] = j-1
            @bmap[j-1] = i-1
          --i
          --j
        else # ins < ren < del
          if j > 0
            @mapping.push [null, b.nodes[j-1]]
            @bmap[j-1] = null
          --j
      else
        if del < ins # del < ren, ins
          if i > 0
            @mapping.push [null, b.nodes[j-1]]
            @mapping.push [a.nodes[i-1], null]
            @amap[i-1] = null
          --i
        else # ins < del < ren
          if j > 0
            @mapping.push [null, b.nodes[j-1]]
            @bmap[j-1] = null
          --j

export COST =
  insertion: 1
  deletion: 1
  renaming: (left, right) ->
    if left.type is right.type
      # TODO string distance
      if left.type is \Literal
        if left.raw is right.raw
          0
        else
          10
      else if left.type is \Identifier
        if left.name is right.name
          0
        else
          10
      else
        0
    else
      10

L = document~create-element

gen-html = (source, ast) ->
  starts = {}
  ends = {}
  q = [ast]
  while (node = q.pop!)?
    [start, end] = node.range
    starts[][start]push node
    ends[][end - 1]unshift node
    q.push ...children-of node

  el = frag = document.create-document-fragment!
  text = ''
  depth = 0
  for c, i in source
    if starts[i]?
      el.append-child document.create-text-node text
      text = ''

      for node in that
        elem = with L \span
          ..class-name = "syntax #{node.type} "# q#{depth % 9}-9"
          ..dataset.postorder = node.postorder
        depth++
        el.append-child elem
        el = elem

    text += c

    if ends[i]?
      el.append-child document.create-text-node text
      text = ''
      for node in that
        el.=parent-node
        depth--

  return frag

diag = d3.svg.diagonal!projection -> [it.y, it.x]

bind-tree = (ast, code, svg) ->
  t = d3.layout.tree!
    .children children-of
    .size [560 360]
  nodes = t.nodes ast
  d3.select svg
    ..select \.nodes .select-all \.node .data nodes
      ..exit!remove!
      ..enter!append \g .attr class: \node
        ..append \circle .attr class: \node-circle r: 20
        ..append \text .attr class: \node-text
      ..attr do
        transform: -> "translate(#{it.y}, #{it.x})"

        'data-postorder': (.postorder)
        title: ->
          [start, end] = it.range
          """
          #{it.type}

          #{code.substring start, end}
          """
      ..select \.node-text .text -> label[it.type] it
    ..select \.links .select-all \.link .data t.links nodes
      ..exit!remove!
      ..enter!append \path .attr \class \link
      ..attr \d diag


# DOM binding

$ = document~get-element-by-id
$q = document~query-selector
$$ = document~query-selector-all

input1 = $ \input1
error1 = $ \error1
raw1 = $ \raw1
output1 = $ \output1
input2 = $ \input2
error2 = $ \error2
raw2 = $ \raw2
output2 = $ \output2
tree1 = $ \tree1
tree2 = $ \tree2

calc-diff = !->
  try
    ast1 = esprima.parse input1.value
    ast2 = esprima.parse input2.value
  catch
    return

  console.time 'ast1'
  f1 = new Tree ast1
  console.time-end 'ast1'
  console.time 'ast2'
  f2 = new Tree ast2
  console.time-end 'ast2'
  console.time 'dist'
  d = new EditDistance f1, f2, COST
  console.time-end 'dist'

  console.log d

  #for node in $$ '#tree1 .node'
    #if d.amap[node.get-attribute \data-postorder]?
      #let p2 = that
        #node
          #..add-event-listener \mouseenter !->
            #$q "\#tree2 .node[data-postorder=\"#p2\"]"
              #.class-list.add \mapped
          #..add-event-listener \mouseleave !->
            #$q "\#tree2 .node[data-postorder=\"#p2\"]"
              #.class-list.remove \mapped
    #else
      #node.class-list.add \deleted
  #for node in $$ '#tree2 .node'
    #if d.bmap[node.get-attribute \data-postorder]?
      #let p1 = that
        #node
          #..add-event-listener \mouseenter !->
            #$q "\#tree1 .node[data-postorder=\"#p1\"]"
              #.class-list.add \mapped
          #..add-event-listener \mouseleave !->
            #$q "\#tree1 .node[data-postorder=\"#p1\"]"
              #.class-list.remove \mapped
    #else
      #node.class-list.add \added

  for node in $$ '#output1 .syntax'
    if d.amap[node.get-attribute \data-postorder]?
      node.class-list.add \mapped
    else
      node.class-list.add \deleted
  for node in $$ '#output2 .syntax'
    if d.bmap[node.get-attribute \data-postorder]?
      node.class-list.add \mapped
    else
      node.class-list.add \added

parse = (input, error, raw, output, tree) -> !->
  try
    ast = esprima.parse input.value, {+range}
  catch
    error.text-content = e
    input.class-list.add \error
    return

  postorder ast
  raw.text-content = JSON.stringify ast, , 2
  #bind-tree ast, input.value, tree

  while output.first-child?
    output.remove-child that

  normalized-code = escodegen.generate ast
  normalized-ast = esprima.parse normalized-code, {+range}
  postorder normalized-ast

  output.append-child gen-html normalized-code, normalized-ast

  input.class-list.remove \error
  error.text-content = ''

parse1 = parse input1, error1, raw1, output1, tree1
parse2 = parse input2, error2, raw2, output2, tree2

$ \input1 .add-event-listener \input parse1
$ \input2 .add-event-listener \input parse2

parse1!
parse2!

$ \calc .add-event-listener \click calc-diff
