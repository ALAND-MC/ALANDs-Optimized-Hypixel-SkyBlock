vec3 GetSmoothLightVolume(vec3 voxelPos) {
    vec3 texPos = voxelPos - 0.5;
    vec3 cell = floor(texPos);
    vec3 pos = clamp01((cell + smoothstep(0.0, 1.0, texPos - cell) + 0.5) / vec3(voxelVolumeSize));
    const float lightCurve = 0.75;
    if (int(framemod2) == 0) return pow(texture(floodfill_sampler_copy, pos).rgb, vec3(lightCurve));
    return pow(texture(floodfill_sampler, pos).rgb, vec3(lightCurve));
}

// Averages four reads spread across the surface to make it reach further
vec3 GetSpreadLightVolume(vec3 voxelPos, vec3 tangent, vec3 bitangent) {
    return 0.25 * (GetSmoothLightVolume(voxelPos + tangent) + GetSmoothLightVolume(voxelPos - tangent)
                 + GetSmoothLightVolume(voxelPos + bitangent) + GetSmoothLightVolume(voxelPos - bitangent));
}

vec3 GetBlocklightSSS(vec3 playerPos, vec3 worldGeoNormal, vec3 albedo, float amount) {
    vec3 normalToCamera = dot(worldGeoNormal, playerPos) > 0.0 ? -worldGeoNormal : worldGeoNormal;
    vec3 voxelPos = SceneToVoxel(playerPos);
    vec3 frontPos = voxelPos + normalToCamera * 0.55;
    vec3 backPos = voxelPos - normalToCamera * 0.55;
    if (!CheckInsideVoxelVolume(frontPos) || !CheckInsideVoxelVolume(backPos)) return vec3(0.0);

    const float spread = 0.5; // to configure how much it spreads in a face
    vec3 tangent, bitangent;
    GetOrthonormalBasis(normalToCamera, tangent, bitangent);
    tangent *= spread;
    bitangent *= spread;

    vec3 front = GetSpreadLightVolume(frontPos, tangent, bitangent);
    vec3 back = GetSpreadLightVolume(backPos, tangent, bitangent);

    vec3 transmitted = max0(back - front) + front * 0.3;
    float intensity = GetLuminance(transmitted);
    float boost = mix(2.2, 1.3, min1(intensity));
    intensity *= sqrt(min1(intensity)); // Make it not reach that far
    vec3 lightHue = mix(vec3(1.0), DoLuminanceCorrection(transmitted), 0.55); // Tint the SSS
    vec3 tint = normalize(albedo + 0.00001) * 1.2;

    vec3 sss = intensity * lightHue * tint * (amount * boost);
    const float peakSoftness = 1.2;
    float sssLum = GetLuminance(sss);
    sss *= log(1.0 + peakSoftness * sssLum) / (peakSoftness * sssLum + 0.0001);

    return sss;
}
