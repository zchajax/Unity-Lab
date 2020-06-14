Shader "Custom/PBR"
{
    Properties
    {
        _Albedo("Albedo", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Roughness("Roughness", Range(0.0001, 1)) = 0.5
        _Shininess("Shininess", Range(1, 600)) = 50
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
            #pragma shader_feature __ _PHONG _BLINN_PHONG _GGX _BECKMAN

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
            float  _Shininess;

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

            #if _DIFFUSE_OREN_NAYER
                float3 orenNayer(float3 albedo, float sigma, float nl, float nv, float lv)
                {
                    float sigma_2 = pow(sigma, 2);
				    float A = 1 - 0.5 * sigma_2 / (sigma_2 + 0.33) + 0.17 * albedo * sigma_2 / (sigma_2 + 0.13);
				    float B = 0.45 * sigma_2 / (sigma_2 + 0.09);
				    float s = lv - nl * nv;
				    float t = s <= 0 ? 1 : max(nl, nv);
                    return albedo / PI * (A + B * s / t);
                }
            #endif

            #if _PHONG
                float3 phong(float vr)
                {
                    return pow(vr, _Shininess);
                }
            #endif

            #if _BLINN_PHONG
                float3 blinnPhong(float nh)
                {
                    return pow(nh, _Shininess);
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
                float lv = saturate(dot(lightDir, viewDir));

                float3 diffuseTerm = 0;

                #if _DIFFUSE_LAMBERT
                    diffuseTerm = lambert(albedo);
                #endif

                #if _DIFFUSE_DISNEY
                    diffuseTerm = disney(albedo, roughness, hl, nl, nv); 
                #endif

                #if _DIFFUSE_OREN_NAYER
                    float sigma = pow(roughness, 2) * PI / 2;
                    diffuseTerm = orenNayer(albedo, sigma, nl, nv, lv);
                #endif

                float3 specularTerm = 0;

                #if _PHONG
                    float3 reflectDir = normalize(reflect(-lightDir, normal));
                    float vr = max(0, dot(viewDir, reflectDir));
                    specularTerm = phong(vr);
                #endif

                #if _BLINN_PHONG
                    specularTerm = blinnPhong(nh);
                #endif
                
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
