#if !defined AURORA_BOREALIS_GLSL
#define AURORA_BOREALIS_GLSL
#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#include "/lib/util/colorConversion.glsl"

#define AURORA_COLOR_PRESET 0 //[-1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14] // 0 is manual and default, 1 is daily, 2 is monthly and 3 is one color preset same with all numbers after

#define AURORA_UP_R 112 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_UP_G 36 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_UP_B 192 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_UP_I 33 //[0 3 5 8 10 13 15 18 20 23 25 28 30 33 35 38 40 43 45 48 50 53 55 58 60 63 65 68 70 73 75 78 80 83 85 88 90 93 95 98 100]

#define AURORA_DOWN_R 96 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_DOWN_G 255 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_DOWN_B 192 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_DOWN_I 33 //[0 3 5 8 10 13 15 18 20 23 25 28 30 33 35 38 40 43 45 48 50 53 55 58 60 63 65 68 70 73 75 78 80 83 85 88 90 93 95 98 100]

#define AURORA_SIZE 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.05 2.10 2.15 2.20 2.25 2.30 2.35 2.40 2.45 2.50 2.55 2.60 2.65 2.70 2.75 2.80 2.85 2.90 2.95 3.00]

//#define RGB_AURORA

#define AURORA_CLOUD_INFLUENCE_INTENSITY 1.00 //[0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.50 3.00]
#define AURORA_TERRAIN_INFLUENCE_INTENSITY 1.00 //[0.00 0.25 0.50 0.75 1.00 1.25 1.50]

#define AURORA_NOISE_SCALE 1.00 //[0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.05 2.10 2.15 2.20 2.25 2.30 2.35 2.40 2.45 2.50 2.55 2.60 2.65 2.70 2.75 2.80 2.85 2.90 2.95 3.00 3.05 3.10 3.15 3.20 3.25 3.30 3.35 3.40 3.45 3.50 3.55 3.60 3.65 3.70 3.75 3.80 3.85 3.90 3.95 4.00 4.05 4.10 4.15 4.20 4.25 4.30 4.35 4.40 4.45 4.50 4.55 4.60 4.65 4.70 4.75 4.80 4.85 4.90 4.95 5.00]
#define AURORA_PATTERN_WARP 0 //[0 1 2 3 4 5 6 7 8 9 10]
#define AURORA_SATURATION 10 //[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define AURORA_COLOR_MIX_POWER 2.0 //[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0]

#include "/lib/atmospherics/auroraBorealisVisibility.glsl"

#define AURORA_PRESET_COUNT 13

// Preset colors in OKLab (up, down), index = AURORA_COLOR_PRESET - 2. A switch instead of an array because runtime-indexed arrays are slow on some GPUs
void getAuroraPreset(int i, out vec3 upLab, out vec3 downLab) {
    switch (i) {
        default:
        case 0: // Complementary (no fixed menu entry, only reached by the cycling modes)
            upLab = vec3(0.6497967, 0.1175833, -0.1405206); downLab = vec3(0.9349612, -0.0950451, 0.0149488); break;
        case 1: // menu 3: Legacy Complementary (v4)
            upLab = vec3(0.7429475, 0.0589431, -0.1345453); downLab = vec3(0.9270518, -0.1078380, 0.0205064); break;
        case 2: // menu 4: permafrost
            upLab = vec3(0.6623245, 0.1453414, -0.0242697); downLab = vec3(0.8364559, -0.0889930, 0.0009189); break;
        case 3: // menu 5: Blossoming Lights (Pink)
            upLab = vec3(0.7785600, 0.1450534, -0.0091299); downLab = vec3(0.7930697, 0.0759838, -0.1074156); break;
        case 4: // menu 6: Nebula
            upLab = vec3(0.7291135, -0.0004477, -0.0904140); downLab = vec3(0.6805046, 0.1319328, -0.0148986); break;
        case 5: // menu 7: Celestial Dance
            upLab = vec3(0.8984496, -0.1569938, 0.0407037); downLab = vec3(0.7279037, 0.0649723, -0.1434207); break;
        case 6: // menu 8: Green Flash
            upLab = vec3(0.9692288, 0.0224571, -0.0152707); downLab = vec3(0.9067356, -0.1471677, 0.1047061); break;
        case 7: // menu 9: Ethereal Lights
            upLab = vec3(0.9312894, -0.1032881, -0.0285845); downLab = vec3(0.6966908, 0.0768975, -0.0508778); break;
        case 8: // menu 10: Glacial Blessing
            upLab = vec3(0.4174097, -0.0423702, -0.1030738); downLab = vec3(0.4202158, -0.0591433, -0.0475605); break;
        case 9: // menu 11: Mythical Lights
            upLab = vec3(0.5892816, 0.2134036, -0.1889643); downLab = vec3(0.8329326, -0.0617447, -0.0799043); break;
        case 10: // menu 12: watermelon
            upLab = vec3(0.8803987, -0.0949160, 0.1111269); downLab = vec3(0.7527072, 0.0600452, 0.0403405); break;
        case 11: // menu 13: blood bath
            upLab = vec3(0.9053992, -0.1494439, -0.0393982); downLab = vec3(0.5591215, 0.2002145, 0.1120516); break;
        case 12: // menu 14: Ghost
            upLab = vec3(0.7928624, 0.1255772, 0.0103766); downLab = vec3(0.9270518, -0.1078380, 0.0205064); break;
    }
}

vec2 warpAuroraCoords(vec2 coord, float warpAmount) {
    float angle = texture2D(noisetex, coord * 0.5).r * 6.28318 * warpAmount;
    float strength = texture2D(noisetex, coord * 0.7 + 0.5).r * warpAmount;
    vec2 offset = vec2(cos(angle), sin(angle)) * strength;
    return coord + offset;
}

void GetAuroraColor(in vec2 wpos, out vec3 auroraUp, out vec3 auroraDown) {
    #ifdef RGB_AURORA
        auroraUp = getRainbowColor(wpos, 0.06);
        auroraDown = getRainbowColor(wpos, 0.05);
    #elif AURORA_COLOR_PRESET == 0
        auroraUp = vec3(AURORA_UP_R, AURORA_UP_G, AURORA_UP_B);
        auroraDown = vec3(AURORA_DOWN_R, AURORA_DOWN_G, AURORA_DOWN_B);
    #else
        #if AURORA_COLOR_PRESET == -1
            float randomValue = hash11(float(worldDay));
            randomValue = pow(randomValue, 0.7); // Bias towards higher values (more transitions)
            float transitionsPerNight = min(randomValue * 2.0, 1.75);
            float idx, frac = modf(nightFactor * transitionsPerNight, idx);

            int dayOffset = worldDay % AURORA_PRESET_COUNT;
            int i0 = (int(idx) + dayOffset) % AURORA_PRESET_COUNT;
            int i1 = (i0 + 1) % AURORA_PRESET_COUNT;

            // Interpolate in OKLab color space for perceptually uniform transitions
            vec3 upLab0, downLab0, upLab1, downLab1;
            getAuroraPreset(i0, upLab0, downLab0);
            getAuroraPreset(i1, upLab1, downLab1);
            auroraUp = oklab2rgb(mix(upLab0, upLab1, frac)) * 255.0;
            auroraDown = oklab2rgb(mix(downLab0, downLab1, frac)) * 255.0;
        #else
            #if AURORA_COLOR_PRESET == 1
                int p = worldDay % AURORA_PRESET_COUNT;
            #elif AURORA_COLOR_PRESET == 2
                int p = worldDay % (AURORA_PRESET_COUNT * 8) / 8;
            #else
                const int p = AURORA_COLOR_PRESET - 2;
            #endif

            vec3 upLab, downLab;
            getAuroraPreset(p, upLab, downLab);
            auroraUp = oklab2rgb(upLab) * 255.0;
            auroraDown = oklab2rgb(downLab) * 255.0;
        #endif
    #endif
    auroraUp = max(auroraUp, vec3(0.001));
    auroraDown = max(auroraDown, vec3(0.001));

    auroraUp *= (AURORA_UP_I * 0.093 + 3.1) / GetLuminance(auroraUp);
    auroraDown *= (AURORA_DOWN_I * 0.245 + 8.15) / GetLuminance(auroraDown);

    #if AURORA_SATURATION != 10
        auroraUp = rgb2hsv(auroraUp);
        auroraUp.g *= AURORA_SATURATION * 0.1;
        auroraUp = hsv2rgb(auroraUp);

        auroraDown = rgb2hsv(auroraDown);
        auroraDown.g *= AURORA_SATURATION * 0.1;
        auroraDown = hsv2rgb(auroraDown);
    #endif
}

vec3 getAuroraAmbientColor(vec3 color, vec3 viewPos, float multiplier, float influence, float VdotUAmount) {
    float visibility = GetAuroraVisibility(0.5, VdotUAmount);
    if (visibility > 0) {
        vec3 wpos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        wpos.xz /= (abs(wpos.y) + length(wpos.xz));

        vec3 auroraUp, auroraDown;
        GetAuroraColor(wpos.xz, auroraUp, auroraDown);

        vec3 auroraColor = mix(auroraUp, auroraDown, 0.8);
        #ifdef COMPOSITE1
            visibility *= influence;
            return mix(color, auroraColor, visibility);
        #endif
        auroraColor *= multiplier;
        visibility *= influence;
        #ifdef DEFERRED1
            return mix(color, saturateColors(auroraColor, 0.8) * visibility * 0.45, visibility);
        #endif
        float luminanceColor = GetLuminance(color);
        vec3 newColor = mix(color, mix(color, vec3(luminanceColor), 0.88), visibility);
        newColor *= mix(vec3(1.0), auroraColor * luminanceColor * 10.0, visibility);
        return clamp01(newColor);
        // return mix(color, color * auroraColor, visibility); // old, keep it for now
    }
    return color;
}

vec3 GetAuroraBorealis(vec3 viewPos, float VdotU, float dither) {
    float visibility = GetAuroraVisibility(VdotU, 1.0);

    if (visibility > 0.0) {
        vec3 aurora = vec3(0.0);

        vec3 wpos = mat3(gbufferModelViewInverse) * viewPos;
             wpos.xz /= wpos.y;
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
             cameraPositionM.x += syncedTimeDynamic * 0.04;

        #ifdef DEFERRED1
            int sampleCount = 25;
            int sampleCountP = sampleCount + 5;
        #else
            int sampleCount = 10;
            int sampleCountP = sampleCount + 10;
        #endif

        float ditherM = dither + 5.0;
        float auroraAnimate = frameTimeCounter * 0.001;

        vec3 auroraUp, auroraDown;
        GetAuroraColor(wpos.xz, auroraUp, auroraDown);

        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);

            vec2 planePos = wpos.xz * (AURORA_SIZE * 0.8 + current) * 11.0 * AURORA_NOISE_SCALE + cameraPositionM;

            #if AURORA_STYLE == 1
                planePos = floor(planePos) * 0.0007;

                #if AURORA_PATTERN_WARP > 0
                    planePos = warpAuroraCoords(planePos, AURORA_PATTERN_WARP * 0.0057);
                #endif

                float noise = texture2DLod(noisetex, planePos, 0.0).b;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));

                noise *= pow1_5(texture2DLod(noisetex, planePos * 100.0 + auroraAnimate, 0.0).b);
            #else
                planePos *= 0.0007;

                #if AURORA_PATTERN_WARP > 0
                    planePos = warpAuroraCoords(planePos, AURORA_PATTERN_WARP * 0.0082);
                #endif

                float noise = texture2DLod(noisetex, planePos, 0.0).r;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));

                noise *= texture2DLod(noisetex, planePos * 3.0 + auroraAnimate, 0.0).b;
                noise *= texture2DLod(noisetex, planePos * 5.0 - auroraAnimate, 0.0).b;
            #endif

            float currentM = 1.0 - current;

            aurora += noise * currentM * mix(auroraUp, auroraDown, pow(pow2(currentM), AURORA_COLOR_MIX_POWER));
        }

        #if AURORA_STYLE == 1
            aurora *= 1.3;
        #else
            aurora *= 1.8;
        #endif

        #ifdef ATM_COLOR_MULTS
            aurora *= sqrtAtmColorMult; // C72380KD - Reduced atmColorMult impact on some things
        #endif

        return aurora * visibility / sampleCount;
    }

    return vec3(0.0);
}
#endif
