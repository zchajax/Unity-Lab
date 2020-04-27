#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 lightDir : TEXCOORD2;
	float4 vertex : SV_POSITION;
};

sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _NoiseTex;

float _FurLength;
float _FurRadius;
float4 _uvOffset;
float4 _Force;
float4 _OcclusionColor;


v2f vert(appdata v)
{
	v2f o;
	v.vertex.xyz += v.normal * _FurLength *  FURSTEP;
	v.vertex.xyz += mul((float3x3)unity_WorldToObject, _Force.xyz) * _Force.w * FURSTEP * FURSTEP * 0.1;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
	o.lightDir = WorldSpaceLightDir(v.vertex);
	return o;
}

fixed4 frag(v2f i) : SV_Target
{
	float occlusion = smoothstep(.0, 0.45, FURSTEP);

	fixed3 albedo = tex2D(_MainTex,i.uv).rgb;
	albedo *= occlusion;

	float3 diff = saturate(dot(i.normal, i.lightDir) * 0.5 + 0.5) * albedo;

	float2 uv = i.uv + _uvOffset.xy * FURSTEP;
	fixed alpha = tex2D(_NoiseTex, uv).r;
	alpha = saturate(alpha - FURSTEP * _FurRadius);

	return fixed4(diff, alpha);
}