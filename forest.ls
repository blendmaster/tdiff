postorder = (root) !->
  n = 0
  stack = [[root, root.children.slice!]]

  while stack.length > 0
    [node, children] = frame = stack.pop!
    if children.length > 0
      child = children.shift!
      stack.push frame, [child, child.children.slice!]
    else
      node.postorder = n++

class Node then -> @children = []; @label = ''

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

  return pstack.0

$ = document~get-element-by-id

diag = d3.svg.diagonal!projection -> [it.y, it.x]

draw-tree = (ast) !->
  t = d3.layout.tree!
    .size [500 500]
  nodes = t.nodes ast
  links = t.links nodes
  console.log links
  d3.select \#forest
    ..select \.nodes .select-all \.node .data nodes
      ..exit!remove!
      ..enter!append \g .attr class: \node
        ..append \circle .attr class: \node-circle r: 20
        ..append \text .attr class: \node-text
      ..attr do
        transform: -> "translate(#{it.y}, #{it.x})"
        'data-postorder': (.postorder)
      ..select \.node-text .text (.label)
    ..select \.links .select-all \.link .data links
      ..exit!remove!
      ..enter!append \path .attr \class \link
      ..attr \d diag

draw = !->
  return unless @value?
  try
    ast = parse @value
    postorder ast
    $ \output .text-content =
      JSON.stringify ast, void, '  '
    $ \error .text-content = ''
    draw-tree ast
  catch
    $ \error .text-content = e

$ \input
  ..add-event-listener \input draw
  draw.call ..
