//
//  Shaders.metal
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 21/04/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    packed_float3 position;
};


struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
    float cosAlpha;
    float cosTheta;
    float distance;
};

struct Light {
    packed_float3 color;
    float ambientIntensity;
    packed_float4 position;
    float intensity;
    float shininess;
};

struct Compound1Float4 {
    float lightPower;
    float dummy1;
    float dummy2;
    float dummy3;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    Light light;
};

vertex VertexOut basic_vertex (
   const device VertexIn* vertex_array [[ buffer(0) ]],
   constant Uniforms& Uniforms [[ buffer(1) ]],
   unsigned int vid [[ vertex_id ]]
) {
   float4x4 modelMatrix = Uniforms.modelMatrix;
   float4x4 viewMatrix = Uniforms.viewMatrix;
   float4x4 projMatrix = Uniforms.projectionMatrix;
   VertexIn VertexIn = vertex_array[vid];
   float3 Vertex1 = VertexIn.position;
   float3 Vertex2;
   float3 Vertex3;
   float3 Vector1;
   float3 Vector2;
   if (vid%3 == 0) {
      Vertex2 = vertex_array[vid+1].position;
      Vertex3 = vertex_array[vid+2].position;
   } else if (vid%3 == 1) {
      Vertex2 = vertex_array[vid+1].position;
      Vertex3 = vertex_array[vid-1].position;
   } else {
      Vertex2 = vertex_array[vid-2].position;
      Vertex3 = vertex_array[vid-1].position;
   }
   Vector1 = Vertex2 - Vertex3;
   Vector2 = Vertex2 - Vertex1;
   VertexOut VertexOut;
   float4 vertexPosition =
      viewMatrix * modelMatrix * float4(VertexIn.position, 1);
   float4 lightPosition = viewMatrix * (float4)Uniforms.light.position;
   float3 lightFromVertex = normalize((lightPosition-vertexPosition).xyz);
   float3 vertexNormal = cross(Vector1, Vector2);
   vertexNormal = normalize (
      (viewMatrix * modelMatrix * float4(vertexNormal, 0.0)).xyz
   );
   float3 vertexDirection = normalize(vertexPosition.xyz);
   float3 lightReflection = reflect(-lightFromVertex, vertexNormal);
   float3 eyeDirection = -vertexDirection;
   VertexOut.cosTheta = clamp(dot(lightFromVertex, vertexNormal), 0.0, 1.0);
   VertexOut.cosAlpha = clamp(dot(eyeDirection, lightReflection), 0.0, 1.0);
   VertexOut.distance = length(vertexPosition -  lightPosition);
   VertexOut.color = float4(VertexIn.position,1.0);
   VertexOut.position = projMatrix * vertexPosition;
   return VertexOut;
}

fragment float4 basic_fragment (
   VertexOut interpolated [[stage_in]], 
   const device Uniforms& Uniforms [[ buffer(1) ]],
   texture2d<float> tex2D [[ texture(0) ]],
   sampler sampler2D [[sampler(0)]]
) { 
   Light light = Uniforms.light;
   float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
   float lightIntensity = 
   light.intensity / (interpolated.distance*interpolated.distance);
   float diffuseFactor 
      = interpolated.cosTheta;
   float4 diffuseColor 
      = float4(light.color * lightIntensity * diffuseFactor, 1.0);
   float specularFactor = pow(interpolated.cosAlpha, light.shininess);
   float4 specularColor = float4(light.color * lightIntensity * specularFactor, 1.0);
   return (interpolated.color+tex2D.sample(sampler2D, interpolated.texCoord))*(ambientColor + diffuseColor+ specularColor);
}

