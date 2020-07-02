
float4x4 mWorldViewProj : WORLDVIEWPROJECTION;

Texture tex0;

sampler2D tex0Sampler :register(s0) = sampler_state{
	texture = <tex0>;
	mipfilter = linear;
	minfilter = linear;
	magfilter = linear;
	AddressU = clamp;
	AddressV = clamp;
};

void vs_main(
    inout float4 Pos  : POSITION,
    inout float2 texCoord:TEXCOORD0
)
{
    Pos = mul(Pos, mWorldViewProj);
    texCoord = texCoord;
}

void ps_main(out float4 color : COLOR0,
	in float2 texCoord:TEXCOORD0
)
{
	color.xyz = tex2D(tex0Sampler,texCoord);
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
