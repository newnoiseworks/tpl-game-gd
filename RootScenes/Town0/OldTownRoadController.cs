using System.Collections.Generic;
using Godot;
using TPV.Utils.Network;
using TPV.GameEvents.RealmEvents;
using Nakama;
using TPV.Scenes.MovementGrid;
using TPV.RootScenes.Farm;
using TPV.Scenes.Items.EnvironmentItems.Objects;

namespace TPV.RootScenes.Town0 {

  public class OldTownRoadController : DungeonController {

    private PackedScene playerContextMenuScene = (PackedScene)ResourceLoader.Load("res://Scenes/UI/PlayerContextMenu.tscn");
    private TeleporterController townTeleporter;

    public override void _Ready() {
      SetupTeleporter();

      base._Ready();

      SessionManager.realmSocket.ReceivedMatchPresence += OnMatchPresenceEvent;
      RealmJoinEvent.Subscribe(RealmJoinEventResponse);
      ChangeDungeonEvent.SubscribeAll(ChangeDungeonEventResponse);

      ReloadDataAndRedraw();
    }

    public override void _ExitTree() {
      RealmJoinEvent.Unsubscribe(RealmJoinEventResponse);
      ChangeDungeonEvent.UnsubscribeAll(ChangeDungeonEventResponse);

      base._ExitTree();
    }

    public void SetupTeleporter() {
      townTeleporter = (TeleporterController)FindNode("TownTeleporter");

      switch (TeleporterController.lastScene) {
        case "town0":
          townTeleporter.exitEnabled = false;
          playerEntryNode = townTeleporter;
          break;
        default:
          int plot = RealmManager.plotMap[FarmController.userIdToJoin];
          FarmTeleporterController farmTeleporter = (FarmTeleporterController)FindNode($"FarmTeleporter{plot}");
          farmTeleporter.exitEnabled = false;
          playerEntryNode = farmTeleporter;
          break;
      }
    }

    public void ReloadDataAndRedraw() {
      for (int i = 0; i < 8; i++) {
        FarmTeleporterController tele = (FarmTeleporterController)FindNode($"FarmTeleporter{i}");
        tele.enabled = false;

        ((MailboxController)FindNode($"MailBox{i}")).HideAndDisable();
      }

      foreach (KeyValuePair<string, int> pair in RealmManager.plotMap) {
        FarmTeleporterController tele = (FarmTeleporterController)FindNode($"FarmTeleporter{pair.Value}");
        tele.enabled = true;
        tele.userIdToJoin = pair.Key;
        tele.userAvatarToJoin = RealmManager.userIdToAvatarMap[pair.Key];

        ((MailboxController)FindNode($"MailBox{pair.Value}")).SetUserAndShow(tele.userIdToJoin, tele.userAvatarToJoin);

        if (pair.Key == FarmController.userIdToJoin && TeleporterController.lastScene != "town0")
          tele.exitEnabled = false;
        else
          tele.exitEnabled = true;
      }
    }

    private void OnMathPresenceEvent(IMatchPresenceEvent matchEvent) {
      CallDeferred("ReloadDataAndRedraw");
    }

    private void RealmJoinEventResponse(RealmJoinEventArgs args) {
      CallDeferred("ReloadDataAndRedraw");
    }

    private void ChangeDungeonEventResponse(ChangeDungeonEventArgs args, string userId) {
      CallDeferred("ReloadDataAndRedraw");
    }
  }
}
