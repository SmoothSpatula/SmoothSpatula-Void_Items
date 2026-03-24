//###### Frag Shader
Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

cbuffer gm_PSMaterialConstantBuffer
{
    bool   gm_PS_FogEnabled;
    float4 gm_FogColour;
    bool   gm_AlphaTestEnabled;
    float4 gm_AlphaRefValue;
};

struct Fragment
{
    float4 vPosition : SV_POSITION;
    float4 vColor    : COLOR0;
    float2 vCoord    : TEXCOORD0;
};

#define MAX_BULGES 10
uniform float4 bulgeUVs[MAX_BULGES];
uniform int numBulges;
// uniform float ShaderStrength;
// uniform float OutlineThreshold;
// uniform float OutlineSmoothness;
// uniform float OutlineStrength;
// uniform float3 ShaderAccent;

float2 coord_warp(float2 uv, float2 resolution, float4 bulgeUVs[MAX_BULGES], out float mask){
    float2 pixel = uv * resolution;
    float radius = 200.0f;

    for (int i = 0; i< numBulges; i++){
        float2 offset = pixel - bulgeUVs[i].xy; // use .xy
        float dist = length(offset);
        float localMask = saturate((radius - dist) / radius);
        mask = max(mask, localMask);
        pixel += offset * localMask * ( - bulgeUVs[i].z / 15);
    }
    return pixel / resolution;
}


float4 main(Fragment INPUT) : SV_Target0 {
    float2 textureDimensions;
    gm_BaseTextureObject.GetDimensions(textureDimensions.x, textureDimensions.y);

    float mask;
    float2 warpedUV = coord_warp(INPUT.vCoord, textureDimensions, bulgeUVs, mask);
    float4 baseColor = gm_BaseTextureObject.Sample(gm_BaseTexture, warpedUV);
    //float3 purple = float3(0.6f, 0.2f, 0.8f);
    //baseColor.rgb = lerp(baseColor.rgb, purple, mask * 0.4f);

    

    return baseColor;
}
