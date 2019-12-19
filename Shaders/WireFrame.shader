Shader "Unlit/WireFrame"
{
    Properties
    {
        _WireframeColor ("Wireframe Color", Color) = (0, 0, 0)
		_WireframeSmoothing ("Wireframe Smoothing", Range(0, 10)) = 1
		_WireframeThickness ("Wireframe Thickness", Range(0, 10)) = 0
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Transparent"  
			"Queue" = "Transparent"
		}

        LOD 100

		Zwrite Off
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

			float3 _WireframeColor;
			float _WireframeSmoothing;
			float _WireframeThickness;

            struct appdata
            {
                float4 vertex : POSITION;
            };

			struct v2g
			{
				float4 vertex : SV_POSITION;
			};

            struct g2f
            {
                float4 vertex : SV_POSITION;
				float2 barycentricCoord : TEXCOORD1;
            };

			v2g vert (appdata v)
            {
				v2g o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triSteam)
			{
				g2f o[3];

				o[0].barycentricCoord = float2(1, 0);
				o[1].barycentricCoord = float2(0, 1);
				o[2].barycentricCoord = float2(0, 0);

				for (int i = 0; i < 3; i++)
				{
					o[i].vertex = IN[i].vertex;
					triSteam.Append(o[i]);
				}

				triSteam.RestartStrip();
			}

            fixed4 frag (g2f i) : SV_Target
            {
				fixed4 col;

				float3 barys;
				barys.xy = i.barycentricCoord;
				barys.z = 1 - barys.x - barys.y;
				float3 deltas = fwidth(barys);
				float3 smoothing = deltas * _WireframeSmoothing;
				float3 thickness = deltas * _WireframeThickness;
				barys = smoothstep(thickness, thickness + smoothing, barys);
				float minBary = min(barys.x, min(barys.y, barys.z));

				col.xyz = _WireframeColor;
				col.a = 1 - minBary;

           
                return col;
            }
            ENDCG
        }
    }
}
