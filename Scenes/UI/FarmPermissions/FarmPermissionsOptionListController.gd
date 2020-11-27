extends VBoxContainer

var userId: String
var farm_collection: String

var data
var perms_dict: Dictionary = {}
var perms

onready var permissionRowScene = ResourceLoader.load(
	"res://Scenes/UI/FarmPermissions/FarmPermissionOption.tscn"
)
onready var items: VBoxContainer = find_node("ItemList")

#     public async override void _Ready() {
#       items = (VBoxContainer)FindNode("ItemList");
#       data = new FarmPermissionsData(farmCollection);

#       await data.Load();

#       if (data.permCollection.ContainsKey(userId) == false) {
#         FarmPermissions copiedDefaults = new FarmPermissions();
#         copiedDefaults.FromJSON(data.defaultPermissions.ForJSON().ToJson());
#         data.permCollection.Add(userId, copiedDefaults);
#       }

#       perms = data.permCollection[userId];

#       permsDict = new Dictionary<string, FarmPermission>() {
#         { "Plant", perms.plant },
#         { "Harvest", perms.harvest },
#         { "Till", perms.till },
#         { "Water", perms.water },
#         { "Forage", perms.forage },
#       };

#       foreach (KeyValuePair<string, FarmPermission> pair in permsDict) {
#         FarmPermissionOptionController permissionRow = (FarmPermissionOptionController)permissionRowScene.Instance();
#         permissionRow.toggleOn = pair.Value == FarmPermission.Can;
#         permissionRow.labelText = pair.Key;
#         permissionRow.Connect(nameof(FarmPermissionOptionController.PermissionToggled), this, "Toggle");
#         NodeManager.ScheduleAdd(items, permissionRow);
#       }
#     }

#     public void Toggle(string permType, bool on) {
#       FarmPermission permission = on ? FarmPermission.Can : FarmPermission.Cannot;

#       if (permsDict.ContainsKey(permType)) {
#         switch (permType) {
#           case "Plant":
#             perms.plant = permission;
#             break;
#           case "Harvest":
#             perms.harvest = permission;
#             break;
#           case "Till":
#             perms.till = permission;
#             break;
#           case "Water":
#             perms.water = permission;
#             break;
#           case "Forage":
#             perms.forage = permission;
#             break;
#         }
#       }
#     }

#     public async void Save() {
#       await data.Save();
#       new FarmPermissionsUpdateEvent(new FarmPermissionUpdateEventArgs(), SessionManager.GetUserId());
#     }
#   }
# }
