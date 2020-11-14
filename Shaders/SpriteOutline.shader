Shader "Custom/SpriteOutline"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _Width("Outline Width", Range(0, 0.1)) = 0.005
        _OutlineColor("OutlineColor", Color) = (1,1,1,1)
        [MaterialToggle] Outline("Outline", Float) = 0

    }
    SubShader
    {
       Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ OUTLINE_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Width;
            float4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= col.a;


            #ifdef OUTLINE_ON
                float sLeft = tex2D(_MainTex, i.uv + float2(_Width, 0)).a;
                float sRight = tex2D(_MainTex, i.uv - float2(_Width, 0)).a;
                float sTop = tex2D(_MainTex, i.uv - float2(0, _Width)).a;
                float sBottom = tex2D(_MainTex, i.uv + float2(0, _Width)).a;
                float outline = sLeft + sRight + sTop + sBottom;

                outline *= (1.0 - col.a);
                col.a += outline;
                col.rgb += outline * _OutlineColor;
            #endif

                return col;
            }
            ENDCG
        }
    }
}
