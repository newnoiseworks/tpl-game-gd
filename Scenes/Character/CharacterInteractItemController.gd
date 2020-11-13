extends "res://Scenes/Items/ItemController.gd"

onready var character = get_parent()  # : CharacterController.gd


func interact():
	character.interact()

#     public override void _Ready() {
#       base._Ready();
#       character = GetParent() as CharacterController;
#     }

#     public override void Interact() {
#       character.Interact();
#     }
#   }
# }
