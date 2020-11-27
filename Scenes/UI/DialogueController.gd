extends Control

# using Godot;
# using System;
# using System.Collections.Generic;
# using System.Timers;
# using TPV.Utils;
# using TPV.Scenes.Character.Farmer;

# namespace TPV.Scenes.UI {

#   public class DialogueController : Control {

#     public static Dictionary<string, DialogueScript> dialogueScripts = new Dictionary<string, DialogueScript>();
#     public delegate void DialogueScript();

#     public const int TYPEWRITER_SPEED = 25;
#     public const int MAX_DIALOGUE_CHARS = 90;
#     public const int MAX_DIALOGUE_CHARS_WITH_AVATAR = 75;
#     public const string ELIPSES = "...";

#     private RichTextLabel currentText;
#     private RichTextLabel dialogueText;
#     private RichTextLabel text;
#     private TileMap avatarTilemap;
#     private ItemList optionList;
#     private TextEdit whomst;

#     private static Vector2 avatarTile = new Vector2(0, 0);
#     private static DialogueController instance;
#     private static System.Timers.Timer typeTimer;
#     private static int nextCharPos;
#     private static char[] bbcode;
#     private static bool isTyping;
#     private static Dictionary<string, string> dialogueStep;
#     private static List<Dictionary<string, string>> dialogueOptions = new List<Dictionary<string, string>>();
#     private static int nextDialogueOptionIndex = -1;
#     private static bool cutOffBBCode;
#     private static string filename;

#     public override void _Ready() {
#       instance = this;
#       text = currentText = (RichTextLabel)FindNode("Dialogue");
#       dialogueText = (RichTextLabel)FindNode("AvatarDialogue");
#       optionList = (ItemList)FindNode("Options");
#       whomst = (TextEdit)FindNode("WhomstContainer");
#       avatarTilemap = (TileMap)FindNode("TileMap");
#       typeTimer = new System.Timers.Timer(TYPEWRITER_SPEED);
#       typeTimer.AutoReset = false;

#       typeTimer.Elapsed += TypeTimerElapsed;
#     }

#     public override void _Input(InputEvent @event) {
#       if (Visible == false) return;

#       if (
#       @event.IsActionReleased("action_one")
#       ||
#       @event.IsActionReleased("action_two")
#       ) {
#         if (isTyping)
#           isTyping = false;
#         else if (cutOffBBCode)
#           ContinueBBCode();
#         else if (nextDialogueOptionIndex > -1)
#           HandleOptionSelection();
#         else if (dialogueStep[I18n.optionsKey] != null)
#           StartOptions();
#         else if (dialogueStep[I18n.nextKey] != null)
#           Start(I18n.GetDialogueStep(filename, dialogueStep[I18n.nextKey]));
#         else if (dialogueStep[I18n.scriptKey] != null)
#           RunScript(dialogueStep);
#         else if (Visible) {
#           GetTree().SetInputAsHandled();
#           HideDialogs();
#         }
#       }
#     }

#     public static void HideDialogs() {
#       instance.Hide();
#       PlayerController.UnlockMovement();
#     }

#     public void DialogueOptionSelected(int index) {
#       nextDialogueOptionIndex = index;
#     }

#     // WELP: It would be really nice if, as a precautionary measure, we checked the Dialogue file for any "script" references, and then make sure that DialogueController.dialogueScripts contains delegates for every corresponding key before starting.
#     public static void Start(
#       string filename,
#       string section
#     ) {
#       DialogueController.filename = filename;

#       Start(I18n.GetDialogueStep(filename, section));
#     }

#     public static void Start(Dictionary<string, string> dialogueStep) {
#       PlayerController.LockMovement();
#       DialogueController.dialogueStep = dialogueStep;
#       UpdateSpeaker();
#       instance.optionList.Hide();
#       nextDialogueOptionIndex = -1;
#       nextCharPos = 0;
#       isTyping = true;

#       if (cutOffBBCode)
#         cutOffBBCode = false;
#       else
#         bbcode = dialogueStep[I18n.textKey].ToCharArray();

#       instance.currentText.BbcodeText = "";
#       instance.Show();
#       Typewrite();
#     }

#     private static void Typewrite() {
#       if (
#       instance.currentText == instance.text ?
#       instance.currentText.Text.Length >= MAX_DIALOGUE_CHARS
#       :
#       instance.currentText.Text.Length >= MAX_DIALOGUE_CHARS_WITH_AVATAR
#       &&
#       bbcode[nextCharPos - 1].ToString() == " "
#       ) {
#         isTyping = false;
#         bbcode = new String(bbcode).Replace(instance.currentText.BbcodeText, "... ").ToCharArray();
#         instance.currentText.BbcodeText += ELIPSES;
#         cutOffBBCode = true;
#         return;
#       } else if (nextCharPos >= bbcode.Length) {
#         isTyping = false;
#         return;
#       }

#       TypeNextCharacter();
#     }

#     private static void TypeNextCharacter() {
#       bool passed = false;
#       string text = bbcode[nextCharPos].ToString();

#       while (passed == false) {
#         try {
#           nextCharPos++;
#           instance.currentText.BbcodeText += text;
#           passed = true;
#         } catch {
#           text += bbcode[nextCharPos];
#         }
#       }

#       if (isTyping)
#         typeTimer.Start();
#       else
#         Typewrite();
#     }

#     private static void TypeTimerElapsed(
#       object sender,
#       ElapsedEventArgs e
#     ) {
#       typeTimer.Stop();
#       Typewrite();
#     }

#     private static void UpdateSpeaker() {
#       instance.text.BbcodeText = "";
#       instance.dialogueText.BbcodeText = "";
#       instance.avatarTilemap.Clear();
#       instance.currentText = instance.text;
#       instance.whomst.Hide();

#       if (dialogueStep[I18n.whomKey] != null) {
#         string characterName = dialogueStep[I18n.whomKey];

#         instance.whomst.Show();
#         instance.whomst.Text = characterName.Trim();

#         int portraitTile = instance.avatarTilemap.TileSet.FindTileByName($"Characters/NPC PORTRAITS/{characterName}/Standard Face");

#         if (portraitTile > -1) {
#           instance.currentText = instance.dialogueText;
#           instance.avatarTilemap.SetCellv(avatarTile, portraitTile);
#         } else {
#           instance.avatarTilemap.Clear();
#         }
#       }
#     }

#     private static void StartOptions() {
#       string[] options = dialogueStep[I18n.optionsKey].Replace(" ", "").Split(',');
#       dialogueOptions.Clear();
#       instance.optionList.Clear();
#       instance.optionList.Show();

#       foreach (string optionKey in options) {
#         Dictionary<string, string> dialogueOption = I18n.GetDialogueStep(filename, optionKey);
#         dialogueOptions.Add(dialogueOption);
#         instance.optionList.AddItem(dialogueOption[I18n.optionTextKey]);
#       }
#     }

#     private static void HandleOptionSelection() {
#       var option = dialogueOptions[nextDialogueOptionIndex];

#       if (option[I18n.scriptKey] != null)
#         RunScript(option);
#       else
#         Start(option);
#     }

#     private static void ContinueBBCode() {
#       Start(dialogueStep);
#     }

#     private static void RunScript(Dictionary<string, string> dialogueStep) {
#       DialogueController.dialogueStep = dialogueStep;
#       instance.optionList.Hide();
#       nextDialogueOptionIndex = -1;
#       instance.CallDeferred("HideDialogs"); // will unlock player movement

#       RunScriptFromStep();
#     }

#     private static void RunScriptFromStep() {
#       string scriptKey = dialogueStep[I18n.scriptKey];

#       if (dialogueScripts.ContainsKey(scriptKey))
#         dialogueScripts[scriptKey].Invoke();
#       else
#         Logger.Log($"Dialogue scriptKey not defined, check initial DialogueController.Start() call and make sure DialogueController.dialogScripts[\"{scriptKey}\"] is setup w/ a callback");
#     }

#     public static void Conceal() {
#       if (instance == null) return;

#       instance.Hide();
#     }
#   }
# }
