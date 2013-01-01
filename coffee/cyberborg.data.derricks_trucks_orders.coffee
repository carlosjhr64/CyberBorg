CyberBorg::derricks_trucks_orders = (derricks) ->
  # What we're building
  extractor = "A0ResourceExtractor"

  p = (n,x,et) ->
    min: n
    max: x
    number: DORDER_BUILD
    employ: (name) ->
      ('Truck': et)[name]

  # With how many trucks, etc...
  p11 = -> p(1,1,3)

  # Returning an object
  order = (str, x, y, p) ->
    # str, x, y, p = data...
    p.structure = str
    p.at = x: x, y: y
    p

  orders = []
  orders.push(order(extractor, derrick.x, derrick.y, p11())) for derrick in derricks
  WZArray.bless(orders)
