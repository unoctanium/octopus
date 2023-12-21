//
//  SHKRadialGradient.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/12.
//  ORIGINAL: SOURCE: https://github.com/twostraws/ShaderKit
//  ORIGINAL: CREDIT: Copyright © 2017 Paul Hudson. Licensed under MIT License (see the original header in the shader source string below)
//  UPDATES:  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public final class RadialGradientShader: SKShader {

    public init(firstColor:     SKColor = .red,
                secondColor:    SKColor = .green,
                center:         CGPoint = CGPoint(x: 0.75, y: 0.25))
    {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_first_color",    color: firstColor),
            SKUniform(name: "u_second_color",   color: secondColor),
            SKUniform(name: "u_center",         point: center)
        ]
        
        super.init(source: SHKRadialGradientShaderSource, uniforms: uniforms)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate let SHKRadialGradientShaderSource = """
//
// Creates a radial gradient over the node. Either the start or the end color can be translucent to let original pixel colors come through.
// Uniform: u_first_color, the SKColor to use at the center of the gradient
// Uniform: u_second_color, the SKColor to use at the edge of the gradient
// Uniform: u_center, a CGPoint representing the center of the gradient, where 0.5/0.5 is dead center
//
// This works by blending the first color with the second based on how far the pixel is from
// the center of the circle. That's then blended with the original pixel color based on how
// opaque the replacement color is, so that we can fade out to clear if needed.
//
// MIT License
//
// Copyright (c) 2017 Paul Hudson
// https://www.github.com/twostraws/ShaderKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

void main() {
    // get the color of the current pixel
    vec4 current_color = texture2D(u_texture, v_tex_coord);

    // the center of our circle
    vec2 circle_center = u_center;

    // how far our pixel is from the center of the circle, doubled and clamped so the range is 0.0 to 1.0
    float pixel_distance = min(1.0, distance(v_tex_coord, circle_center) * 2.0);

    // if the current color is not transparent
    if (current_color.a > 0.0) {
        // mix the first color with the second color by however far away we are,
        // multiplying by this pixel's alpha (to avoid a hard edge) and also
        // multiplying by the node alpha so we can fade in or out
        vec4 new_color = mix(u_first_color, u_second_color, pixel_distance);
        gl_FragColor = vec4(mix(current_color, new_color, new_color.a)) * current_color.a * v_color_mix.a;
    } else {
        // use the current (transparent) color
        gl_FragColor = current_color;
    }
}
"""
