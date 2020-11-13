extends Node2D

export var on_ground: bool
export var is_crafted: bool
export var crafted_item_type: String

var current_interacting_player: Node2D
var tile_map: TileMap
var tile_map_node: Node
var base_z_index: int

onready var interaction_area: Area2D = find_node("InteractionArea")
onready var colliding_characters: Array = []
onready var tween: Tween = $Tween


func _ready():
	if has_node("Variants"):
		for map in $Variants.get_children():
			if map.visible:
				tile_map_node = map
				break
	else:
		tile_map_node = get_node("TileMap")

	tile_map = tile_map_node
	base_z_index = z_index


func on_body_enter(_body: PhysicsBody2D):
#       PlayerController player = body as PlayerController;

#       if (player != null && player.itemUnderTarget == this && !InputController.Moving()) {
#         currentInteractingPlayer = player;
#         TPV.Utils.Logger.Log("item interaction");
#         CallDeferred("Interact");
	pass


func on_body_exit(_body: PhysicsBody2D):
#       PlayerController player = body as PlayerController;

#       if (player != null && currentInteractingPlayer == player)
#         currentInteractingPlayer = null;

#       MovementGridController grid = body as MovementGridController;

#       if (grid != null && PlayerController.instance?.itemUnderTarget == this)
#         PlayerController.instance.itemUnderTarget = null;
	pass

#     public override void _ExitTree() {
#       if (PlayerController.instance != null && PlayerController.instance.itemUnderTarget == this)
#         PlayerController.instance.itemUnderTarget = null;
#     }

#     public void SetCollisionMaskOnInteractionArea(uint mask) {
#       if (interactionArea != null)
#         interactionArea.CollisionMask = mask;
#     }

#       MovementGridController grid = body as MovementGridController;

#       if (grid != null) {
#         PlayerController.instance.itemUnderTarget = this;
#       }
#     }

#     public virtual void Interact() {
#       Logger.Log("base interact with item");
#     }

#     public virtual void OnWalkBehindTriggerEnter(PhysicsBody2D body) {
#       baseZIndex = ZIndex;
#       CharacterController character = body as CharacterController;
#       PlayerController player = body as PlayerController;

#       if (character == null) return;

#       collidingCharacters.Add(character);

#       if (player != null) {
#         tween.InterpolateProperty(
#           tileMapNode,
#           "modulate",
#           tileMap.Modulate,
#           new Color(1, 1, 1, 0.3f),
#           0.33f,
#           Tween.TransitionType.Linear,
#           Tween.EaseType.In
#         );

#         LightOccluder2D light = FindNode("LightOccluder2D") as LightOccluder2D;

#         if (light != null) light.Hide();
#       }

#       // FUCK: WARNING - ENTERING MAGIC NUMBER FUCKERY
#       ZIndex = baseZIndex + 3;

#       tween.Start();
#     }

#     public virtual void OnWalkBehindTriggerExit(PhysicsBody2D body) {
#       CharacterController character = body as CharacterController;
#       PlayerController player = body as PlayerController;

#       if (character == null) return;

#       if (collidingCharacters.Contains(character)) collidingCharacters.Remove(character);

#       if (collidingCharacters.Count == 0)
#         ZIndex = baseZIndex;

#       if (player != null) {
#         tween.Stop(tileMapNode);

#         tween.InterpolateProperty(
#           tileMapNode,
#           "modulate",
#           tileMap.Modulate,
#           new Color(1, 1, 1, 1),
#           0.33f,
#           Tween.TransitionType.Linear,
#           Tween.EaseType.In
#         );

#         if (tween.IsInsideTree()) tween.Start();

#         LightOccluder2D light = FindNode("LightOccluder2D") as LightOccluder2D;

#         if (light != null) light.Show();
#       }
#     }

#     protected async void PlaceCraftedItemOnFarmGrid() {
#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (isCrafted == false || farmGrid == null) return;

#       Vector2 gridPosition = MovementGrid.MovementGridController.instance.GetCurrentFarmGridTile();

#       if (farmGrid.IsUserOwner() == false) {
#         TPV.Scenes.UI.UIController.ShowToast("You can't put crafted items on someone else's farm.");
#         return;
#       }

#       if (farmGrid.HasFarmItem(gridPosition)) return;

#       FarmGridData farmData = farmGrid.data;
#       string itemHash = InventoryItemIDHelper.GetHash(
#         InventoryItemIDHelper.GetEnumFromName($"Crafted_{craftedItemType}")
#       );

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.PlaceCraftedItem,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         itemHash
#       ));

#       if (SessionManager.match == null) {
#         if (await farmData.PlaceCraftedItem(
#           gridPosition,
#           itemHash
#         )) {
#           await InventoryController.instance.bag.ReloadBag();
#         } else {
#           new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#         }
#       } else {
#         InventoryController.instance.bag.RemoveItemLocally(InventoryItemIDHelper.GetEnum(itemHash));
#       }
#     }

#     protected async void RemoveCraftedItemOnFarmGrid() {
#       if (isCrafted == false || PlayerController.instance.currentFarmGrid == null) return;

#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;
#       FarmGridData farmData = farmGrid.data;
#       Vector2 gridPosition = MovementGrid.MovementGridController.instance.GetCurrentFarmGridTile();
#       string itemHash = InventoryItemIDHelper.GetHash(
#         InventoryItemIDHelper.GetEnumFromName($"Crafted_{craftedItemType}")
#       );

#       if (farmGrid.IsUserOwner() == false) {
#         TPV.Scenes.UI.UIController.ShowToast("You can't steal crafted items. Tsk!");
#         return;
#       }

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.RemoveCraftedItem,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         itemHash
#       ));

#       if (SessionManager.match == null) {
#         if (await farmData.RemoveCraftedItem(
#           gridPosition,
#           itemHash
#         )) {
#           await InventoryController.instance.bag.ReloadBag();
#         } else {
#           new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#         }
#       } else {
#         InventoryController.instance.bag.AddItemLocally(InventoryItemIDHelper.GetEnum(itemHash));
#       }
#     }
#   }
# }
