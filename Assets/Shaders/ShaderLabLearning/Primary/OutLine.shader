Shader "Learning/Primary/OutLine"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "grey" {}

		[Header(Out Line)]
		_OutLineColor("OutLine Color", Color) = (0, 0.4, 1.0, 1) 
		_OutLineSize("OutLine Size", Range(0,0.1)) = 0.05
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
			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _OutLineColor;
			fixed _OutLineSize;

			struct appdata {
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f {
				float4 vertex: SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _OutLineSize;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return _OutLineColor;
			}
			ENDCG
		}
	}
}
