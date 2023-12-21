//
//  SHKColorAlpha.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/12.
//  ORIGINAL: SOURCE: https://github.com/twostraws/ShaderKit
//  ORIGINAL: CREDIT: Copyright © 2017 Paul Hudson. Licensed under MIT License (see the original header in the shader source string below)
//  UPDATES:  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public final class ColorAlphaShader: SKShader {

    public init(color: SKColor = .green) {
        
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_color", color: color)
        ]
        
        super.init(source: SHKColorAlphaShaderSource, uniforms: uniforms)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate let SHKColorAlphaShaderSource = """
//
// Colors all clear pixels in the node.
// Uniform: u_color, the SKColor to use.
//
// This works by scanning the alpha value of the current pixel. If it's transparent then
// we color it using whatever was passed in by the user. If it's not transparent then
// we blend it using the source color and user's color based on how transparent the
// pixel is. This gives us a nice soft edge where existing pixels become translucent.
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
    // find the current pixel color
    vec4 current_color = SKDefaultShading();

    // if it's transparent
    if (current_color.a == 0.0) {
        // use the input color, multiplying by the node alpha so we can fade in or out
        gl_FragColor = u_color * v_color_mix.a;
    } else {
        // make a blended color based on the input and current pixel color, using as much as is needed
        // based on the alpha value of the current pixel
        gl_FragColor = mix(u_color, current_color, current_color.a) * v_color_mix.a;
    }
}
"""
