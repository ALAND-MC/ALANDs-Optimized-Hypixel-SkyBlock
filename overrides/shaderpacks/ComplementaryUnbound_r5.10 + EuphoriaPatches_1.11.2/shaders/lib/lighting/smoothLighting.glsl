float smoothLightmapSteepFactor = 2.8 - 0.6 * vsBrightness + XLIGHT_CURVE;
float smoothLightmapCalmFactor = 2.8 + 0.6 * vsBrightness - XLIGHT_CURVE;

#if defined LIGHTMAP_CURVES && !defined GBUFFERS_TEXTURED && !defined GBUFFERS_HAND
    float smoothLightmapTransitionFactor = ((UPPER_LIGHTMAP_CURVE * 0.1 + 0.9) - 1.0) *
                                           mix(1.0, 10.0, float(int(max(0.0, UPPER_LIGHTMAP_CURVE - 0.01))));

    float smoothLightmapTransition16 = (10.0 - vsBrightness) * 2.0 * smoothLightmapTransitionFactor;
    float smoothLightmapTransition8 = (2.8 + XLIGHT_CURVE - vsBrightness) * 0.8 * smoothLightmapTransitionFactor;
    float smoothLightmapTransition4 = (2.8 + XLIGHT_CURVE - vsBrightness * 0.7) * smoothLightmapTransitionFactor;
    float smoothLightmapCalmFactorCurved = smoothLightmapCalmFactor * LOWER_LIGHTMAP_CURVE;
#endif

float GetTweakedSmoothLightmap(float light) {
    float lx4 = pow2(pow2(light));
    float lx8 = pow2(lx4);

    #if defined LIGHTMAP_CURVES && !defined GBUFFERS_TEXTURED && !defined GBUFFERS_HAND
        float lx16 = pow2(lx8);

        float lightmapSteep = max(0.0, lx8 * smoothLightmapSteepFactor +
                                       lx16 * smoothLightmapTransition16 +
                                       lx8 * smoothLightmapTransition8 +
                                       lx4 * smoothLightmapTransition4);
        float lightmapCalm = light * smoothLightmapCalmFactorCurved;
    #else
        float lightmapSteep = lx8 * smoothLightmapSteepFactor;
        float lightmapCalm = light * smoothLightmapCalmFactor;
    #endif

    return pow(lightmapSteep + lightmapCalm, 2.25);
}
