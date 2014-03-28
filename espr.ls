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

const
  D = 0
  R = 1
  I = 2

# should be big enough
# XXX would prefer to allocate heap as
# new array buffer when diffing, but
# firefox can't re-link an asm module with
# a different heap.
HEAP_SIZE = 33554432
HEAP = new ArrayBuffer HEAP_SIZE

next-size = ->
  size = 4096
  until size >= 4 * it
    size *= 2
  size

prgm = ZhangShasha window, {}, HEAP .diff

class EditDistance
  (a, b, {deletion, insertion, renaming}: cost) ->

    asize = a.size
    bsize = b.size
    as = asize + 1
    bs = bsize + 1

    # check heap size
    total = next-size do
      # uint td[a.size + 1][b.size + 1]
      (td-size = as * bs) +
      # uint fd[a.size + 1][b.size + 1]
      (fd-size = as * bs) +
      # uint bt[a.size + 1][a.size + 1]
      (bt-size = as * bs) +
      # uint renames[a.size][b.size]
      (renames-size = asize * bsize) +
      # struct {
      #   uint postorder;
      #   uint leftmost_postorder;
      #   uint leftmost_leftmost_postorder;
      # } a[a.size], b[b.size]
      (a-struct-size = 4 * a.size) +
      (b-struct-size = 4 * b.size) +
      #
      # int kra[krasize], krb[krbsize];
      (kra-arr-size = a.key-roots.length) +
      (krb-arr-size = b.key-roots.length)

    if total > HEAP_SIZE
      alert 'not enough heap space :('

    ofs = 0
    alloc = (size) ->
      ptr = ofs
      ofs += size
      return new Uint32Array HEAP, ptr * 4, size

    # distance array, (a.size, b.size)
    td = alloc td-size
    @td = td

    fd = alloc fd-size
    bt = alloc fd-size

    renames = alloc renames-size
    for aa, i in a.nodes
      for bb, j in b.nodes
        renames[i * bsize + j] = renaming aa, bb

    # fill node structs
    astruct = alloc a-struct-size
    for aa, i in a.nodes
      astruct[i*3    ] = aa.postorder
      astruct[i*3 + 1] = aa.leftmost.postorder
      astruct[i*3 + 2] = aa.leftmost.leftmost.postorder

    bstruct = alloc b-struct-size
    for bb, i in b.nodes
      bstruct[i*3    ] = bb.postorder
      bstruct[i*3 + 1] = bb.leftmost.postorder
      bstruct[i*3 + 2] = bb.leftmost.leftmost.postorder

    # key root arrays
    kra = alloc kra-arr-size
    for kr1, i in a.key-roots
      kra[i] = kr1.postorder

    krb = alloc krb-arr-size
    for kr2, i in b.key-roots
      krb[i] = kr2.postorder

    console.time \main

    prgm do
     astruct.byte-offset
     asize
     kra.byte-offset
     kra-arr-size

     bstruct.byte-offset
     bsize
     krb.byte-offset
     krb-arr-size

     td.byte-offset
     fd.byte-offset
     bt.byte-offset

     renames.byte-offset
     insertion
     deletion

    console.time-end \main

    # console.log 'td after'
    # console.log tbl td, as, bs
    # console.log 'fd after'
    # console.log tbl fd, as, bs
    @distance = td[asize * bs + bsize]
    @mapping = []
    @amap = {}
    @bmap = {}
    @trace = []
    i = a.size
    j = b.size
    k = a.size * b.size
    while i >= 0 and j >= 0 and k > 0 # row/col 0 is dummy data
      --k
      @trace.push [i, j]
      switch bt[i * bs + j]
      case R
        if i > 0 and j > 0
          @mapping.push [a.nodes[i-1], b.nodes[j-1]]
          @amap[i-1] = j-1
          @bmap[j-1] = i-1
        --i
        --j
      case I
        if j > 0
          @mapping.push [null, b.nodes[j-1]]
          @bmap[j-1] = null
        --j
      case D
        if i > 0
          @mapping.push [a.nodes[i-1], null]
          @amap[i-1] = null
        --i
      default
        throw [i, j]

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
