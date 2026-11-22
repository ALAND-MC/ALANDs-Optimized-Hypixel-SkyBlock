#if defined SKY_HEIGHT_INTERNAL && defined GBUFFERS_TERRAIN
    #define SKYLIGHT_SSS_ACT
#endif

#ifdef SKYLIGHT_SSS_ACT
    float GetSkyCover(ivec2 column, uint blockHeight, int blockMat, float sameLevelCover) {
        uint data = texelFetch(skyheight_sampler, column, 0).r;
        uint top = GetSkyHeightFromData(data);
        // Fixes sss leaks, different material at the same height means there is a wall, so we can extend the cover
        if (top == blockHeight && blockMat > 0 && GetSkyMatFromData(data) != blockMat) return sameLevelCover;
        if (top <= blockHeight) return 0.0;

        return 1.0 - smoothstep(32.0, 96.0, float(top - blockHeight));
    }
#endif

#ifdef SKYLIGHT_SSS_ACT
float isACTSkylight(vec3 playerPos, vec3 worldGeoNormal) {
        float open = 0.0;
        vec3 inside = (playerPos - vec3(0, 0.1, 0)) - worldGeoNormal * 0.25; //-0.1 for trapdoors
        vec2 columnPos = SceneToSkyHeightColumn(inside);
        if (CheckInsideSkyHeightVolume(columnPos)) {
            ivec2 column = ivec2(columnPos);
            uint height = GetSkyHeightOfBlock(inside.y + cameraPosition.y);

            vec2 edge = fract(columnPos) - 0.5;
            ivec2 edgeStep = ivec2(edge.x < 0.0 ? -1 : 1, edge.y < 0.0 ? -1 : 1);
            vec2 blend = smoothstep(0.25, 0.5, abs(edge)) * 0.5;
            if (maxOf(abs(worldGeoNormal)) < 0.99) blend = vec2(0.0); // Not axis aligned, do not blend

            ivec3 cell = ivec3(SceneToVoxel(inside));
            ivec3 front = ivec3(round(worldGeoNormal));

            float coverCentre = GetSkyCover(column, height, 0, 0.0);
            float coverNeighbourX = coverCentre;
            float coverNeighbourZ = coverCentre;
            float coverDiagonal = coverCentre;
            if (blend.x > 0.0 && GetVoxelVolume(cell + ivec3(edgeStep.x, 0, 0) + front) == 0u) {
                coverNeighbourX = GetSkyCover(column + ivec2(edgeStep.x, 0), height, mat, coverCentre);
            }
            if (blend.y > 0.0 && GetVoxelVolume(cell + ivec3(0, 0, edgeStep.y) + front) == 0u) {
                coverNeighbourZ = GetSkyCover(column + ivec2(0, edgeStep.y), height, mat, coverCentre);
            }
            if (blend.x > 0.0 && blend.y > 0.0 && GetVoxelVolume(cell + ivec3(edgeStep.x, 0, edgeStep.y) + front) == 0u) {
                coverDiagonal = GetSkyCover(column + edgeStep, height, mat, coverCentre);
            }
            float cover = mix(mix(coverCentre, coverNeighbourX, blend.x), mix(coverNeighbourZ, coverDiagonal, blend.x), blend.y);
            open = 1.0 - cover;

            vec2 toMapEdge = min(columnPos, vec2(skyHeight_volumeSize) - columnPos);
            open *= smoothstep(0.0, 8.0, min(toMapEdge.x, toMapEdge.y));
        }
        return open;
}
#endif

vec3 GetSkylightSSS(vec3 playerPos, vec3 worldGeoNormal, vec3 nViewPos, vec3 albedo, float lightmapY, float amount, float lightning) {
    float back = 0.5 - 0.25 * NdotU;
    float view = pow2(dot(nViewPos, upVec) * 0.5 + 0.5);
    float phase = 2.0 - pow2(1.0 - view); // Brighter when looking up through the material
    vec3 tint = normalize(albedo + 0.00001) * 1.2;

    float exposure = pow4(pow2(lightmapY)) * (0.25 + 0.75 * invRainFactor);
    exposure *= 1.0 - 0.75 * smoothstep(0.85, 1.0, lightmapY); // Reduce skylight sss at fully open air blocks

    float lightningExposure = lightning * pow4(pow2(lightmapY));

    #ifdef SKYLIGHT_SSS_ACT
        float actMax = 0.08 * (0.25 + 0.75 * invRainFactor);
        float actLightningMax = lightning * 0.3;
        if (exposure < actMax || lightningExposure < actLightningMax) {
            float actSkylight = isACTSkylight(playerPos, worldGeoNormal);
            exposure = max(exposure, actMax * actSkylight);
            lightningExposure = max(lightningExposure, actLightningMax * actSkylight);
        }
    #endif

    exposure *= 0.6 + 1.4 * (1.0 - eyeBrightnessM); // Weaker when the player is outside, stronger indoors
    exposure *= 0.2 + 0.8 * sunVisibility; // Night sky is much dimmer
    exposure = max(exposure, lightningExposure);

    return exposure * tint * (amount * back * phase);
}
