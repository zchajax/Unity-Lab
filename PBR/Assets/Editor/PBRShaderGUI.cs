using UnityEngine;
using UnityEditor;
using System;

public class PBRShaderGUI : ShaderGUI
{
    Material target;
    MaterialEditor editor;
    MaterialProperty[] properties;

    enum DiffuseMode
    {
        None, Lambert, Disney, Oren_Nayar
    }

    static GUIContent staticLabel = new GUIContent();

    static GUIContent MakeLabel(string text, string tooltip = null)
    {
        staticLabel.text = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.target = materialEditor.target as Material;
        this.editor = materialEditor;
        this.properties = properties;

        DoDiffuseMode();

        base.OnGUI(materialEditor, properties);
    }

    void DoDiffuseMode()
    {
        DiffuseMode source = DiffuseMode.None;
        if (IsKeywordEnabled("_DIFFUSE_LAMBERT"))
        {
            source = DiffuseMode.Lambert;
        }
        else if (IsKeywordEnabled("_DIFFUSE_DISNEY"))
        {
            source = DiffuseMode.Disney;
        }
        else if (IsKeywordEnabled("_DIFFUSE_OREN_NAYER"))
        {
            source = DiffuseMode.Oren_Nayar;
        }

        EditorGUI.BeginChangeCheck();
        source = (DiffuseMode)EditorGUILayout.EnumPopup(
            MakeLabel("Diffuse Mode"), source
        );
        if (EditorGUI.EndChangeCheck())
        {
            SetKeyword("_DIFFUSE_LAMBERT", source == DiffuseMode.Lambert);
            SetKeyword("_DIFFUSE_DISNEY", source == DiffuseMode.Disney);
            SetKeyword("_DIFFUSE_OREN_NAYER", source == DiffuseMode.Oren_Nayar);
        }
    }

    void SetKeyword(string keyword, bool state)
    {
        if (state)
        {
            target.EnableKeyword(keyword);
        }
        else
        {
            target.DisableKeyword(keyword);
        }
    }

    bool IsKeywordEnabled(string keyword)
    {
        return target.IsKeywordEnabled(keyword);
    }
}


