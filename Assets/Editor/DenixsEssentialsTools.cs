using UnityEngine;
using UnityEditor;

public class DenixsEssentialsTools : EditorWindow {

    string prevScriptName, newScriptName;
    GameObject[] scriptFiles;
 
    [MenuItem("DenixTools/Essentials")]
    private static void ShowWindow() {
        var window = GetWindow<DenixsEssentialsTools>();
        window.titleContent = new GUIContent("DenixsEssentialsTools");
        window.Show();
    }

    private void OnGUI() {
        if (GUILayout.Button("Execute"))
        {
            //Do this
        }
    }
}