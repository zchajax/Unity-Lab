Shader "Custom/PBR"
{
    Properties
    {
        _Albedo("Albedo", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Roughness("Roughness", Range(0.0001, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define PI 3.14159265358979323846264338327950288419716939937510

            #pragma shader_feature __ _DIFFUSE_LAMBERT _DIFFUSE_DISNEY _DIFFUSE_OREN_NAYER

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float4 _Albedo;
            float4 _Specular;
            float  _Roughness;

#if _DIFFUSE_LAMBERT
            float3 lambert(float albedo)
            {
                return albedo / PI;
            }
#endif

#if _DIFFUSE_DISNEY
            float3 disney(float3 baseColor, float roughness, float hl, float nl, float nv)
            {
				float fd90 = 0.5 + 2 * pow(hl, 2) * roughness;
				return  baseColor / PI * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5)); 
			}
#endif
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 albedo = _Albedo;
                float roughness = _Roughness;
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 normal = normalize(i.worldNormal);
                float3 halfVector = normalize(lightDir + viewDir);
                
                
                float nl = saturate(dot(normal, lightDir));
                float nh = saturate(dot(normal, halfVector));
                float hl = saturate(dot(halfVector, lightDir));
                float nv = saturate(dot(normal, viewDir));

                float3 diffuseTerm = 0;

                #if _DIFFUSE_LAMBERT
                    diffuseTerm = lambert(albedo);
                #endif

                #if _DIFFUSE_DISNEY
                    diffuseTerm = disney(albedo, roughness, hl, nl, nv); 
                #endif

                float3 specularTerm = 0;
                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

                fixed4 col = 0;
                col.rgb = (diffuseTerm + specularTerm) * _LightColor0.rbg * nl + ambient;
                return col;
            }
            
            ENDCG
        }
    }
    CustomEditor "PBRShaderGUI"
}
