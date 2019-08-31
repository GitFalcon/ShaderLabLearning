Shader "Learning/Advance/Shadow_Volume_Rotate"
{
	Properties
	{
		_Color("Shadow Color", color) = (0, 0, 0, 1)
		_LightDirection("Light Direction(XYZ), Floor(W)", Vector) = (6, 27, 14, 0)
		_Weakness("Weakness", Range(0.1, 100)) = 0.5
		_Angle("Angle", Range(0, 90)) = 0
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
			float _Angle;

			inline float4 quatMul(float4 q, float4 p)
			{
				float3 qv = q.xyz;
				float3 pv = p.xyz;
				return float4(cross(qv, pv) + qv * p.w + q.w * pv, q.w * p.w - dot(qv, pv));
			}

			inline float4 quatRot(float4 r, float4 p)
			{
				float4 c = float4(-r.xyz, r.w);
				return quatMul(quatMul(r, p),c);
			}

			inline float3 Rot(float3 axis, float rad, float3 vec)
			{
				rad *= 0.5;
				float4 r = float4(axis * sin(rad), cos(rad));
				float4 p = float4(vec, 0);
				return quatRot(r, p);
			}

			inline float3 RotVertexWorld(float3 v, float3 rad)
			{
				float3 offset = unity_ObjectToWorld._14_24_34;
				offset.y = _LightDirection.w;
				v -= offset;
				float3 axis = normalize(cross(float3(0, _LightDirection.y, 0), _LightDirection.xyz));
				v = Rot(axis, -rad, v);
				v += offset;
				return v;
			}
			
			v2f vert(appdata v)
			{
	            v2f o = (v2f) 0;
				float4 vertex = mul(unity_ObjectToWorld, v.vertex);
				float3 lightDir = _LightDirection.xyz;

				float k = max(0, ((vertex.y - _LightDirection.w) / lightDir.y));
				o.distance.xyz = lightDir * k;
				o.distance.w = sign(k) * _Weakness / (length(o.distance.xyz) + _Weakness);
				vertex.xyz -= o.distance.xyz;
				vertex.xyz = RotVertexWorld(vertex.xyz, radians(_Angle));
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
