
float4x4 mWorldViewProj : WorldViewProjection;
//Textures
//background texture
Texture tex0;
//road texture
Texture tex1;

sampler2D tex0Sampler :register(s0) = sampler_state{
	texture = <tex0>;
	mipfilter = linear;
	minfilter = linear;
	magfilter = linear;
	AddressU = clamp;
	AddressV = clamp;
};

sampler2D tex1Sampler  :register(s1)= sampler_state{
	texture = <tex1>;
	mipfilter = linear;
	minfilter = linear;
	magfilter = linear;
	AddressU = mirror;
	AddressV = mirror;
};


void vs_main(
    inout float4 Pos  : POSITION,
    inout float2 texCoord:TEXCOORD0,
    in float3 normal :NORMAL)
{
    Pos = mul(Pos, mWorldViewProj);
    texCoord = texCoord;
}

void ps_main(out float4 color : COLOR0,
	in float2 texCoord:TEXCOORD0)
{
	float3 bgColor = tex2D(tex0Sampler,texCoord);
	float4 roadColor = tex2D(tex1Sampler,texCoord);
	color.xyz = lerp(bgColor,roadColor.xyz,roadColor.w);
	color.xyz *= 0.9;
	color.w = 1;
}

technique SimpleMesh_vs30_ps30
{
    pass P0
    {
		FogEnable = false;
        vertexShader = compile vs_2_0 vs_main();
        pixelShader = compile ps_2_0 ps_main();
    }
}
