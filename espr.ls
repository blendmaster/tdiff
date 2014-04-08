# DOM binding

input1 = $ \input1
error1 = $ \error1
output1 = $ \output1
input2 = $ \input2
error2 = $ \error2
output2 = $ \output2
textmode = $ \textmode

# to work around mouseout not firing when hovering
# children, keep track of actual hovered element so
# we can unhover parent elements
hovered = []
calc-diff = !->
  try
    ast1 = esprima.parse input1.value
    ast2 = esprima.parse input2.value
  catch
    if textmode.checked
      try
        ast1 = text-mode-parse input1.value
        ast2 = text-mode-parse input2.value
      catch
        return
    else
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

        node.add-event-listener \click !->
          return unless it.target is node
          other = $q "\#output2 [data-postorder=\"#mapped\"]"
          {top: o-top} = other.get-bounding-client-rect!
          {top: n-top} = node.get-bounding-client-rect!

          o1-top = parseInt do
            get-computed-style(output1).get-property-value \margin-top
              .slice 0, -2
          o2-top = parseInt do
            get-computed-style(output2).get-property-value \margin-top
              .slice 0, -2

          diff = Math.ceil n-top - o-top

          if diff > 0
            o2-top += diff
            scroll = 0
          else
            o1-top -= diff
            scroll = -diff

          # reset tops to top if both are > 0
          if o1-top and o2-top > 0
            up = o1-top <? o2-top
            scroll -= up
            o1-top -= up
            o2-top -= up

          output1.style.margin-top = "#{o1-top}px"
          output2.style.margin-top = "#{o2-top}px"

          window.scroll-by 0, scroll
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

        node.add-event-listener \click !->
          return unless it.target is node
          other = $q "\#output1 [data-postorder=\"#mapped\"]"
          {top: o-top} = other.get-bounding-client-rect!
          {top: n-top} = node.get-bounding-client-rect!

          o1-top = parseInt do
            get-computed-style(output1).get-property-value \margin-top
              .slice 0, -2
          o2-top = parseInt do
            get-computed-style(output2).get-property-value \margin-top
              .slice 0, -2

          diff = Math.ceil n-top - o-top

          if diff > 0
            o1-top += diff
            scroll = 0
          else
            o2-top -= diff
            scroll = -diff

          # reset tops to top if both are > 0
          if o1-top and o2-top > 0
            up = o1-top <? o2-top
            scroll -= up
            o1-top -= up
            o2-top -= up

          output1.style.margin-top = "#{o1-top}px"
          output2.style.margin-top = "#{o2-top}px"

          window.scroll-by 0, scroll
        , false

    else
      node.class-list.add \added

parse = (input, error, output) -> !->
  try
    ast = esprima.parse input.value, {+range}
  catch
    if textmode.checked
      try
        ast = text-mode-parse input.value, {+range}
      catch
        return
    else
      error.text-content = e
      input.class-list.add \error
      return

  postorder ast

  while output.first-child?
    output.remove-child that

  normalized-code = escodegen.generate ast, format:
    indent: style: ''
    semicolons: false
  normalized-ast = esprima.parse normalized-code, {+range}
  postorder normalized-ast

  output.append-child gen-html normalized-code, normalized-ast

  input.class-list.remove \error
  error.text-content = ''

parse1 = parse input1, error1, output1
parse2 = parse input2, error2, output2

$ \input1 .add-event-listener \input parse1
$ \input2 .add-event-listener \input parse2

parse1!
parse2!

$ \calc .add-event-listener \click calc-diff
