## Script name: TravelIndicator
##
## Creates animated arrow effect to indicate unit travel intentions
class_name TravelIndicator

extends Path2D

var playing : bool = true

## 32x32 
var arrow = preload("res://prefabs/visuals/pathArrow.tscn")

func _init(newCurve : Curve2D) -> void:
	curve = newCurve

func _ready() -> void:
	var follows = (curve.point_count - 1) * 2.0

	var newPosition : float  = 0.0
	
	var pLength = curve.get_baked_length()
	var increment : float =  pLength / follows
	print(str(follows))
	for i in follows:
		var newArrow = arrow.instantiate()
		add_child(newArrow)
		newArrow.progress = newPosition
		newPosition = float(newPosition) + float(increment)

func updatePath(newCurve : Curve2D):
	##TODO refactor to only remove appropriate arrows at a time and reposition
	for node in get_children():
		node.queue_free()
	var follows = (curve.point_count - 1) * 2.0
	curve = newCurve
	
	var newPosition : float  = 0.0
	
	var pLength = curve.get_baked_length()
	var increment : float =  pLength / follows
	print(str(follows))
	for i in follows:
		var newArrow = arrow.instantiate()
		add_child(newArrow)
		newArrow.progress = newPosition
		newPosition = float(newPosition) + float(increment)
