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

float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}
// 펄린 스타일 노이즈 - 더 부드러운 변화를 위함
float perlinStyleNoise(float2 uv) {
    float2 i = floor(uv);
    float2 f = fract(uv);
    
    // 4개 코너에서의 해시값
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    
    // 부드러운 보간을 위한 퀸틱 곡선
    float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    
    // 4개 값 보간
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
float generatePaperTexture(float2 uv) {
    float noise1 = hash21(uv * 2000.0);
    float noise2 = hash21((uv + 0.5) * 1500.0);
    float noise3 = perlinStyleNoise(uv * 800.0);
    
    // 여러 노이즈를 혼합하여 자연스러운 종이 질감 생성
    float paperTexture = 0.96 + (noise1 * 0.01 + noise2 * 0.01 + noise3 * 0.02);
    
    return paperTexture;
}

kernel void handwritten_edge(
    texture2d<float, access::read> inTexture [[texture(0)]],
    texture2d<float, access::write> outTexture [[texture(1)]],
    uint2 gid [[thread_position_in_grid]],
    constant float &intensity [[buffer(0)]])
{
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
       uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
       
       // 2. 정규화된 UV 좌표
       float2 uv = float2(gid) / float2(inTexture.get_width(), inTexture.get_height());
       
       // 3. 엣지 검출
       float edge = sobelEdge(inTexture, correctedGid);
       
       // 4. 임계값 적용 (인텐시티에 따라 조절)
       float threshold = mix(0.12, 0.25, 1.0 - intensity);
       
       // 5. 손그림 효과를 위한 노이즈 생성
       float noise = hash21(uv * 800.0) - 0.5;
       float jitter = noise * 0.2 * intensity;
       
       // 6. 압력 변화 효과 (연필이나 펜의 압력 변화 시뮬레이션)
       float pressure = 0.6 + perlinStyleNoise(uv * 300.0) * 0.8;
       pressure = pow(pressure, 1.5); // 비선형 압력 조정
       
       // 7. 엣지에 노이즈 적용한 손그림 효과
       float edgeStrength = smoothstep(threshold - 0.02, threshold + 0.03, edge + jitter);
       
       // 8. 선 두께 변화
       float strokeWeight = edgeStrength * pressure;
       
       // 9. 종이 텍스처 생성
       float paper = generatePaperTexture(uv);
       
       // 10. 펜/연필 잉크 효과
       float inkVariation = 0.05 + hash21(uv * 900.0) * 0.15;
       float3 inkColor = float3(0.08 + inkVariation * 0.2);
       
       // 11. 최종 이미지 합성
       float3 paperColor = float3(paper); // 종이 배경
       float3 result = mix(paperColor, inkColor, strokeWeight);
       
       outTexture.write(float4(clamp(result, 0.0, 1.0), 1.0), gid);
}

kernel void art_painting(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]],
                         constant float &intensity [[buffer(0)]]) {
    // 특징: 전체적으로 부드럽지만 색상 경계에는 번짐 효과-> 소벨필터/ 색상 블록을 더 부드럽게 -> 미디언 필터
    float edgePreservation = mix(0.7, 0.3, intensity);  // intensity가 높을수록 에지 보존이 낮아짐
    float blurRadius = mix(4.0, 12.0, intensity);        // intensity가 높을수록 더 넓은 블러 반경
    
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
    float levels = mix(8.0, 2.0, pow(intensity, 0.5));  // 색상 단순화 정도
    float3 quantizedColor = mix(blurredColor.rgb, floor(blurredColor.rgb * levels) / levels, intensity);
    
    // 휘도 조정 - intensity에 비례하도록 수정
    float originalLuminance = dot(blurredColor.rgb, float3(0.2126, 0.7152, 0.0722));
    float luminanceRatio = 1.0;
    if (originalLuminance > 0.01) {
        // intensity에 따라 휘도 조정 범위 제어
        // intensity가 낮을수록 원본에 가깝게, 높을수록 수정 효과가 강하게
        float rawRatio = medianLuminance / originalLuminance;
        // 비율이 1에 가까울수록 변화가 적음, intensity에 따라 clamp 범위가 넓어짐
        float minRatio = mix(1.0, 0.4, pow(intensity, 0.5));
        float maxRatio = mix(1.0, 1.6, pow(intensity, 0.5));
        luminanceRatio = clamp(rawRatio, minRatio, maxRatio);
    }
    float3 luminanceAdjusted = mix(quantizedColor, quantizedColor * luminanceRatio, intensity);
    
    
    // 5. 수채화 질감 효과(종이의 자연스러운 불규칙한 질감을 위한 난수 생성)
    float2 noiseCoord = float2(correctedGid) * 0.01;
    float paperTexture = fract(sin(dot(noiseCoord, float2(12.9898, 78.233))) * 43758.5453);
    float textureStrength = mix(0.02, 0.1, pow(intensity, 0.5));
    float textureFactor = mix(1.0 - textureStrength, 1.0 + textureStrength, paperTexture);
    float3 texturedColor = luminanceAdjusted * textureFactor;
    
    // 7. 에지 처리 (수채화 특유의 약간 번지는 경계)
    float edgeBlending = mix(0.4, 0.8, pow(intensity, 0.5));
    float3 edgeAwareColor = mix(texturedColor, originalColor.rgb, (1.0 - edgeFactor) * edgeBlending);
    
    // 8. 최종 결과 - 원본과 수채화 효과 사이의 블렌딩
    float adjustedIntensity = pow(intensity, 0.7);  // intensity 강조
    float3 finalColor = mix(originalColor.rgb, edgeAwareColor, adjustedIntensity);
    
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
    
    float edgeStrength = sobelEdge(inTexture, correctedGid);
    edgeStrength = pow(edgeStrength, 0.6) * 5.0 * intensity; // 감마 강화, 스케일 증가
    
    // 2. 네온 컬러 팔레트 강화
    float3 neonColors;
    float luminance = dot(origColor.rgb, float3(0.2126, 0.7152, 0.0722));
    if (luminance < 0.3) {
        neonColors = float3(0.5, 0.1, 1.0); // 더 강렬한 보라/파랑
    } else if (luminance < 0.6) {
        neonColors = float3(0.0, 1.0, 1.0); // 청록
    } else {
        neonColors = float3(1.0, 0.2, 1.0); // 핑크/보라
    }
    
    // 3. 엣지 영역에 가우시안 블러로 글로우 확산
    float4 blurred = gaussianBlur(inTexture, correctedGid, 4); // radius=4로 확산범위 확대
    float glowAmount = clamp(edgeStrength, 0.0, 1.0);
    
    // 4. 네온 컬러 오버레이
    float3 neonGlow = neonColors * glowAmount * 1.2; // 네온 컬러 강조 및 강도 증가
    float3 neonBase = mix(origColor.rgb, blurred.rgb, 0.7) + neonGlow;
    
    // 5. 강한 색상 양자화로 네온 느낌 강조
    neonBase = quantizeColor(neonBase, 6.0); // 6단계 양자화
    
    // 6. 원본과 네온 효과 블렌딩
    float3 finalColor = mix(origColor.rgb, neonBase, intensity);
    
    float2 center = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
    float vignette = 1.0 - dot(center, center) * 0.7 * intensity; // 비네팅 강도 증가
    finalColor *= vignette;
    
    outTexture.write(float4(clamp(finalColor, 0.0, 1.0), origColor.a), gid);
}


kernel void scare_cinema(texture2d<float, access::read> inTexture [[texture(0)]],
                           texture2d<float, access::write> outTexture [[texture(1)]],
                           uint2 gid [[thread_position_in_grid]],
                           constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
    uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
    float4 originalColor = inTexture.read(correctedGid);
    
    // 원본 색상 저장
    float4 color = originalColor;
    
    // 1. 색상 데스츄레이션 - 공포영화 특유의 차갑고 칙칙한 색감
    float luminance = calculateLuminance(color.rgb);
    float3 desaturatedColor = float3(luminance);
    
    // 푸르스름한 색조로 조정 (차가운 청색)
    float3 coldTint = float3(0.7, 0.85, 1.0);
    float3 tintedColor = desaturatedColor * coldTint;
    
    // 원본과 탈색 이미지 혼합
    float desaturationAmount = 0.6 * intensity;
    color.rgb = mix(color.rgb, tintedColor, desaturationAmount);
    
    // 2. 대비(콘트라스트) 강화 - 더 극적인 명암차
    float3 contrastColor = (color.rgb - 0.5) * (1.0 + 0.5 * intensity) + 0.5;
    color.rgb = contrastColor;
    
    // 3. 비네팅 효과 (가장자리 어둡게) - 공포영화의 압박감 증가
    float2 center = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
    float vignetteDistance = length(center * 1.8); // 강한 비네팅을 위해 수치 조정
    float vignette = 1.0 - vignetteDistance;
    
    // 비네팅을 부드럽게하고 강도 조절
    vignette = smoothstep(0.0, 0.8, vignette);
    vignette = pow(vignette, 1.5); // 비네팅 형태 조정
    
    // 비네팅 적용
    float vignetteIntensity = 0.75 * intensity;
    color.rgb = mix(color.rgb * (1.0 - vignetteIntensity), color.rgb * vignette, vignetteIntensity);
    
    // 4. 노이즈/그레인 효과 - 오래된 공포 영화 느낌
    float2 noiseCoord = float2(gid) / 4.0; // 더 굵은 그레인
    float noise = fract(sin(dot(noiseCoord, float2(12.9898, 78.233))) * 43758.5453);
    float noiseAmount = mix(0.08, 0.15, intensity); // 강한 노이즈 적용
    color.rgb += (noise - 0.5) * noiseAmount;
    
    // 5. 엣지 강조 - 공포 장면에서 디테일 강조
    float edgeStrength = sobelEdge(inTexture, correctedGid);
    float3 edgeColor = float3(0.1, 0.1, 0.2); // 어두운 푸른빛 엣지
    color.rgb = mix(color.rgb, edgeColor, edgeStrength * 0.3 * intensity);
    
    // 6. 플리커링 효과 (깜빡임) - 공포영화의 불안정한 조명
    float flickerSpeed = 0.1;
    float flickerAmount = 0.08 * intensity;
    float flicker = sin(float(gid.y) * flickerSpeed) * 0.5 + 0.5;
    color.rgb *= 1.0 - (flicker * flickerAmount);
    
    // 7. 색상 왜곡 - 악몽같은 효과
    float2 distortionCenter = float2(0.5, 0.5); // 화면 중앙
    float2 normalizedPos = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height());
    float distortionDistance = length(normalizedPos - distortionCenter);
    
    // 색상 채널 분리
    float separationAmount = 0.005 * intensity * distortionDistance;
    
    uint2 redOffset = uint2(clamp(int2(correctedGid) + int2(int(separationAmount * inTexture.get_width()), 0),
                               int2(0), int2(inTexture.get_width() - 1, inTexture.get_height() - 1)));
    uint2 blueOffset = uint2(clamp(int2(correctedGid) - int2(int(separationAmount * inTexture.get_width()), 0),
                                int2(0), int2(inTexture.get_width() - 1, inTexture.get_height() - 1)));
    
    float redChannel = inTexture.read(redOffset).r;
    float blueChannel = inTexture.read(blueOffset).b;
    
    // 색상 채널 분리 적용
    color.r = mix(color.r, redChannel, intensity * 0.5);
    color.b = mix(color.b, blueChannel, intensity * 0.5);
    
    // 8. 블러 효과를 사용한 유령같은 흔들림
    float4 blurredColor = gaussianBlur(inTexture, correctedGid, 3);
    float blurAmount = 0.2 * intensity;
    color = mix(color, blurredColor, blurAmount);
    
    // 9. 어두운 부분 더 어둡게 (그림자 강화)
    float shadowThreshold = 0.5;
    float shadowIntensity = 0.2 * intensity;
    if (luminance < shadowThreshold) {
        color.rgb *= 1.0 - (shadowThreshold - luminance) * shadowIntensity;
    }
    
    // 10. 임의의 어두운 얼룩 추가 (불규칙한 그림자)
    float2 spotCoord = float2(gid) / 32.0;
    float spot = fract(sin(dot(spotCoord, float2(45.6789, 23.4567))) * 89012.3456);
    if (spot > 0.75) {
        float spotIntensity = 0.15 * intensity;
        color.rgb *= (1.0 - (spot - 0.75) * 4.0 * spotIntensity);
    }
    
    // 11. 혈흔 효과 (붉은 얼룩) - 공포영화 특유의 혈흔 표현
    if (intensity > 0.5) {
        float2 bloodCoord = float2(gid) / 16.0;
        float bloodNoise = fract(sin(dot(bloodCoord, float2(78.5432, 19.8765))) * 65432.1098);
        
        if (bloodNoise > 0.94) {
            float bloodAmount = (bloodNoise - 0.94) * 20.0 * (intensity - 0.5);
            float3 bloodColor = float3(0.5, 0.0, 0.0);
            color.rgb = mix(color.rgb, bloodColor, bloodAmount);
        }
    }
    
    // 12. 불규칙한 스캔라인 (깨진 필름/TV 효과)
    if (int(gid.y) % 4 == 0) {
        float scanlineIntensity = 0.05 * intensity;
        color.rgb -= scanlineIntensity;
    }
    
    // 최종 인텐시티에 따른 혼합
    color = mix(originalColor, color, clamp(intensity, 0.0, 1.0));
    
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
    float4 originalColor = color;
    
    // 1. 색상 조정 - 더 강한 90년대 필름 색감
     color.r = pow(color.r, 0.85) * 1.15; // 레드 채널 강화
     color.g = pow(color.g, 1.05); // 그린 채널 약간 조정
     color.b = pow(color.b, 1.4) * 0.85; // 블루 채널 억제 및 변형
    // 2. 색상 시프트 - 특유의 90년대 컬러 시프트 (마젠타/시안 경향)
       float3 colorShift = float3(0.06, -0.02, 0.08) * intensity;
       color.rgb += colorShift;
    
    // 채도 감소
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    float3 warmLuminance = float3(luminance * 1.1, luminance * 1.0, luminance * 0.9); // 따뜻한 색조의 휘도
    color.rgb = mix(color.rgb, warmLuminance, intensity * 0.4);

    // 향상된 그레인 효과 - 더 다양하고 필름과 유사한 그레인
     float2 noiseCoord = float2(gid);
     float noise1 = fract(sin(dot(noiseCoord, float2(12.9898, 78.233))) * 43758.5453);
     float noise2 = fract(sin(dot(noiseCoord, float2(39.7459, 28.7573))) * 23421.6817);
     float noise3 = fract(sin(dot(noiseCoord, float2(54.3289, 41.2946))) * 76841.1645);
     
     float3 noise = float3(noise1, noise2, noise3) - 0.5;
     float grainIntensity = 0.15 * intensity;
     color.rgb += noise * grainIntensity;
    // 비네팅 효과 - 오래된 사진 느낌을 위한 가장자리 어두워짐
     float2 center = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
     float vignette = 1.0 - dot(center * 1.5, center * 1.5);
     vignette = pow(clamp(vignette, 0.0, 1.0), 0.8 + intensity * 0.8);
     color.rgb *= mix(1.0, vignette, intensity * 0.5);
    // 컬러 스크래치와 먼지 효과
    float scratch = 0.0;
    if (fract(noiseCoord.y * 0.1) < 0.03 * intensity && noise1 > 0.6) {
        scratch = 0.1 * intensity;
    }
    color.rgb += scratch;
    
    float3 midtones = float3(0.6, 0.55, 0.5); // 중간톤이 이동된 위치
        color.rgb = pow(color.rgb, float3(1.0) / (midtones + (1.0 - midtones) * (1.0 - intensity)));
    
    color = mix(originalColor, color, clamp(intensity, 0.0, 1.0));
        
        outTexture.write(clamp(color, 0.0, 1.0), gid);
}
kernel void clean_bright(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]],
                         constant float &intensity [[buffer(0)]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }
       uint2 correctedGid = uint2(gid.x, inTexture.get_height() - 1 - gid.y);
       float4 color = inTexture.read(correctedGid);
       
       // 1. 부드러운 피부톤 효과 (약한 블러)
       float4 blurredColor = gaussianBlur(inTexture, correctedGid, 2);
       float edgeStrength = sobelEdge(inTexture, correctedGid);
       float edgeMask = smoothstep(0.1, 0.2, edgeStrength); // 에지 부분은 보존
       
       // 블러와 원본 혼합 (디테일은 유지)
       color.rgb = mix(mix(blurredColor.rgb, color.rgb, 0.5), color.rgb, edgeMask);
       
       // 2. 자연스러운 색감 향상
       
       // 밝기 약간 증가
       float brightness = 1.0 + 0.08 * intensity;
       color.rgb *= brightness;
       
       // 콘트라스트 약간 증가
       float contrast = 1.0 + 0.1 * intensity;
       color.rgb = ((color.rgb - 0.5) * contrast) + 0.5;
       
       // 채도 약간 증가 (너무 과하지 않게)
       float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
       float saturation = 1.0 + 0.12 * intensity;
       color.rgb = mix(float3(luminance), color.rgb, saturation);
       
       // 3. 피부톤 보정 (살짝 따뜻한 색감)
       float3 warmTone = float3(1.02, 1.0, 0.97);
       color.rgb = mix(color.rgb, color.rgb * warmTone, 0.15 * intensity);
       
       // 4. 비네팅 효과 (중앙 초점)
       float2 center = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
       float vignette = 1.0 - dot(center, center) * 0.2 * intensity;
       color.rgb *= vignette;
       
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
       
       // 1. 휘도 계산 (나중에 색상 조정에 사용)
       float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
       
       // 2. 채도 크게 증가 (음식 색상 더 생생하게)
       color.rgb = mix(float3(luminance), color.rgb, 1.0 + intensity * 0.8);
       
       // 3. 음식 색상 강화 (붉은색, 노란색, 주황색 강화 - 대부분의 맛있는 음식에 해당)
       // 붉은색 강화
       color.r *= (1.0 + 0.15 * intensity);
       
       // 황금색/주황색 강화 (빨강과 초록의 조합)
       if (color.r > 0.5 && color.g > 0.3) {
           color.r *= (1.0 + 0.1 * intensity);
           color.g *= (1.0 + 0.1 * intensity);
       }
       
       // 4. 갈색 조정 (구운 음식, 고기 등의 갈색 강화)
       if (color.r > color.g && color.g > color.b && color.r > 0.3 && color.g > 0.2 && color.b < 0.3) {
           color.r *= (1.0 + 0.12 * intensity);
           color.g *= (1.0 + 0.06 * intensity);
       }
       
       // 5. 선명도 증가 (음식 질감 강조)
       float edgeStrength = sobelEdge(inTexture, correctedGid);
       color.rgb += edgeStrength * intensity * 0.15;
       
       // 6. 하이라이트 강화 (반짝이는 효과로 신선해 보이게)
       float highlightBoost = 0.1 * intensity;
       if (luminance > 0.7) {
           color.rgb += highlightBoost * (luminance - 0.7) / 0.3;
       }
       
       // 7. 비네팅 효과 (초점을 음식에 집중시키는 효과)
       float2 center = float2(correctedGid) / float2(inTexture.get_width(), inTexture.get_height()) - 0.5;
       float vignette = 1.0 - dot(center, center) * 0.4 * intensity;
       color.rgb *= vignette;
       
       // 8. 약간의 따뜻한 톤 추가 (식욕을 돋우는 톤)
       float3 warmTone = float3(1.02, 1.0, 0.95); // 아주 약간의 따뜻한 톤
       color.rgb *= mix(float3(1.0), warmTone, 0.3 * intensity);
       
       // 9. 녹색 채소 강화 (신선한 느낌을 위해)
       if (color.g > color.r && color.g > color.b) {
           color.g *= (1.0 + 0.12 * intensity);
       }
       
       // 10. 매력적인 색상 대비 강화
       float contrast = 1.0 + 0.15 * intensity;
       color.rgb = (color.rgb - 0.5) * contrast + 0.5;
       
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
