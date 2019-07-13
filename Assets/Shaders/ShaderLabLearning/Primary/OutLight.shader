Shader "Learning/Primary/OutLight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "grey" {}

		[Header(Out Light)]
		_OutLightColor("OutLight Color", Color) = (0, 0.4, 1.0, 1) 
		_OutLightSize("OutLight Size", Range(0,0.5)) = 0.1
		_OutLightPower("OutLight Power",Range(0.2,8.0)) = 5
		_OutLightIntensity("OutLight Intensity", Range(0.0,10.0)) = 10
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"	

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

		Pass{
			Tags {"LightMode" = "Always"  "Queue" = "Transparent" "RenderType" = "Transparent" }
			Cull Front
			Blend SrcAlpha One

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _OutLightColor;
			fixed _OutLightSize;
			float _OutLightPower;
			float _OutLightIntensity;

			struct appdata {
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float2 texcoord0: TEXCOORD0;
			};

			struct v2f {
				float4 vertex: SV_POSITION;
				float4 vertexWorld: TEXCOORD1;
				float3 normalDir: TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _OutLightSize;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normalDir = v.normal;
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 normalDirection = normalize(i.normalDir);
				float3 viewDirection = normalize(i.vertexWorld.xyz - _WorldSpaceCameraPos.xyz);
				float NdotV = dot(viewDirection, normalDirection);
				float4 col = _OutLightColor;
				col.a = saturate(_OutLightIntensity * pow(saturate(NdotV), _OutLightPower));
				return col;
			}
			ENDCG
		}
	}
}
