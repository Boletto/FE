//
//  Filters.metal
//  FilterApp
//
//  Created by Sunho on 3/30/25.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h>


float sobelEdge(texture2d<float, access::read> inTexture, uint2 gid) {
    float3x3 sobelX = float3x3(
                               -1.0, 0.0, 1.0,
                               -2.0, 0.0, 2.0,
                               -1.0, 0.0, 1.0
                               );
    float3x3 sobelY = float3x3(
                               -1.0, -2.0, -1.0,
                               0.0,  0.0,  0.0,
                               1.0,  2.0,  1.0
                               );
    float gx = 0.0, gy = 0.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            uint2 offset = uint2(x,y);
            float4 color = inTexture.read(gid + offset);
            float luminace = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
            gx += luminace * sobelX[y+1][x+1];
            gy += luminace * sobelY[y+1][x+1];
        }
    }
    return sqrt(gx * gx + gy * gy);
}
float median(float values[9]) {
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8 - i; j++) {
            if (values[j] > values[j + 1]) {
                float temp = values[j];
                values[j] = values[j + 1];
                values[j + 1] = temp;
            }
        }
    }
    return values[4];
}
float calculateLuminance(float3 color) {
    // sRGB 표준에 맞는 정확한 휘도 계산 가중치
    return dot(color, float3(0.2126, 0.7152, 0.0722));
}
float4 medianFilter(texture2d<float,access::read> inTexture, uint2 gid) {
    float4 colors[9];
    int index = 0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x ++) {
            uint2 samplePos = uint2(clamp(int2(gid) + int2(x,y), int2(inTexture.get_width() - 1), inTexture.get_height() - 1));
            colors[index++] = inTexture.read(samplePos);
        }
    }
    float reds[9], greens[9], blues[9];
    for (int i = 0; i < 9; i++) {
        reds[i] = colors[i].r;
        greens[i] = colors[i].g;
        blues[i] = colors[i].b;
    }
    return float4(median(reds), median(greens), median(blues), colors[4].a);
}
// 색상 양자화 함수: 색상 수를 줄여 단순화된 색상 팔레트
float3 quantizeColor(float3 color, float levels) {
    return floor(color * levels) / levels;
}

// 가우시안 블러 함수: 부드러운 번짐 효과용
float4 gaussianBlur(texture2d<float, access::read> inTexture, uint2 gid, int radius) {
    float4 sum = float4(0.0);
    float totalWeight = 0.0;
    
    for (int y = -radius; y <= radius; y++) {
        for (int x = -radius; x <= radius; x++) {
            uint2 samplePos = uint2(clamp(int2(gid) + int2(x, y), int2(0), int2(inTexture.get_width() - 1, inTexture.get_height() - 1)));
            
            // 가우시안 가중치 계산
            float weight = exp(-(x*x + y*y) / (2.0 * radius * radius));
            sum += inTexture.read(samplePos) * weight;
            totalWeight += weight;
        }
    }
    
    return sum / totalWeight;
}

kernel void art_painting(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]],
                         constant float &intensity [[buffer(0)]]) {
    // 특징: 전체적으로 부드럽지만 색상 경계에는 번짐 효과-> 소벨필터/ 색상 블록을 더 부드럽게 -> 미디언 필터
    float edgePreservation = mix(0.7, 0.3, intensity);  // intensity가 높을수록 에지 보존이 낮아짐
    float blurRadius = mix(2.0, 5.0, intensity);        // intensity가 높을수록 더 넓은 블러 반경
    
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 originalColor = inTexture.read(correctedGid);
    if (intensity <= 0.01) {
        outTexture.write(originalColor, gid);
        return;
    }
    
    float luminance[9];
    int index = 0;
    // 휘도에만 미디언 필터를 적용해 색상정보는 보존하고 밝기의 노이즈만 제거하자. 색상은 중요하다.
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            uint2 samplePos = uint2(clamp(int2(correctedGid) + int2(x,y), int2(0), int2(inTexture.get_width() - 1, inTexture.get_height() - 1)));
            float4 sampleColor = inTexture.read(samplePos);
            luminance[index] = dot(sampleColor.rgb, float3(0.2126, 0.7152, 0.0722));
            index++;
        }
    }
    float medianLuminance = median(luminance);
    //2. edge검출 edgeFactor는 에지인 부분(낮은 값)과 평평한 영역(높은 값)을 구분하는 마스크
    float edge = sobelEdge(inTexture, correctedGid);
    float edgeFactor = 1.0 - smoothstep(0.0, 0.2, edge * edgePreservation);
    // 이후 엣지팩터를 활용하여 평평한영역(엣지팩터높은값)에서는 색상 번짐과 단순화 효과가 강하고 에지부분(낮은 엣지팩터)에서는 원본색상에 가깝게 유지.
    // 3. 양방향 블러 블러 효과를 주기 위해 주변 픽셀 샒플링.
    float4 blurredColor = float4(0);
    float totalWeight = 0.0;
    int radius = int(blurRadius);
    for (int y = -radius; y <= radius; y++) {
        for (int x = -radius; x <= radius; x++) {
            if (x*x + y*y > radius*radius) continue;
            uint2 samplePos = uint2(clamp(int2(correctedGid) + int2(x, y),
                                          int2(0),
                                          int2(inTexture.get_width() - 1, inTexture.get_height() - 1)));
            float4 sampleColor = inTexture.read(samplePos);
            
            // 공간적 가중치. 현재 픽셀에서 샘플 픽셀까지의 공간적 거리 제곱을 계산. 유클리드거리의 제곱. 거리가 멀수록 영향력이 작아지도록.
            float spatialDist = float(x*x + y*y);
            float spatialWeight = exp(-spatialDist / (2.0 * radius * radius));
            
            // 색상 가중치
            float colorDist = distance(originalColor.rgb, sampleColor.rgb);
            float colorWeight = exp(-(colorDist * colorDist) / (2.0 * 0.15 * 0.15));
            
            // 에지 가중치 (에지 근처에서는 덜 블러)
            float approxEdge = colorDist > 0.2 ? 1.0 : 0.0;
            float edgeWeight = mix(1.0, 1.0 - approxEdge, edgePreservation);
            
            float weight = spatialWeight * colorWeight * edgeWeight;
            blurredColor += sampleColor * weight;
            totalWeight += weight;
        }
    }
    blurredColor = blurredColor / max(totalWeight, 0.0001);
    // 4. 색상 양자화 (수채화 효과)
    float levels = mix(32.0, 4.0, intensity);  // 색상 단순화 정도
    float3 quantizedColor = mix(blurredColor.rgb, floor(blurredColor.rgb * levels) / levels, intensity);
    
    // 휘도 조정 - intensity에 비례하도록 수정
    float originalLuminance = dot(blurredColor.rgb, float3(0.2126, 0.7152, 0.0722));
    float luminanceRatio = 1.0;
    if (originalLuminance > 0.01) {
        // intensity에 따라 휘도 조정 범위 제어
        // intensity가 낮을수록 원본에 가깝게, 높을수록 수정 효과가 강하게
        float rawRatio = medianLuminance / originalLuminance;
        // 비율이 1에 가까울수록 변화가 적음, intensity에 따라 clamp 범위가 넓어짐
        float minRatio = mix(1.0, 0.7, intensity);
        float maxRatio = mix(1.0, 1.3, intensity);
        luminanceRatio = clamp(rawRatio, minRatio, maxRatio);
    }
    float3 luminanceAdjusted = mix(quantizedColor, quantizedColor * luminanceRatio, intensity);
    
    
    // 5. 수채화 질감 효과(종이의 자연스러운 불규칙한 질감을 위한 난수 생성)
    float2 noiseCoord = float2(correctedGid) * 0.01;
    float paperTexture = fract(sin(dot(noiseCoord, float2(12.9898, 78.233))) * 43758.5453);
    float textureStrength = mix(0.0, 0.05, intensity);
    float textureFactor = mix(1.0 - textureStrength, 1.0 + textureStrength, paperTexture);
    float3 texturedColor = luminanceAdjusted * textureFactor;
    
    // 7. 에지 처리 (수채화 특유의 약간 번지는 경계)
    float edgeBlending = mix(0.1, 0.7, intensity);
    float3 edgeAwareColor = mix(texturedColor, originalColor.rgb, (1.0 - edgeFactor) * edgeBlending);
    
    // 8. 최종 결과 - 원본과 수채화 효과 사이의 블렌딩
    //        float finalIntensity = intensity * 0.9;  // 약간 부드럽게 블렌딩
    float3 finalColor = mix(originalColor.rgb, edgeAwareColor, intensity);
    
    outTexture.write(float4(clamp(finalColor, 0.0, 1.0), originalColor.a), gid);
    
}


// 네온 글로우 필터
kernel void neon_glow(texture2d<float, access::read> inTexture [[texture(0)]],
                      texture2d<float, access::write> outTexture [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]],
                      constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 origColor = inTexture.read(correctedGid);
    
    // intensity가 0일 경우 원본 이미지 반환
    if (intensity <= 0.001) {
        outTexture.write(origColor, gid);
        return;
    }
    
    float4 color = origColor;
    float edgeStrength = sobelEdge(inTexture, correctedGid);
    edgeStrength = pow(edgeStrength, 0.8) * 2.5 * intensity;
    
    float3 neonColors;
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    if (luminance < 0.3) {
        neonColors = float3(0.3, 0.1, 0.6);
    } else if (luminance < 0.6) {
        neonColors = float3(0.1, 0.5, 0.8);
    } else {
        neonColors = float3(0.7, 0.3, 0.7);
    }
    
    float3 neonBase = color.rgb + neonColors * intensity * 0.6;
    float3 neon = neonBase + edgeStrength * float3(0.8, 0.5, 0.9);
    
    // intensity에 따라 원본과 필터 효과 블렌딩
    color.rgb = mix(origColor.rgb, neon, intensity);
    
    // 비네팅 효과도 intensity에 비례
    float2 center = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
    float vignette = 1.0 - dot(center, center) * 0.5 * intensity;
    color.rgb *= vignette;
    
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}

kernel void forest(texture2d<float, access::read> inTexture [[texture(0)]],
                   texture2d<float, access::write> outTexture [[texture(1)]],
                   uint2 gid [[thread_position_in_grid]],
                   constant float &intensity [[buffer(0)]]) {

//    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
//    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
//    float4 origcolor = inTexture.read(correctedGid);
//    float4 color = origcolor;
//    
//    // 숲의 색감 강화 - 녹색 및 청록색 강조
//    float3 forestTone = float3(-0.05, 0.25, 0.05);
//    color.rgb += forestTone * intensity;
//    
//    // 그림자 깊게, 더 자연스러운 그라데이션으로
//    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
//    if (luminance < 0.6) {
//        float shadowDepth = (0.6 - luminance) / 0.6;
//        color.rgb *= (1.0 - 0.25 * intensity * pow(shadowDepth, 1.2));
//    }
//    
//    // 하이라이트에 따뜻한 오렌지색 톤 살짝 추가
//    if (luminance > 0.7) {
//        color.rgb += float3(0.08, 0.04, -0.05) * intensity * (luminance - 0.7) / 0.3;
//    }
//    
//    // 콘트라스트 약간 증가
//    color.rgb = pow(color.rgb, float3(1.0 + 0.1 * intensity));
//    color.rgb = mix(origcolor.rgb,color.rgb,intensity);
//    outTexture.write(clamp(color, 0.0, 1.0), gid);
}
kernel void clean_bright(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]],
                         constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 origcolor = inTexture.read(correctedGid);
    float4 color = origcolor;
    
    // 전체적인 밝기 조정
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    float brightAdjust = 0.15 * intensity * (1.0 - pow(luminance, 0.6));
    color.rgb += brightAdjust;
    
    // 하이라이트 강화, 자연스러운 그라데이션으로
    if (luminance > 0.4) {
        float highlightStrength = pow((luminance - 0.4) / 0.6, 1.2);
        color.rgb += highlightStrength * intensity * 0.25;
    }
    
    // 선명도 증가
    float edgeStrength = sobelEdge(inTexture, correctedGid) * 0.08 * intensity;
    color.rgb += float3(edgeStrength);
    
    // 약간의 채도 증가
    luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(float3(luminance), color.rgb, 1.0 + intensity * 0.2);
    color.rgb = mix(origcolor.rgb,color.rgb,intensity);
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}


// Warm 필터
kernel void warm(texture2d<float, access::read> inTexture [[texture(0)]],
                 texture2d<float, access::write> outTexture [[texture(1)]],
                 uint2 gid [[thread_position_in_grid]],
                 constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 color = inTexture.read(correctedGid);
    
    // 따뜻한 색감 추가
    color.r += 0.15 * intensity;
    color.g += 0.05 * intensity;
    color.b -= 0.05 * intensity;
    
    // 채도 증가
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(float3(luminance), color.rgb, 1.0 + 0.3 * intensity);
    
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}

// Vintage Cinema 필터
kernel void vintage_cinema(texture2d<float, access::read> inTexture [[texture(0)]],
                           texture2d<float, access::write> outTexture [[texture(1)]],
                           uint2 gid [[thread_position_in_grid]],
                           constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 color = inTexture.read(correctedGid);
    
    // 시네마틱 색보정
    float3 sepia = float3(
                          dot(color.rgb, float3(0.393, 0.769, 0.189)),
                          dot(color.rgb, float3(0.349, 0.686, 0.168)),
                          dot(color.rgb, float3(0.272, 0.534, 0.131))
                          );
    
    // 콘트라스트 증가
    float3 adjusted = pow(color.rgb, float3(1.1));
    
    // 비네팅 효과
    float2 center = float2(gid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
    float vignette = 1.0 - dot(center, center) * 1.5;
    
    color.rgb = mix(color.rgb, sepia, intensity * 0.5);
    color.rgb = mix(color.rgb, adjusted, intensity * 0.3);
    color.rgb *= mix(1.0, vignette, intensity * 0.7);
    
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}

// Vintage 90s 필터
kernel void vintage_90s(texture2d<float, access::read> inTexture [[texture(0)]],
                        texture2d<float, access::write> outTexture [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]],
                        constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 color = inTexture.read(correctedGid);
    
    // 색상 조정
    color.r = pow(color.r, 0.9);
    color.g = pow(color.g, 1.1);
    color.b = pow(color.b, 1.2);
    
    // 채도 감소
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(color.rgb, float3(luminance), intensity * 0.3);
    
    // 그레인 효과
    float2 noiseCoord = float2(gid) / 8.0;
    float noise = fract(sin(dot(noiseCoord, float2(12.9898, 78.233))) * 43758.5453);
    color.rgb += (noise - 0.5) * intensity * 0.1;
    
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}

// Food Fresh 필터
kernel void food_fresh(texture2d<float, access::read> inTexture [[texture(0)]],
                       texture2d<float, access::write> outTexture [[texture(1)]],
                       uint2 gid [[thread_position_in_grid]],
                       constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 color = inTexture.read(correctedGid);
    
    // 채도 증가
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(float3(luminance), color.rgb, 1.0 + intensity * 0.5);
    
    // 따뜻한 색감 강화
    color.r *= (1.0 + 0.1 * intensity);
    color.g *= (1.0 + 0.05 * intensity);
    
    // 선명도 증가
    float edgeStrength = sobelEdge(inTexture, correctedGid);
    color.rgb += edgeStrength * intensity * 0.1;
    
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}

// Noir 필터
kernel void mood_noir(texture2d<float, access::read> inTexture [[texture(0)]],
                      texture2d<float, access::write> outTexture [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]],
                      constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 color = inTexture.read(correctedGid);
    
    // 흑백 변환
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    
    // 콘트라스트 증가
    float contrast = pow(luminance, 1.0 + intensity * 0.5);
    
    // 엣지 디텍션으로 드라마틱한 효과 추가
    float edgeStrength = sobelEdge(inTexture, correctedGid);
    contrast -= edgeStrength * intensity * 0.2;
    
    color.rgb = float3(contrast);
    
    outTexture.write(clamp(color, 0.0, 1.0), gid);
}
