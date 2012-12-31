CyberBorg::derricks_orders = (derricks) ->
  # What we're building
  extractor = "A0ResourceExtractor"

  # With how many trucks
  p = (n,x) -> min: n, max:x
  p11 = -> p(1,1)

  # Returning an object
  order = (str, x, y, p) ->
    # str, x, y, p = data...
    p.structure = str
    p.at = x: x, y: y
    p

  orders = []
  orders.push(order(extractor, derrick.x, derrick.y, p11)) for derrick in derricks
  WZArray.bless(orders)
