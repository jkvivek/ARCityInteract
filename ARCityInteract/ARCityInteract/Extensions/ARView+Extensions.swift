//
//  ARView+Extensions.swift
//  ARCityInteract
//
//  Created by Vivek Jalahalli on 2/10/25.
//

import Foundation
import ARKit
import RealityKit

extension ARView{
    
    func addCoachingOverlay() {
        let coachingView = ARCoachingOverlayView()
        coachingView.goal = .horizontalPlane
        coachingView.session = self.session
        coachingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(coachingView)
    }
    
}

