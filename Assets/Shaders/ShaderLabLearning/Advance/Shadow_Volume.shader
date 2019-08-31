Shader "Learning/Advance/Shadow_Volume"
{
	Properties
	{
		_Color("Shadow Color", color) = (0, 0, 0, 1)
		_LightDirection("Light Direction(XYZ), Floor(W)", Vector) = (6, 27, 14, 0)
		_Weakness("Weakness", Range(0.1, 100)) = 0.5
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CULL Back
			
			CGPROGRAM
			
			#pragma vertex vert
        	#pragma fragment frag
        	#include "UnityCG.cginc"

        	struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 distance : TEXCOORD1;
			};

			fixed4 _Color;
			float4 _LightDirection;
			float _Weakness;
			
			v2f vert(appdata v)
			{
	            v2f o = (v2f) 0;
				float4 vertex = mul(unity_ObjectToWorld, v.vertex);
				float3 lightDir = _LightDirection.xyz;

				float k = max(0, ((vertex.y - _LightDirection.w) / lightDir.y));
				o.distance.xyz = lightDir * k;
				o.distance.w = sign(k) * _Weakness / (length(o.distance.xyz) + _Weakness);
				vertex.xyz -= o.distance.xyz;
				o.vertex = UnityObjectToClipPos(mul(unity_WorldToObject, vertex));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				_Color.a *= i.distance.w;
				return _Color;
			}
			ENDCG
		}
	}
}
