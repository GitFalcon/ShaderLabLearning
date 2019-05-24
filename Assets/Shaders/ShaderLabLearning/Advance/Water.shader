Shader "Learning/Advance/Water"
{
    Properties
    {
        _WaveTex ("Wave Texture", 2D) = "white" {}
        _WaterColor("Water Color",Color)=(0.65,1,1,1)
        _FarColor("Far Water Color",Color)=(.2,.43,1,.4)
        _BumpTex("Bump Texture",2D) = "white" {}
        _BumpPower("Bump Power",Range(-1,1))=.6
        _EdgeTex("Edge Texture",2D) = "white" {}
        _EdgeRange("Edge Range",Range(0.1,10))=1.4
        _EdgeColor("Edge Color",Color)=(.74,1,1,0)
        _WaveSize("Wave Size",Range(0.01,1))=.02
        _WaveOffset("Wave Offset",vector)=(.1,.21,-.2,-.1)
        _WaveSpeed("Wave Speed",Range(0,10))=1.4
        _LightColor("Light Color",Color)=(.53,1,1,.32)
        _LightVector("Light Vector",vector)=(.5,.5,.5,30)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

			      sampler2D _WaveTex;
			      float4 _WaveTex_ST;
			      fixed4 _WaterColor;
			      fixed4 _FarColor;
			      sampler2D _BumpTex;
			      float4 _BumpTex_ST;
			      float _BumpPower;
			      sampler2D _EdgeTex;
			      float4 _EdgeTex_ST;
			      float _EdgeRange;
			      fixed4 _EdgeColor;
			      float _WaveSize;
			      float4 _WaveOffset;
			      float _WaveSpeed;
			      fixed4 _LightColor;
			      float4 _LightVector;
			      sampler2D _CameraDepthTexture;

			      struct appdata
			      {
			      	float4 vertex : POSITION;
			      	float3 normal : NORMAL;
			      };

			      struct v2f
			      {
			      	float4 vertex : SV_POSITION;
			      	half3 normal: TEXCOORD0;
			      	float4 screenPos: TEXCOORD1;
			      	fixed3 viewDir:TEXCOORD2;
			      	fixed2 uv[2]:TEXCOORD3;
			      };

			      v2f vert (appdata v)
			      {
			      	v2f o;
      
			      	o.vertex = UnityObjectToClipPos(v.vertex);
      
			      	float4 wPos=mul(unity_ObjectToWorld,v.vertex);
			      	o.uv[0]=wPos.xz*_WaveSize+_WaveOffset.xy*_Time.y*.4;
			      	o.uv[1]=wPos.xz*_WaveSize+_WaveOffset.zw*_Time.y*.4;
      
			      	o.normal=UnityObjectToWorldNormal(v.normal);
			      	o.viewDir=WorldSpaceViewDir(v.vertex);
      
			      	//用于深度采集
			      	o.screenPos=ComputeScreenPos(o.vertex);
			      	COMPUTE_EYEDEPTH(o.screenPos.z);
      
			      	return o;
			      }

            fixed4 frag (v2f i) : SV_Target
            {
              fixed4 col = _WaterColor;
          
              half3 nor=UnpackNormal((tex2D(_BumpTex,i.uv[0])+tex2D(_BumpTex,i.uv[1]))*.5);
              nor=normalize(i.normal+nor.xzy*half3(1,0,1)*_BumpPower);
      
              //高光 Bline-Phong模型
              half spec=max(0,dot(nor,normalize(normalize(_LightVector.xyz)+normalize(i.viewDir))));
              spec=pow(spec,_LightVector.w);
        
              half fresnel=dot(nor,normalize(i.viewDir));
              fresnel=saturate(dot(nor*fresnel,normalize(i.viewDir)));
      
              //计算深度
              half depth=SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.screenPos));
              depth=LinearEyeDepth(depth);     
              depth=saturate((depth-i.screenPos.z)*_EdgeRange);
          
              fixed4 edge=(tex2D(_EdgeTex,i.uv[0])+tex2D(_EdgeTex,i.uv[1]));
              edge.a=0;
              col=lerp(edge*_EdgeColor,col,depth);
          
              float time=_Time.x*_WaveSpeed;
              float wave=tex2D(_WaveTex,float2(time+depth,1)).a;
              col+=_EdgeColor*saturate(saturate(wave)-depth)*edge.a;
      
              col.rgb=lerp(col,_FarColor,_FarColor.a-fresnel)*0.95;
              col.rgb+=_LightColor.rgb*spec*_LightColor.a;
          
              //和天空盒边界融合
              col.a=lerp(col.a, 0.01f, saturate(i.screenPos.z / _ProjectionParams.b - 0.3f) * 1.43f);
          
              return col;
            }

            ENDCG
        }
    }
    FallBack OFF
}
