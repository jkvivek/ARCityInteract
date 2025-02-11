//
//  Coordinator.swift
//  ARCityInteract
//
//  Created by Vivek Jalahalli on 2/10/25.
//

import Foundation
import ARKit
import RealityKit

class Coordinator: NSObject, ARSessionDelegate{
    weak var arView: ARView?
    var floorAnchor: AnchorEntity?
    var planeAnchor: ARPlaneAnchor?
    var towerAnchors: [AnchorEntity] = []  // Keep track of Tower Anchors
    var vehicleAnchors: [AnchorEntity] = [] // Keep list of Vehicle Anchors
    var placedEntities: [ModelEntity] = [] // Keep track of all placed model entities ( Tower , Vehicle )

// MARK: AR Session Handling
    /*
        Get the first horizontal plane detected
        Place 5 towers as a start
     */
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        guard let arView = self.arView else { return }
        
        // Detect horizontal plane to place towers
        for anchor in anchors {
            guard let detectedPlaneAnchor = anchor as? ARPlaneAnchor else { continue }
            planeAnchor = detectedPlaneAnchor
            let position = SIMD3<Float>(detectedPlaneAnchor.center.x, Float(detectedPlaneAnchor.transform.columns.3.y), detectedPlaneAnchor.center.z)
            
            let newFloorAnchor = AnchorEntity(world: position)
            arView.scene.addAnchor(newFloorAnchor)
            floorAnchor = newFloorAnchor

            placeTowersRandomly(on: arView, count: 5)
        }
    }

    /*
        Handle Tap gestures to place vehicles as cones
        Default : 1 vehicle/cone at each tap
     */
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        guard let arView = self.arView else { return }

        let tapLocation = recognizer.location(in: arView)
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        if let result = results.first {
            let position = result.worldTransform.columns.3
            let worldPosition = SIMD3<Float>(position.x, position.y, position.z)
            placeVehicle(on: arView, at: worldPosition)
        }
    }

// MARK: AR Session handling to place Towers / Vehicles
    /*  Place towers at random positions on the plane anchor
        Count : Pass in number of towers to be placed. Default is 5
     */
    func placeTowersRandomly(on arView: ARView, count: Int = 5) {
        
        guard let planeAnchor = planeAnchor else { return }
        let position = SIMD3<Float>(planeAnchor.center.x, Float(planeAnchor.transform.columns.3.y), planeAnchor.center.z)

        guard let cameraTransform = arView.session.currentFrame?.camera.transform else { return }
        let cameraDirection = SIMD3<Float>(-cameraTransform.columns.2.x, 0, -cameraTransform.columns.2.z)
                    
        for i in 0..<count {
            
            var towerPosition: SIMD3<Float>
            repeat{
                let offset = Float(i) * 0.5 + 0.5 // Spread them out
                let randomX = cameraDirection.x * offset + Float.random(in: -0.3...0.3)
                let randomZ = cameraDirection.z * offset + Float.random(in: -0.1...0.3)
                let height = Float.random(in: 0.2...0.5)
                
                towerPosition = SIMD3<Float>(position.x + randomX, Float(planeAnchor.transform.columns.3.y) + height / 2, position.z + randomZ)
                
            }while checkCollision(on: arView, at: towerPosition)
            
            let towerSize = SIMD3<Float>(0.1, Float.random(in: 0.2...0.9), 0.1)
            
            let tower = ModelEntity(mesh: .generateBox(size: towerSize, cornerRadius: 0))
            tower.model?.materials = [SimpleMaterial(color: UIColor.random(), isMetallic: false)]
            tower.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
            placedEntities.append(tower)

            let towerAnchor = AnchorEntity(world: towerPosition)
            towerAnchor.addChild(tower)
            arView.scene.addAnchor(towerAnchor)
            
            towerAnchors.append(towerAnchor)
        }
    }

    /*
        Helper function to place vehicle at tapped position
     */
    func placeVehicle(on arView: ARView, at position: SIMD3<Float>) {

        if checkCollision(on: arView, at: position){
            return
        }

        let vehicle = ModelEntity(mesh: .generateCone(height: 0.2, radius: 0.05))
        vehicle.model?.materials = [SimpleMaterial(color: UIColor.random(), isMetallic: true)]
        vehicle.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        let vehicleAnchor = AnchorEntity(world: position)
        vehicleAnchor.addChild(vehicle)
        arView.scene.addAnchor(vehicleAnchor)
        placedEntities.append(vehicle) // Track the placed vehicle
        vehicleAnchors.append(vehicleAnchor)
    }

// MARK: - Collision Detection
    /*
        Check if the new object will collide with any existing placed entities ( Towers & Vehicles )
     */
    func checkCollision(on arView: ARView, at position: SIMD3<Float>) -> Bool {
        for entity in placedEntities {
            let distance = simd_length(position - entity.position)
            if distance < 0.3 {
                return true // Collision detected
            }
        }
        return false
    }

// MARK: Remove Towers / Cones
    /*
        Remove last 2 towers when user taps "Remove Towers" button
        Helps if city is too crowded
     */
    func removeFewTowers() {
        guard !towerAnchors.isEmpty else { return }
        for _ in 0..<min(2, towerAnchors.count) { // Remove up to 2 Towers
            let anchorToRemove = towerAnchors.removeLast()
            anchorToRemove.removeFromParent()
            
            // Remove the entity from placedEntities too
            if let index = placedEntities.firstIndex(where: { $0 == anchorToRemove.children.first }) {
                placedEntities.remove(at: index)
            }
        }
    }
    
    /*
        Removes last 2 cones when user taps "Remove vehicles" button
     */
    func removeFewCones() {
        guard !vehicleAnchors.isEmpty else { return }
        for _ in 0..<min(2, vehicleAnchors.count) { // Remove up to 2 Cones
            let anchorToRemove = vehicleAnchors.removeLast()
            anchorToRemove.removeFromParent()
            
            // Remove the entity from placedEntities too
            if let index = placedEntities.firstIndex(where: { $0 == anchorToRemove.children.first }) {
                placedEntities.remove(at: index)
            }
        }
    }

// MARK: - UI Button Handlers
    lazy var addTowerButton = createButton(title: "Add Towers", backgroundColor: .systemBlue) { [weak self] _ in
        guard let arView = self?.arView else { return }
        self?.placeTowersRandomly(on: arView, count: 3)
    }
    
    lazy var removeTowerButton = createButton(title: "Remove Towers", backgroundColor: .systemBlue) { [weak self] _ in
        guard let arView = self?.arView else { return }
        self?.removeFewTowers()
    }
    
    lazy var removeCarCones  = createButton(title: "Remove Vehicle", backgroundColor: .systemBlue) { [weak self] _ in
        guard let arView = self?.arView else { return }
        self?.removeFewCones()
    }

// MARK: setupUI for stackView/buttons
    func setupUI() {
        guard let arView = self.arView else { return }
        
        let stackView = UIStackView(arrangedSubviews: [addTowerButton, removeTowerButton, removeCarCones])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        arView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
                stackView.bottomAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                stackView.heightAnchor.constraint(equalToConstant: 50),
                stackView.leadingAnchor.constraint(equalTo: arView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: arView.trailingAnchor, constant: -20)
            ])
    }
    
}
