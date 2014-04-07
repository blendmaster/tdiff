{left, right, pwd} = new URI window.location .query true

left = pwd + left unless left.0 is \/
right = pwd + right unless right.0 is \/

err, {response: left} <-! d3.xhr "/file" + left
throw err if err
err, {response: right} <-! d3.xhr "/file" + right
throw err if err

# DOM binding

output1 = $ \output1
output2 = $ \output2

# to work around mouseout not firing when hovering
# children, keep track of actual hovered element so
# we can unhover parent elements
hovered = []
calc-diff = !->
  try
    ast1 = esprima.parse left
    ast2 = esprima.parse right
  catch
    ast1 = text-mode-parse left
    ast2 = text-mode-parse right

  console.time 'ast1'
  f1 = new Tree ast1
  console.time-end 'ast1'
  console.time 'ast2'
  f2 = new Tree ast2
  console.time-end 'ast2'
  console.time 'dist'
  d = new EditDistance f1, f2, COST
  console.time-end 'dist'

  for node in $$ '#output1 .syntax'
    postorder = node.get-attribute \data-postorder
    if d.amap[postorder]?
      let mapped = that, postorder
        node.class-list.add \mapped
        node.add-event-listener \mouseenter !->
          for $$ ".hover"
            ..class-list.remove \hover

          @class-list.add \hover
          hovered.push [mapped, postorder]
          $q "\#output2 [data-postorder=\"#mapped\"]"
            .class-list.add \hover
        , false

        node.add-event-listener \mouseleave !->
          for $$ ".hover"
            ..class-list.remove \hover
          hovered.pop!
          if hovered[*-1]?
            $q "\#output2 [data-postorder=\"#{that.0}\"]"
              .class-list.add \hover
            $q "\#output1 [data-postorder=\"#{that.1}\"]"
              .class-list.add \hover
        , false
    else
      node.class-list.add \deleted
  for node in $$ '#output2 .syntax'
    postorder = node.get-attribute \data-postorder
    if d.bmap[postorder]?
      let mapped = that, postorder
        node.class-list.add \mapped
        node.add-event-listener \mouseenter !->
          for $$ ".hover"
            ..class-list.remove \hover

          @class-list.add \hover
          hovered.push [mapped, postorder]
          $q "\#output1 [data-postorder=\"#mapped\"]"
            .class-list.add \hover
        , false

        node.add-event-listener \mouseleave !->
          for $$ ".hover"
            ..class-list.remove \hover
          hovered.pop!
          if hovered[*-1]?
            $q "\#output1 [data-postorder=\"#{that.0}\"]"
              .class-list.add \hover
            $q "\#output2 [data-postorder=\"#{that.1}\"]"
              .class-list.add \hover
        , false
    else
      node.class-list.add \added

parse = (input, output) ->
  try
    ast = esprima.parse input, {+range}
  catch
    ast = text-mode-parse input, {+range}

  postorder ast

  while output.first-child?
    output.remove-child that

  normalized-code = escodegen.generate ast, format:
    indent: style: ''
    semicolons: false
  normalized-ast = esprima.parse normalized-code, {+range}
  postorder normalized-ast

  output.append-child gen-html normalized-code, normalized-ast

parse left, $ \output1
parse right, $ \output2
calc-diff!
