@tool
extends RichTextLabel

func _process(_delta):
  clear()
  push_table(2)
  add_cell("FPS")
  add_cell(Performance.get_monitor(Performance.TIME_FPS))
  add_cell("Nodes")
  add_cell(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
  add_cell("Resources")
  add_cell(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
  add_cell("Objects")
  add_cell(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
  add_cell("Primitives")
  add_cell(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
  add_cell("Draw Calls")
  add_cell(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
  pop()

func add_cell(content):
  push_cell()
  add_text(str(content))
  pop()
