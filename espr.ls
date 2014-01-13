
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

set-to-array = -> with []
  it.for-each (el) !-> ..push el

# preorder visit
visit = (root, children, fn) !->
  q = [root]
  while (node = q.pop!)?
    fn node
    q.push ...children[node.postorder]

ids = 0
class Forest
  (
    @nodes         # [Node]
    @leftmost-root # Node
    @children      # {Int: [Node]} from each node's postorder to its children
    @roots         # {Int: Node} from each node's postorder to its root
  ) ->
    @id = ids++
    @size = @nodes.length
    if @size is 0 # stop calculating null forest
      return

    for node in nodes
      unless @roots[node.postorder]?
        throw new Error \fuck

    @is-tree = true
    uniq-root-ids = {}
    uniq-roots = []

    for n, root of @roots
      if not uniq-root-ids[root.postorder]?
        uniq-roots.push root
      uniq-root-ids[root.postorder] = true

      if root is not @leftmost-root
        @is-tree = false

    sorted-roots = uniq-roots.sort (a, b) -> a.postorder - b.postorder

    minus-leftmost-roots = {}
    for child in @children[@leftmost-root.postorder]
      visit child, @children, !->
        minus-leftmost-roots[it.postorder] = child
    for n, root of @roots
      if root is not @leftmost-root
        minus-leftmost-roots[n] = root

    minus-leftmost-uniq-root-ids = {}
    minus-leftmost-uniq-roots = []

    for n, root of minus-leftmost-roots
      if not minus-leftmost-uniq-root-ids[root.postorder]?
        minus-leftmost-uniq-roots.push root
      minus-leftmost-uniq-root-ids[root.postorder] = true

    minus-leftmost-sorted-roots =
      minus-leftmost-uniq-roots.sort (a, b) -> a.postorder - b.postorder

    minus-leftmost = @nodes.filter ~> it is not @leftmost-root
    @minus-leftmost = new Forest do
      minus-leftmost
      minus-leftmost-sorted-roots.0
      @children
      minus-leftmost-roots

    leftmost-subtree-nodes = @nodes.filter ~>
      @roots[it.postorder] is @leftmost-root

    leftmost-subtree-roots = {}
    for node in leftmost-subtree-nodes
      leftmost-subtree-roots[node.postorder] = @leftmost-root

    leftmost-subtree = @nodes.filter ~> @roots[it.postorder] is @leftmost-root
    @leftmost-subtree =
      if leftmost-subtree.length is @nodes.length
        this
      else
        new Forest do
          leftmost-subtree
          @leftmost-root
          @children
          leftmost-subtree-roots

    minus-leftmost-subtree-nodes =
      @nodes.filter ~> @roots[it.postorder] is not @leftmost-root

    second-leftmost-root = sorted-roots.1

    minus-leftmost-subtree-roots = {}
    for node in minus-leftmost-subtree-nodes
      minus-leftmost-subtree-roots[node.postorder] = @roots[node.postorder]

    @minus-leftmost-subtree = new Forest do
      minus-leftmost-subtree-nodes
      second-leftmost-root
      @children
      minus-leftmost-subtree-roots

  @@from-ast = (ast) ->
    nodes = []
    leftmost-root = ast
    children = {}
    roots = {}

    q = [ast]
    while (node = q.pop!)?
      n = node.postorder

      c = children-of node

      nodes.push node
      children[n] = c
      roots[n] = leftmost-root

      q.push ...c

    return new Forest nodes, leftmost-root, children, roots

min-and-mapping = (...choices) ->
  min-dist = Infinity
  min = void
  for [distance]: choice in choices
    if distance < min-dist
      min = choice
  return min

add-distance-and-mapping = ([add-cost, add-mapping], [distance, mapping]) ->
  [distance + add-cost, mapping <<< add-mapping]

memo = {}
distance-and-mapping = let
  fn = (forest1, forest2, cost, mapping) ->
    ret = if forest1.size is 0 and forest2.size is 0
      [0, {}]
    else if forest2.size is 0
      [forest1.size * cost.deletion, {}]
    else if forest1.size is 0
      [forest2.size * cost.insertion, {}]
    else if forest1.is-tree and forest2.is-tree
      min-and-mapping do
        add-distance-and-mapping do
          [cost.deletion, {}]
          distance-and-mapping forest1.minus-leftmost, forest2, cost
        add-distance-and-mapping do
          [cost.insertion, {}]
          distance-and-mapping forest1, forest2.minus-leftmost, cost
        add-distance-and-mapping do
          [
            cost.rename forest1.leftmost-root, forest2.leftmost-root
            {(forest1.leftmost-root.postorder): forest2.leftmost-root.postorder}
          ]
          distance-and-mapping forest1.minus-leftmost, forest2.minus-leftmost, cost
    else # one is not a single tree
      min-and-mapping do
        add-distance-and-mapping do
          [cost.deletion, {}]
          distance-and-mapping forest1.minus-leftmost, forest2, cost
        add-distance-and-mapping do
          [cost.insertion, {}]
          distance-and-mapping forest1, forest2.minus-leftmost, cost
        add-distance-and-mapping do
          distance-and-mapping do
            forest1.leftmost-subtree, forest2.leftmost-subtree, cost
          distance-and-mapping do
            forest1.minus-leftmost-subtree, forest2.minus-leftmost-subtree, cost
    return ret

  # memoize
  (forest1, forest2, cost, mapping) ->
    memo["#{forest1.id}#{forest2.id}"] ?= fn forest1, forest2, cost, mapping

export COST =
  insertion: 1
  deletion: 1
  rename: (left, right) ->
    if left.type is right.type
      # TODO string distance
      if left.type is \Literal
        if left.raw is right.raw
          0
        else
          Infinity
      else if left.type is \Identifier
        if left.name is right.name
          0
        else
          Infinity
      else
        0
    else
      Infinity

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

bind-forest = !->
  try
    ast1 = esprima.parse input1.value
    ast2 = esprima.parse input2.value
  catch
    return

  postorder ast1
  postorder ast2

  # clear memoize
  memo := {}

  console.time 'ast1'
  f1 = Forest.from-ast ast1
  console.time-end 'ast1'
  console.time 'ast2'
  f2 = Forest.from-ast ast2


calc-diff = !->
  try
    ast1 = esprima.parse input1.value
    ast2 = esprima.parse input2.value
  catch
    return

  postorder ast1
  postorder ast2

  # clear memoize
  memo := {}

  console.time 'ast1'
  f1 = Forest.from-ast ast1
  console.time-end 'ast1'
  console.time 'ast2'
  f2 = Forest.from-ast ast2
  console.time-end 'ast2'
  console.time 'dist'
  [distance, mapping] = distance-and-mapping do
    f1
    f2
    COST
    {}
  console.time-end 'dist'

  console.log mapping, distance

  # calc bimapping
  bimap = {}
  for p1, p2 of mapping
    bimap[p2] = p1

  for node in $$ '#tree1 .node'
    if mapping[node.get-attribute \data-postorder]?
      let p2 = that
        node
          ..add-event-listener \mouseenter !->
            $q "\#tree2 .node[data-postorder=\"#p2\"]"
              .class-list.add \mapped
          ..add-event-listener \mouseleave !->
            $q "\#tree2 .node[data-postorder=\"#p2\"]"
              .class-list.remove \mapped
    else
      node.class-list.add \deleted
  for node in $$ '#tree2 .node'
    if bimap[node.get-attribute \data-postorder]?
      let p1 = that
        node
          ..add-event-listener \mouseenter !->
            $q "\#tree1 .node[data-postorder=\"#p1\"]"
              .class-list.add \mapped
          ..add-event-listener \mouseleave !->
            $q "\#tree1 .node[data-postorder=\"#p1\"]"
              .class-list.remove \mapped
    else
      node.class-list.add \added

  for node in $$ '#output1 .syntax'
    if mapping[node.get-attribute \data-postorder]?
      node.class-list.add \mapped
    else
      node.class-list.add \deleted
  for node in $$ '#output2 .syntax'
    if bimap[node.get-attribute \data-postorder]?
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
  bind-tree ast, input.value, tree

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
