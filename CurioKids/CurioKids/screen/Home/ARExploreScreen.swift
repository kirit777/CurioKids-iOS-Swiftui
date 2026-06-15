//
//  ARExploreScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import RealityKit
import ARKit

struct ARExploreScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedObject = ARLearningObject.samples[0]
    @State private var resetTrigger = UUID()

    private let objects = ARLearningObject.samples

    var body: some View {
        GeometryReader { geo in
            let isPad = geo.size.width > 700

            ZStack {
                ARLearningView(
                    selectedObject: selectedObject,
                    resetTrigger: resetTrigger
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView(isPad: isPad, topInset: geo.safeAreaInsets.top)

                    Spacer()

                    objectSelector(isPad: isPad, bottomInset: geo.safeAreaInsets.bottom)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool, topInset: CGFloat) -> some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.92))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("AR Explore")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Place learning objects in your room.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Button {
                resetTrigger = UUID()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.92))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, isPad ? 40 : 20)
       //.padding(.top, topInset + 18)
    }

    private func objectSelector(isPad: Bool, bottomInset: CGFloat) -> some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(selectedObject.title)
                    .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(selectedObject.fact)
                    .font(.system(size: isPad ? 16 : 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(objects) { object in
                        Button {
                            selectedObject = object
                            resetTrigger = UUID()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: object.icon)
                                Text(object.title)
                            }
                            .font(.system(size: isPad ? 16 : 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(selectedObject.id == object.id ? .white : AppColors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(selectedObject.id == object.id ? object.color : AppColors.white.opacity(0.9))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(isPad ? 22 : 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .padding(.horizontal, isPad ? 40 : 20)
        .padding(.bottom, bottomInset + 18)
    }
}

struct ARLearningView: UIViewRepresentable {
    let selectedObject: ARLearningObject
    let resetTrigger: UUID
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        configureSession(for: arView)
        addObject(to: arView)
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        arView.scene.anchors.removeAll()
        addObject(to: arView)
    }
    
    private func configureSession(for arView: ARView) {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func addObject(to arView: ARView) {
        let anchor = AnchorEntity(world: [0, 0, -0.7])
        
        let entity: ModelEntity
        
        switch selectedObject.shape {
        case .sphere:
            entity = ModelEntity(
                mesh: .generateSphere(radius: 0.13),
                materials: [SimpleMaterial(color: selectedObject.uiColor, roughness: 0.35, isMetallic: false)]
            )
            
        case .box:
            entity = ModelEntity(
                mesh: .generateBox(size: 0.22),
                materials: [SimpleMaterial(color: selectedObject.uiColor, roughness: 0.35, isMetallic: false)]
            )
            
        case .cylinder:
            entity = ModelEntity(
                mesh: .generateCylinder(height: 0.32, radius: 0.08),
                materials: [SimpleMaterial(color: selectedObject.uiColor, roughness: 0.35, isMetallic: false)]
            )
            
            entity.generateCollisionShapes(recursive: true)
            
            let textMesh = MeshResource.generateText(
                selectedObject.title,
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 0.08, weight: .bold),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            
            let textEntity = ModelEntity(
                mesh: textMesh,
                materials: [SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)]
            )
            
            textEntity.position = [-0.18, -0.24, 0]
            
            anchor.addChild(entity)
            anchor.addChild(textEntity)
            arView.scene.addAnchor(anchor)
        }
    }
}

struct ARLearningObject: Identifiable {
    let id = UUID()
    let title: String
    let fact: String
    let icon: String
    let color: Color
    let uiColor: UIColor
    let shape: ARObjectShape

    static let samples: [ARLearningObject] = [
        .init(
            title: "Earth",
            fact: "Earth is our home planet and most of it is covered with water.",
            icon: "globe.asia.australia.fill",
            color: AppColors.accent,
            uiColor: .systemBlue,
            shape: .sphere
        ),
        .init(
            title: "Sun",
            fact: "The Sun is a star that gives Earth light and heat.",
            icon: "sun.max.fill",
            color: AppColors.secondary,
            uiColor: .systemOrange,
            shape: .sphere
        ),
        .init(
            title: "Cube",
            fact: "A cube has 6 equal square faces.",
            icon: "cube.fill",
            color: AppColors.primary,
            uiColor: .systemIndigo,
            shape: .box
        ),
        .init(
            title: "Rocket",
            fact: "Rockets help astronauts and satellites travel into space.",
            icon: "airplane.departure",
            color: AppColors.pink,
            uiColor: .systemPink,
            shape: .cylinder
        )
    ]
}

enum ARObjectShape {
    case sphere
    case box
    case cylinder
}

#Preview {
    NavigationStack {
        ARExploreScreen()
    }
}
