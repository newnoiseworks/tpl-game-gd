extends CanvasLayer

# using Godot;
# using System.Threading.Tasks;
# using static Godot.Tween;

# namespace TPV.Scenes.UI {

#   public class UIController : CanvasLayer {

#     public static UIController instance;

#     private Label savingLabel;
#     private Label toastLabel;
#     private WindowDialog loadingDialog;
#     private Tween tween;

#     public override void _Ready() {
#       savingLabel = (Label)GetNode("Container/TopLeft/SavingLabel");
#       toastLabel = (Label)FindNode("AlertLabel");
#       loadingDialog = (WindowDialog)GetNode("Modals/LoadingDialog");
#       tween = (Tween)FindNode("Tween");
#       instance = this;
#     }

#     public override void _ExitTree() {
#       instance = null;
#     }

#     public static void ShowSavingIndicator() {
#       if (instance == null) return;
#       instance.savingLabel.Show();
#     }

#     public static void HideSavingIndicator() {
#       if (instance == null) return;
#       instance.savingLabel.Hide();
#     }

#     public static void ShowLoadingDialog() {
#       if (instance == null) return;
#       instance.loadingDialog.Show();
#     }

#     public static void HideLoadingDialog() {
#       if (instance == null) return;
#       instance.loadingDialog.Hide();
#     }

#     public static async void ShowToast(string message) {
#       // TODO: YO USE THE SEMAPHORE LIB TO QUEUE INCOMING MESSAGES
#       instance.toastLabel.Text = message;

#       await Task.Delay(1);

#       instance.toastLabel.Show();
#       Vector2 startingPoint = instance.toastLabel.RectPosition + new Vector2(800, 0);
#       Vector2 originalPosition = instance.toastLabel.RectPosition;
#       instance.toastLabel.RectPosition = startingPoint;

#       instance.tween.InterpolateProperty(
#         instance.toastLabel,
#         "rect_position",
#         startingPoint,
#         originalPosition,
#         1.5f,
#         TransitionType.Quint,
#         EaseType.Out
#       );

#       instance.tween.Start();

#       await Task.Delay(5000);

#       instance.toastLabel.Hide();
#     }
#   }
# }
