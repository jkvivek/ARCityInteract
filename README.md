# ARCityInteract

AR app to place City towers and vehicles

This app detects horizontal floor with a camera pass, and renders tall towers.
User can tap on the screen to place Vehicles(cones) at any position on the floor.
Collision is checked to make sure Towers and Vehicles wont overlap while placing on floor.

Additional Featuers:
- User can add more towers
- User can remove towers
- User can remove vehicles

// MARK: - AR Session Handling
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {}

// MARK: - Gesture Handling
@objc func handleTap(_ recognizer: UITapGestureRecognizer) {}

// MARK: - Object Placement
func placeTowersRandomly(on arView: ARView, count: Int = 5) {}
func placeVehicle(on arView: ARView, at position: SIMD3<Float>) {}

// MARK: - Collision Detection
func checkCollision(on arView: ARView, at position: SIMD3<Float>) -> Bool {}

// MARK: - Object Removal
func removeFewTowers() {}
func removeFewCones() {}

// MARK: - UI Button Handlers
lazy var addTowerButton = createButton(...)     // User can add in more towers
lazy var removeTowerButton = createButton(...)  // User can remove towers from the floor. Last 2 placed towers are removed
lazy var removeCarCones  = createButton(...)    // User can remove cars from the floor. Last 2 placed cars are removed

// MARK: - UI Setup
func setupUI() {}
