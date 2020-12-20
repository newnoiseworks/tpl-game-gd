extends Node2D

var mission_data: Dictionary


func _ready():
	for mission in SessionManager.mission_data.missions:
		if mission.key == "pickupYorksHearts":
			mission_data = mission

  if ! "context" in mission_data: return

	for picked_up_hearts in mission_data.context:
		var heart_node = find_node("YorkHeart%s" % picked_up_hearts)

		if (heart_node != null):
			heart_node.queue_free()
