class Node then -> @children = []; @label = ''

class Tree
  (root) ->
    @root = root
      ..key-root = true
    @nodes = [root]
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

# TODO more efficient way for tracking the mapping
min-mapping = (mappings, ...choices) ->
  min = choices.0.1
  min-m =  choices.0.0
  for [m, cost] in choices
    if cost < min
      min = cost
      min-m = m
  mappings <<< min-m if min-m?
  return min

class EditDistance
  (a, b, {deletion, insertion, renaming}: cost) ->
    # distance array, (a.size, b.size)
    @td = [[] for i to a.size]

    # from a.postorder to b.postorder
    @mapping = {}

    for kr1 in a.key-roots
      for kr2 in b.key-roots
        # temporary array (lmd[kr1]-1 .. kr1, lmd[kr2]-1 .. kr2)
        # where lmd = leftmost-decendent
        fd = [[] for i to a.size]

        # initialize "origin" and edges
        # add 1 to all postorders to prevent use of index -1
        fd[kr1.leftmost.postorder][kr2.leftmost.postorder] = 0
        for d_i from (kr1.leftmost.postorder + 1) to (kr1.postorder + 1)
          fd[d_i][kr2.leftmost.postorder] =
            fd[d_i - 1][kr2.leftmost.postorder] + deletion
        for d_j from (kr2.leftmost.postorder + 1) to (kr2.postorder + 1)
          fd[kr1.leftmost.postorder][d_j] =
            fd[kr1.leftmost.postorder][d_j - 1] + insertion

        # add 1 to all postorders to prevent use of index -1
        for d_i from (kr1.leftmost.postorder + 1) to (kr1.postorder + 1)
          for d_j from (kr2.leftmost.postorder + 1) to (kr2.postorder + 1)
            if  kr1.leftmost.leftmost is kr1.leftmost \
            and kr2.leftmost.leftmost is kr2.leftmost
              # i.e. both are trees
              fd[d_i][d_j] = min-mapping @mapping,
                [{(d_i - 1) : null}, fd[d_i - 1][d_j    ] + deletion]
                [{"_#{d_j - 1}" : d_j - 1}, fd[d_i    ][d_j - 1] + insertion]
                [
                  {(d_i - 1) : d_j - 1}
                  fd[d_i - 1][d_j - 1] + renaming a.nodes[d_i - 1], b.nodes[d_j - 1]
                ]

              @td[d_i][d_j] = fd[d_i][d_j]
            else
              fd[d_i][d_j] = min-mapping @mapping,
                [{(d_i - 1) : null}, fd[d_i - 1][d_j    ] + deletion]
                [{"_#{d_j - 1}" : d_j - 1}, fd[d_i    ][d_j - 1] + insertion]
                [
                  void
                  fd[a.nodes[d_i - 1].leftmost.postorder]\
                    [b.nodes[d_j - 1].leftmost.postorder] + td[d_i][d_j]
                ]

    @distance = @td[a.size][b.size]

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

COST =
  insertion: 10
  deletion: 10
  renaming: (a, b) ->
    if a.label is b.label
      0
    else
      20

diff = !->
  a = parse-and-draw $(\input1), $(\error1), d3.select \#tree1
  b = parse-and-draw $(\input2), $(\error2), d3.select \#tree2

  return unless a? and b?

  d = new EditDistance a, b, COST
  console.log d
  $ \diff .text-content = d.distance
  for am, bm of d.mapping
    if am.0 is \_ # insertion
      $s "\#tree2 .node[data-postorder=\"#bm\"]" .class-list.add \insert
    else if bm? # mapped
      # draw diagonal
      $s "\#tree2 .node[data-postorder=\"#bm\"]" .class-list.add \mapped
    else # deletion
      $s "\#tree1 .node[data-postorder=\"#am\"]" .class-list.add \delete
    

$ \input1
  ..add-event-listener \input diff

$ \input2
  ..add-event-listener \input diff

diff!
