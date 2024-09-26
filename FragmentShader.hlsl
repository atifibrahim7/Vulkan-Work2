struct PSInput
{
    float4 position : SV_POSITION;
    float3 worldPos : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float4 tangent : TANGENT;
};

struct SHADER_VARS
{
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4 sunDirection;
    float4 sunColor;
    float4 cameraPosition;
};

cbuffer UboView : register(b0, space0)
{
    SHADER_VARS ubo;
}


Texture2D textures[] : register(t0, space1); // Assuming [0] is base color, [1] is roughness map
SamplerState samplers[] : register(s0, space1);

static float4 specular = float4(1, 1, 1, 1);
static float4 ambient = float4(0.1f, 0.1f, 0.1f, 1);
static float4 emissive = float4(0, 0, 0, 1);
static float Ns = 100;

float4 main(PSInput input) : SV_TARGET
{
    float3 N = normalize(input.normal);
    float3 L = normalize(-ubo.sunDirection.xyz);
    float3 V = normalize(ubo.cameraPosition.xyz - input.worldPos);
    float3 H = normalize(L + V);

    float4 diffuse = textures[0].Sample(samplers[0], input.uv);

    float roughness = textures[1].Sample(samplers[0], input.uv).r;

    float4 finalColor = ambient + emissive;
    float NdotL = max(dot(N, L), 0);
    finalColor += diffuse * ubo.sunColor * NdotL;

    float NdotH = max(dot(N, H), 0);
    float specularTerm = pow(NdotH, Ns * (1.0f - roughness));
    finalColor += specular * ubo.sunColor * specularTerm;

    return finalColor;
}
    