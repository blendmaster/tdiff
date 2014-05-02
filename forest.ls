class Node
  -> @children = []; @label = ''
  deep-copy: ->
    with new Node
      .. <<< this
      ..children = @children?map (.deep-copy!)

class Tree
  (root) ->
    @root = root
      ..key-root = true
    @nodes = []
    @key-roots = [root]
    # reverse + unshift keeps the @key-roots array in ascending order
    # by posteorder traversal
    for root.children.slice 1 .reverse!
      ..key-root = true
      @key-roots.unshift ..

    # postorder labeling, while also discovering key roots
    # i.e. a node which has left siblings or the root
    # and leftmost-decendents
    n = 0
    stack = [[root, root.children.slice!]]
    while stack.length > 0
      [node, children] = frame = stack.pop!
      if children.length > 0
        child = children.shift!

        # all non-left-siblings are key roots. if there
        # is only one child, then the slice is empty
        for child.children.slice 1 .reverse!
          ..key-root = true
          @key-roots.unshift ..

        stack.push frame, [child, child.children.slice!]
      else
        @nodes.push node
        node.postorder = n++

        # since we're postorder traversal, our children's leftmost-decendent
        # is already calculated
        node.leftmost =
          if node.children.length > 0
            node.children.0.leftmost
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
        next.push ...node.children.slice!
        node.depth = depth
      q.push next unless next.length is 0
      depth++

# TODO more efficient way for tracking the mapping
min-mapping = (...choices) ->
  min = choices.0.1
  min-m =  choices.0.0
  for [m, cost] in choices
    if cost < min
      min = cost
      min-m = m
  return [min-m, min]

class EditDistance
  (a, b, {deletion, insertion, renaming}: cost) ->
    # distance array, (a.size, b.size)
    @td = [[j * insertion for j to b.size] for i to a.size]
    @backtrace = [[\i for j to b.size] for i to a.size]

    for i from 1 til @td.length
      @td[i]0 = i * deletion
      @backtrace[i]0 = \d

    @backtrace[0][0] = \r

    @fd = {}
    for kr1 in a.key-roots
      for kr2 in b.key-roots
        # temporary array (lmd[kr1]-1 .. kr1, lmd[kr2]-1 .. kr2)
        # where lmd = leftmost-decendent
        fd = [[\- for j to b.size] for i to a.size]

        # initialize "origin" and edges
        # add 1 to all postorders to prevent use of index -1
        fd[kr1.leftmost.postorder][kr2.leftmost.postorder] = 0
        for i from (kr1.leftmost.postorder + 1) to (kr1.postorder + 1)
          fd[i][kr2.leftmost.postorder] =
            fd[i-1][kr2.leftmost.postorder] + deletion
        for j from (kr2.leftmost.postorder + 1) to (kr2.postorder + 1)
          fd[kr1.leftmost.postorder][j] =
            fd[kr1.leftmost.postorder][j-1] + insertion

        # add 1 to all postorders to prevent use of index -1
        for i from (kr1.leftmost.postorder + 1) to (kr1.postorder + 1)
          i1 = a.nodes[i-1]
          for j from (kr2.leftmost.postorder + 1) to (kr2.postorder + 1)
            j1 = b.nodes[j-1]
            if  i1.leftmost is kr1.leftmost \
            and j1.leftmost is kr2.leftmost
              # i.e. both are trees
              [@backtrace[i][j], fd[i][j]] = min-mapping do
                [\r fd[i-1][j-1] + renaming a.nodes[i-1], b.nodes[j-1] ]
                [\d fd[i-1][j  ] + deletion]
                [\i fd[i  ][j-1] + insertion]

              @td[i][j] = fd[i][j]
            else
              fd[i][j] = Math.min do
                fd[a.nodes[i-1].leftmost.postorder]\
                  [b.nodes[j-1].leftmost.postorder] + @td[i][j]
                fd[i-1][j  ] + deletion
                fd[i  ][j-1] + insertion

        # emit fd for algorithm tracing
        @fd["#{kr1.postorder}-#{kr2.postorder}"] = fd

    @distance = @td[a.size][b.size]
    @mapping = []
    @amap = {}
    @bmap = {}
    @trace = []
    i = a.size
    j = b.size
    while i >= 0 and j >= 0 # row/col 0 is dummy data
      @trace.push [i, j]
      switch @backtrace[i][j]
      case \r
        if i > 0 and j > 0
          @mapping.push [a.nodes[i-1], b.nodes[j-1]]
          @amap[i-1] = j-1
          @bmap[j-1] = i-1
        --i
        --j
      case \i
        if j > 0
          @mapping.push [null, b.nodes[j-1]]
          @bmap[j-1] = null
        --j
      case \d
        if i > 0
          @mapping.push [a.nodes[i-1], null]
          @amap[i-1] = null
        --i
      default
        throw [i, j]

const DELIM =
  \] : \[
  \) : \(
  \} : \{

# parse labeled bracket language
parse = (text) ->
  dstack = []

  pstack = [new Node]

  for c in text - /\s+/g
    switch c
    case <[ [ { ( ]>
      dstack.push c

      node = new Node
      pstack[*-1]children.push node
      pstack.push node
    case <[ ] } ) ]>
      if pstack.length is 1 or dstack[*-1] is not DELIM[c]
        throw new Error "unexpected '#c'"

      pstack.pop!
      delimiter = dstack.pop!
    default
      pstack[*-1]label += c

  if pstack.length > 1
    throw new Error "missing closing '#{dstack[*-1]}'"

  return new Tree pstack.0

$ = document~get-element-by-id

diag = d3.svg.diagonal!

BLANK = new Node <<< {label: '', postorder: ''}

draw-tree = (ast, svg) !->
  t = d3.layout.tree!
    .size [500 500]
  nodes = t.nodes ast.root
  links = t.links nodes
  svg
    ..select \.nodes .select-all \.node .data nodes
      ..exit!remove!
      ..enter!append \g .attr class: \node
        ..append \circle .attr class: \node-circle r: 20
        ..append \text .attr class: \node-text
          ..append \tspan .attr class: \node-label
          ..append \tspan .attr class: \node-postorder dy: 5
      ..attr do
        transform: -> "translate(#{it.x}, #{it.y})"
        'data-postorder': (.postorder)
      ..classed \key-root (.key-root)
      ..select \.node-label .text (.label)
      ..select \.node-postorder .text (.postorder)
    ..select \.links .select-all \.link .data links
      ..exit!remove!
      ..enter!append \path .attr \class \link
      ..attr \d diag

# draw filtered T[0..i] forest
mini-forest = (tree, node) !-->
  return if node is BLANK
  i = node.postorder

  t = d3.layout.tree!
    .size [50 50]
  nodes = t.nodes tree.root.deep-copy!
  links = t.links nodes .filter ->
    it.source.postorder <= i and it.target.postorder <= i
  nodes.=filter -> it.postorder <= i

  d3.select this .select-all \.mini-forest .data [tree]
    ..exit!remove!
    ..enter!append \svg
      ..attr class: \mini-forest width: 60 height: 60
      ..append \g .attr \transform "translate(5, 5)"
        ..append \g .attr \class \links
        ..append \g .attr \class \nodes
    ..select \.links .select-all \.link .data links
      ..exit!remove!
      ..enter!append \path .attr \class \link
      ..attr \d diag
    ..select \.nodes .select-all \.node .data nodes
      ..exit!remove!
      ..enter!append \circle .attr \class \node
      ..attr cx: (.x), cy: (.y), r: 3
      ..classed \highlight -> it.postorder is i

$s = document~query-selector

parse-and-draw = (input, error, svg) ->
  try
    ast = parse input.value || ''
    error.text-content = ''
    draw-tree ast, svg
    return ast
  catch
    error.text-content = e
    void

diff = !->
  a = parse-and-draw $(\input1), $(\error1), d3.select \#tree1
  b = parse-and-draw $(\input2), $(\error2), d3.select \#tree2

  window.a = a
  window.b = b

  return unless a? and b?

  renaming-flat = parseFloat $(\renaming).value
  postorder-weight = parseFloat $(\postorder-weight).value
  depth-weight = parseFloat $(\depth-weight).value
  cost =
    insertion: parseFloat $(\insertion).value
    deletion: parseFloat $(\deletion).value
    renaming: (aa, bb) ->
      msize = a.size >? b.size
      postorder = postorder-weight * Math.max do
        (a.size - aa.postorder) / msize * renaming-flat
        (b.size - bb.postorder) / msize * renaming-flat
      depth-diff = depth-weight * Math.abs aa.depth - bb.depth
      if aa.label is bb.label
        postorder + depth-diff
      else
        renaming-flat

  d = new EditDistance a, b, cost
  window.d = d

  cols = [BLANK] ++ a.nodes

  d3.select \#dtable
    ..select 'thead > tr' .select-all \th .data [BLANK, BLANK] ++ b.nodes
      ..exit!remove!
      ..enter!append \th
        ..append \span .attr \class \label
        ..append \sub .attr \class \postorder
        ..append \div .attr \class \forest
      ..select \.label .text (.label)
      ..select \.postorder .text (.postorder)
      ..select \.forest .each mini-forest b
    tbody = ..select 'tbody'
      ..select-all \tr .data d.td
        ..exit!remove!
        ..enter!append \tr
          ..append \th
            ..append \span .attr \class \label
            ..append \sub .attr \class \postorder
            ..append \span .attr \class \forest
        ..select \th
          ..select \.label .text (, i) -> cols[i]label
          ..select \.postorder .text (, i) -> cols[i]postorder
          ..select \.forest .each (, i) -> mini-forest.call this, a, cols[i]
        tds = ..select-all \td .data (-> it)
          ..exit!remove!
          ..enter!append \td
          ..classed \trace false
          ..classed \subtreed (, j, i) ->
            d.fd["#{i-1}-#{j-1}"]?
          ..attr \id (, j, i) -> "td#i#j"
          ..text -> it # d3.format '0.'
          ..on \mouseenter (, j, i) !->
            if d.fd["#{i-1}-#{j-1}"]?
              # rebind trs to fd
              tds.text (, y, x) -> d.fd["#{i-1}-#{j-1}"][x][y]
          ..on \mouseleave (, j, i) !->
            # reset table
            tds.text -> it

  for [i, j] in d.trace
    $ "td#i#j" .class-list.add \trace

  diag = ->
    sx = it.0.x + 30;  sy = it.0.y + 30
    tx = it.1.x + 480; ty = it.1.y + 30

    "M #sx #sy A 500 500 0 0 0 #tx #ty"

  d3.select \#mappings
    ..select-all \.mapping .data d.mapping.filter (-> it.0? and it.1?)
      ..exit!remove!
      ..enter!append \path
      ..attr \class -> "mapping a#{it.0.postorder} b#{it.1.postorder}"
      ..attr \d diag

  d3.select \#tree1 .select-all \.node
    ..classed \delete -> not d.amap[it.postorder]?
  d3.select \#tree2 .select-all \.node
    ..classed \insert -> not d.bmap[it.postorder]?

for el in <[ input1 input2 insertion deletion renaming postorder-weight depth-weight ]>
  $ el .add-event-listener \input diff

diff!
