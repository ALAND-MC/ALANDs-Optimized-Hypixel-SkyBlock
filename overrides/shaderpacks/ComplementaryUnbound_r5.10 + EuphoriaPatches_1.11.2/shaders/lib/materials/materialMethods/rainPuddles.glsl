float GetPuddleLightFactor(vec2 lmCoordP) {
    return max0(lmCoordP.y * 32.0 - 31.0) * clamp((1.0 - 1.15 * lmCoordP.x) * 10.0, 0.0, 1.0);
}

vec2 GetPuddlePos(vec2 worldPosXZ) {
    #if WATER_STYLE == 1
        worldPosXZ = floor(worldPosXZ * 16.0) * 0.0625;
    #endif
    return worldPosXZ * 0.1;
}

vec3 GetPuddleNormal(vec2 puddlePos) {
    vec2 puddleWind = vec2(frameTimeCounter) * 0.03;
    vec2 pNormalCoord1 = puddlePos + vec2(puddleWind.x, puddleWind.y);
    vec2 pNormalCoord2 = puddlePos + vec2(puddleWind.x * -1.5, puddleWind.y * -1.0);
    vec3 pNormalNoise1 = texture2DLod(noisetex, pNormalCoord1, 0.0).rgb;
    vec3 pNormalNoise2 = texture2DLod(noisetex, pNormalCoord2, 0.0).rgb;
    float pNormalMult = 0.03;

    vec3 puddleNormal = vec3((pNormalNoise1.xy + pNormalNoise2.xy - vec2(1.0)) * pNormalMult, 1.0);
    puddleNormal = clamp(normalize(puddleNormal * tbnMatrix), vec3(-1.0), vec3(1.0));
    return normalize(mix(normal, puddleNormal, rainFactor));
}

void ApplyPuddleSpecular(inout float smoothnessG, inout float smoothnessD, inout float highlightMult, float puddleMixer, int subsurfaceModeP) {
    float puddleSmoothnessG = 0.7 - rainFactor * 0.3;
    float puddleHighlight = (1.5 - subsurfaceModeP * 0.6 * invNoonFactor);
    smoothnessG = mix(smoothnessG, puddleSmoothnessG, puddleMixer);
    highlightMult = mix(highlightMult, puddleHighlight, puddleMixer);
    smoothnessD = mix(smoothnessD, 1.0, sqrt1(puddleMixer));
}

float GetPuddleFormNoise(vec2 puddlePos, float wetnessM) {
    vec2 puddlePosForm = puddlePos * 0.05;
    float pFormNoise  = texture2DLod(noisetex, puddlePosForm, 0.0).b        * 3.0;
          pFormNoise += texture2DLod(noisetex, puddlePosForm * 0.5, 0.0).b  * 5.0;
          pFormNoise += texture2DLod(noisetex, puddlePosForm * 0.25, 0.0).b * 8.0;
          pFormNoise *= sqrt1(wetnessM) * 0.5625 + 0.4375;
    return clamp(pFormNoise - 7.0, 0.0, 1.0);
}
