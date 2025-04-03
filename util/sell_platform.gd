extends StaticBody3D
@onready var area_3d: Area3D = $Area3D
@onready var label_3d: Label3D = $MeshInstance3D2/Label3D

func _process(_delta: float) -> void:
	var amount:int = 0
	for i in area_3d.get_overlapping_bodies():
		if i is PickupableItem and i.has_node("SellableComponent"):
			var sellable_component: SellableComponent = i.get_node("SellableComponent")
			amount += sellable_component.cost
	label_3d.text = _convert_num(amount)

func _convert_num(amount:int):
	if amount >= 1_000_000:
		return str(int(amount) / 1_000_000).replace(",", ".") + "m " + "$"
	elif amount >= 1_000:
		return str(int(amount) / 1_000).replace(",", ".") + "k " + "$"
	else:
		return str(amount) + "$"
