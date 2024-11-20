//
//  Constants.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import Foundation
import SwiftUI

struct Constants {
    // MARK: - 각도 정보
    static let angles: [(Double, Double)] = [
        (0, 60),
        (-60, 0),
        (60, 120),
        (-120, -60),
        (120, 180),
        (-180, -120),
        (180, 240),
        (-240, -180),
        (240, 300),
        (-300, -240),
        (300, 360),
        (-360, -300),
        (360, 420),
        (-420, -360),
        (420, 480),
        (-480, -420),
        (480, 540),
        (-540, -480),
        (540, 600),
        (-600, -540),
        (600, 660),
        (-660, -600),
        (660, 720),
        (-720, -660),
        (720, 780),
        (-780, -720),
        (780, 840),
        (-840, -780),
        (840, 900),
        (-900, -840),
        (900, 960),
        (-960, -900),
        (960, 1020),
        (-1020, -960),
        (1020, 1080),
        (-1080, -1020),
        (1080, 1140),
        (-1140, -1080),
        (1140, 1200),
        (-1200, -1140),
        (1200, 1260),
        (-1260, -1200),
        (1260, 1320),
        (-1320, -1260),
        (1320, 1380),
        (-1380, -1320),
        (1380, 1440),
        (-1440, -1380),
        (1440, 1500),
        (-1500, -1440)
    ]
    
    // MARK: - 타원 크기
    static let ellipses: [(width: CGFloat, height: CGFloat)] = [
        (1260, 1008), (967, 774), (674, 540), (285, 225)
    ]
    
    // MARK: - 타원 Color
    static let gradientColors: [(firstColor: Color, secondColor: Color)] = [
        (.subColor0, .subColor1), (.subColor1, .subColor2), (.subColor2, .subColor3), (.subColor3, .subColor4)
    ]
}
