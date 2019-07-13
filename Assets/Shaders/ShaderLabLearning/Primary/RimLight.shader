Shader "Learning/Primary/RimLight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "grey" {}

		[Header(Rim Light)]
		_RimColor("Rim Color", Color) = (0.17,0.36,0.81,0.0)
		_RimPower("Rim Power", Range(0.2,8.0)) = 2.0
		_RimIntensity("Rim Intensity", Range(0.0,10.0)) = 1.0
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

			fixed4 _RimColor;
			float _RimPower;
			float _RimIntensity;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 vertexWorld: TEXCOORD1;
				float3 normalDir: TEXCOORD2;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.vertexWorld.xyz);
				fixed3 normalDirection = normalize(i.normalDir);
				fixed NdotV = dot(viewDirection, normalDirection);
				fixed rim = 1.0 - saturate(NdotV);
				fixed3 rimLight = _RimColor.rgb * pow(rim, _RimPower) * _RimIntensity;
				col.rgb += rimLight;

				return col;
			}
			ENDCG
		}
	}
}
