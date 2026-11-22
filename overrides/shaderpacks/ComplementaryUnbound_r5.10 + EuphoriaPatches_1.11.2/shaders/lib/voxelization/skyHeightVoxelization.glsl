const ivec2 skyHeight_volumeSize = ivec2(256);
const float skyHeight_yOffset = 2049.0; // World y -2048 becomes 1, so 0 means no block in the column.

vec2 SceneToSkyHeightColumn(vec3 scenePos) {
    return scenePos.xz + fract(cameraPosition.xz) + 0.5 * vec2(skyHeight_volumeSize);
}

bool CheckInsideSkyHeightVolume(vec2 column) {
    return clamp(column, vec2(0.0), vec2(skyHeight_volumeSize)) == column;
}

// The stored height of the block at this world y, to compare with the column's height
uint GetSkyHeightOfBlock(float worldY) {
    return uint(max(floor(worldY) + skyHeight_yOffset, 1.0));
}

// A column stores the height of its highest block in the upper bits and the material of that block in the lower 15. Height first for atomic max
uint PackSkyHeight(uint height, int mat) {
    return (height << 15u) | (uint(mat) & 32767u);
}

uint GetSkyHeightFromData(uint data) {
    return data >> 15u;
}

int GetSkyMatFromData(uint data) {
    return int(data & 32767u);
}

#if defined SHADOW && defined VERTEX_SHADER
    void UpdateSkyHeightMap(int mat, vec3 normal) {
        if (mat == 32000 // Water
            || mat < 10000 // Block entities or unknown blocks that we treat as non-solid
            || uint(mat - 10007) <= 5u // Leaves from 10007 to 10012
        ) return;

        if (mat < 30000) {
            // Same per-block handling as the reflection voxel map, so half blocks, carpets and snow layers block the sky like they do there
            vec3 voxelPos = vec3(0.0);
            bool doSolidBlockCheck = true;
            bool storeToAllFaces = false;
            bool storeToAllFacesExceptTop = false;
            vec2 textureRad = abs(texCoord - mc_midTexCoord.xy);
            vec2 origin = mc_midTexCoord.xy - textureRad;

            #include "/lib/voxelization/voxelHandling.glsl"

            if (doSolidBlockCheck && mat % 2 == 1) return; // Non-solid terrain
        }

        vec3 modelPos = gl_Vertex.xyz + at_midBlock.xyz / 64.0;
        vec3 viewPos = mat3(gl_ModelViewMatrix) * modelPos + gl_ModelViewMatrix[3].xyz;
        vec3 scenePos = mat3(shadowModelViewInverse) * viewPos + shadowModelViewInverse[3].xyz;
        vec2 column = SceneToSkyHeightColumn(scenePos);

        if (CheckInsideSkyHeightVolume(column)) {
            imageAtomicMax(skyheight_img, ivec2(column), PackSkyHeight(GetSkyHeightOfBlock(scenePos.y + cameraPosition.y), mat));
        }
    }
#endif
