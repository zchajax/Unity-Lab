Shader "Custom/Kajiya-kayHair"
{
	Properties
	{
		[Header(Hair Rendering)]
		[NoScaleOffset]_TangentShiftMap("Tangent ShiftMap", 2D)= "white"{}
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularStrength("_Specular Strength", Range(0, 1)) = 0.5
		_PrimaryShift("Primary Shift", Range(-5, 5)) = 1
		
		[Space(30)]
		
		_MainTex("Texture", 2D) = "white"{}
		_Color("Tint Color", Color) = (1, 1, 1, 1)
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
	}
	
	SubShader
	{
		Tags {"RenderType" = "Opaque"}
		LOD 100
		
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
		}
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 5.0
		
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "UnityStandardBRDF.cginc"
		
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
		}
		
		struct v2f
		{
			half3 normal : TEXCOORD0;
			half3 bitangent : TEXCOORD1;
			float2 uv : TEXCOORD2;
			float3 pos1 : POSITION1;
			float4 pos : SV_POSITION;
		}
		
		sampler2D _TangentShiftMap;
		fixed4 _SpecularColor;
		float _SpecularStrength;
		float _PrimaryShift;
		
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		float _Smoothness;
		
		half3 ShiftedTangent(float3 t, float3 n, float shift)
		{
			return normalize(t + shift * n);
		}
		
		float StrandSpecular(float3 T, float3 V, float3 L, int exponent)
		{
			float3 H = normalize(L + V);
			float dotTH = dot(T, H);
			float sinTH = sqrt(1.0 - dotTH * dotTH);
			float dirAtten = smoothstep(-1, 0 , dotTH);
			return dirAtten * pow(sinTH, exponent);
		}
		
		float3 HairSpecular(float3 t, float n, float3 l, float3 v, float2 uv)
		{
			float shiftTex = tex2D(_TangentShiftMap, uv) - 0.5;
			float3 t1 = ShiftedTangent(t, n, _PrimaryShift + shiftTex);
			float3 specular = _SpecularColor * StrandSpecular(t1, v, l, 20) * _SpecularStrength;
			return specular;
		}
		
		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			
			half3 wNormal = UnityObjectToWorldNormal(v.normal);
			half3 wTangent = UnityObjectToWorldNormal(v.tangent.xyz);
			half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
			half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
			o.normal = wNormal;
			o.bitangent = wBitangent;
			o.pos1 = mul(unity_ObjectToWorld, v.vertex);
			return o;
		}
		
		ENDCG
	}
}
