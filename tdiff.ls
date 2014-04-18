$ = document~get-element-by-id
$q = document~query-selector
$$ = document~query-selector-all

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
  TryStatement:          -> [it.block, ...it.handlers, it.finalizer]
  UnaryExpression:       -> [it.argument]
  UpdateExpression:      -> [it.argument]
  VariableDeclaration:   -> it.declarations
  VariableDeclarator:    -> [it.id, it.init]
  WhileStatement:        -> [it.test, it.body]
  WithStatement:         -> [it.expression, it.body]

children-of = -> children[it.type] it .filter (?)
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

    # label depths
    q = [[root]]
    depth = 0
    while q.length > 0
      next = []
      level = q.shift!
      for node in level
        next.push ...children-of(node)
        node.depth = depth
      q.push next unless next.length is 0
      depth++

const
  D = 0
  R = 1
  I = 2

# should be big enough
# XXX would prefer to allocate heap as
# new array buffer when diffing, but
# firefox can't re-link an asm module with
# a different heap.
HEAP_SIZE = 33554432 * 8
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
    for i til bs
      bt[i] = I

    renames = alloc renames-size
    for aa, i in a.nodes
      for bb, j in b.nodes
        renames[i * bsize + j] = renaming a, b, aa, bb

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

    #console.log tbl td, as, bs
    #console.log tbl bt, as, bs

    # console.log 'td after'
    # console.log tbl td, as, bs
    # console.log 'fd after'
    # console.log tbl fd, as, bs
    @distance = td[asize * bs + bsize]
    @mapping = []
    @amap = {}
    @bmap = {}
    @trace = []
    @tmap = [["#{td[i * bs + j]}" for j til bs] for i til as]
    i = a.size
    j = b.size
    k = a.size * b.size
    while i >= 0 and j >= 0 and k > 0 # row/col 0 is dummy data
      --k
      @trace.push [i, j]
      @tmap[i][j] = "(#{td[i * bs + j]})"
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
    #console.log table(@tmap)
    #console.log @trace

BASE = 200
BASE_RENAME = BASE * 10
export COST =
  insertion: BASE
  deletion: BASE
  renaming: (lgraph, rgraph, left, right) ->
    depth-diff = Math.abs left.depth - right.depth
    # make earlier (in a postorder sense) exact renames more
    # expensive than later
    msize = Math.max lgraph.size, rgraph.size
    postorder-weight = Math.max do
      (lgraph.size - left.postorder) / msize * BASE
      (rgraph.size - right.postorder) / msize * BASE

    exact-rename = depth-diff + postorder-weight

    if left.type is right.type
      # TODO string distance
      if left.type is \Literal
        if left.raw is right.raw
          exact-rename
        else
          BASE_RENAME
      else if left.type is \Identifier
        if left.name is right.name
          exact-rename
        else
          BASE_RENAME
      else
        exact-rename
    else
      BASE_RENAME

L = document~create-element

supertype-of = ->
  if /Statement/.test it.type
    \Statement
  else if /Declaration/.test it.type
    \Statement
  else if /Expression/.test it.type
    \Expression
  else
    ''

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
  type-stack = []
  for c, i in source
    if starts[i]?
      el.append-child document.create-text-node text
      text = ''

      for node in that
        elem = with L \span
          ..class-name = "syntax #{node.type} #{supertype-of node}"# q#{depth % 9}-9"
          ..dataset.postorder = node.postorder
        type-stack.push node.type
        cur-type = node.type
        depth++
        el.append-child elem
        el = elem

    if cur-type is \BlockStatement
      unless c is \{ or c is \}
        text += c
    else
      unless c is \\n
        text += c

    if ends[i]?
      el.append-child document.create-text-node text
      text = ''
      for node in that
        el.=parent-node
        type-stack.pop!
        cur-type = type-stack[*-1]
        depth--

  return frag

# as a hack, if a file doesn't parse
# as javascript, then pretend it's a list of
# javascript strings, per line, which is the
# degenerate case of tree diff that reduces
# to a classical string diff.
text-mode-parse = (text ? '') ->
  fake-js =
    "[
    #{text.split /\n/
      .map ->
        "'#{it.split /\s/
          .map (.replace /'/g "\\'")
          .join "','"}'"
      .join '];['
    }]"

  esprima.parse fake-js
