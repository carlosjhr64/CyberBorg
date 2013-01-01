CyberBorg::derricks_orders = (derricks) ->
  # What we're building
  extractor = "A0ResourceExtractor"

  p = (n,x,et,em) ->
    min: n
    max: x
    employ: (name) ->
      ('Truck': et, 'MgWhB1': em)[name]

  # With how many trucks, etc...
  p11 = -> p(1,1,3,9)

  # Returning an object
  order = (str, x, y, p) ->
    # str, x, y, p = data...
    p.structure = str
    p.at = x: x, y: y
    p

  orders = []
  orders.push(order(extractor, derrick.x, derrick.y, p11())) for derrick in derricks
  WZArray.bless(orders)
