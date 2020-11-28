extends "res://Scenes/Items/ItemController.gd"

#     [Export] public string plantType;
#     [Export] public List<int> growthStages;

#     public long createdAt;
#     public PlantData data;
#     public FarmGridController farmGrid;

#     private int currentGrowthStage;
#     private string plantTypeId;
#     private TileMap waterTile;

#     public override void _EnterTree() {
#       base._EnterTree();

#       if (waterTile == null)
#         waterTile = (TileMap)FindNode("WaterTile");

#       plantTypeId = InventoryItemIDHelper.GetHash(PlantData.plantItemTypeMap[plantType]);
#       growthStages = PlantInfoHelper.plantGrowthStages[plantTypeId];
#       GameTime.TriggerDaybreakEvent += DryWaterAndGrowPlantIfNeeded;
#       currentGrowthStage = DetermineGrowthStage();

#       if (data != null && data.waterHistory.Count > currentGrowthStage && data.waterHistory[currentGrowthStage] > 0)
#         CallDeferred("Water");

#       Node2D growthStage;

#       if (IsHarvestable())
#         growthStage = (Node2D)FindNode($"Stage{growthStages.Count}");
#       else
#         growthStage = (Node2D)FindNode($"Stage{currentGrowthStage}");

#       if (growthStage != null) growthStage.CallDeferred("show");
#     }

#     public override void _ExitTree() {
#       base._ExitTree();
#       GameTime.TriggerDaybreakEvent -= DryWaterAndGrowPlantIfNeeded;
#       Dry();
#       data = null;

#       int stage = 1;

#       while (HasNode($"Stage{stage}")) {
#         Node2D node = (Node2D)FindNode($"Stage{stage}");

#         if (node == null) break;

#         if (stage > 1) node.Hide();
#         else node.Show();

#         stage++;
#       }
#     }

#     public override void Interact() {
#       if (!IsHarvestable() || PlayerController.instance.currentFarmGrid == null) return;

#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions().plant != FarmPermission.Can) {
#         TPV.Scenes.UI.UIController.ShowToast("You don't have permission to harvest crops on this farm!");
#         return;
#       }

#       InventoryBagController bag = InventoryController.instance.bag;

#       if (bag.HasItem(PlantData.plantItemTypeMap[plantType]) == false && bag.HasEmptySlot() == -1) {
#         UIController.ShowToast("Inventory Full!");
#         Logger.Log("TODO: Need to implement multi row inventory");
#         return;
#       }

#       FarmGridData farmData = farmGrid.data;

#       InventoryController.instance.bag.AddItemLocally(PlantData.plantItemTypeMap[plantType]);

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Harvest,
#         data.position,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         plantTypeId
#       ));

#       if (SessionManager.match == null) HarvestRPCMethod(farmData);
#     }

#     public void Water() {
#       waterTile.Show();
#     }

#     public void Dry() {
#       waterTile.Hide();
#     }

#     private async void HarvestRPCMethod(FarmGridData farmData) {
#       bool harvestOk = await farmData.Harvest(
#         MovementGridController.instance.GetCurrentFarmGridTile(),
#         plantTypeId
#       );

#       // if (harvestOk)
#       //   await InventoryController.instance.bag.ReloadBag();
#       // else
#       //   new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));

#       if (!harvestOk)
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }

#     public async void PrimaryAction() {
#       // TODO: "eating" plants should do something? gain experience? Have text denoting refreshing state?

#       // await InventoryController.instance.bag.RemoveItemFromBag(
#       //   PlantData.plantItemTypeMap[plantType]
#       // );
#     }


func ready_for_inventory():
	for i in range(7):
		var node = find_node("Stage%s" % (i + 1))
		if node != null:
			node.hide()

	var inventory_tile = find_node("InventoryTile")
	inventory_tile.show()

#     private bool IsHarvestable() {
#       return currentGrowthStage == growthStages.Count;
#     }

#     public int DetermineGrowthStage() {
#       int growthStageIdx = 0;
#       int dayCounter = 0;
#       long daysPassedSinceCreatedAt = GameTime.NumberOfGameDaysFromDaybreakFromUnixTimestamp(createdAt);

#       for (int i = 0; i < growthStages.Count; i++) {
#         dayCounter += growthStages[i];

#         if (daysPassedSinceCreatedAt >= dayCounter)
#           growthStageIdx = i;
#         else
#           break;
#       }

#       // adding another one if it's "passed" all growth stages and thusly this will trigger IsHarvestable() to return true
#       if (daysPassedSinceCreatedAt > dayCounter) growthStageIdx++;

#       return growthStageIdx;
#     }

#     protected void DryWaterAndGrowPlantIfNeeded() {
#       Dry();

#       int growthStage = DetermineGrowthStage();

#       if (currentGrowthStage >= growthStage) return;

#       Node2D currentStage = (Node2D)FindNode(string.Format("Stage{0}", currentGrowthStage));
#       Node2D nextStage = (Node2D)FindNode(string.Format("Stage{0}", growthStage));
#       Node2D lastStage = (Node2D)FindNode($"Stage{growthStages.Count}");

#       if (!IsHarvestable() && currentStage != null && nextStage != null) {
#         currentStage.Hide();
#         nextStage.Show();
#       } else if (IsHarvestable() && lastStage != null) {
#         lastStage.Show();
#       }

#       currentGrowthStage = growthStage;
#     }
#   }
# }
