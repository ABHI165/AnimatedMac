//
//  ContentView.swift
//  AnimatedMac
//
//  Created by Abhishek Agarwal  on 9/6/22.
//

import ARKit
import SwiftUI
import RealityKit



struct ContentView: View {
    var body: some View {
        ARViewRepresentable()
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ARViewRepresentable: UIViewRepresentable {
    let arView: ARView = ARView(frame: .zero)
    
    func makeCoordinator() -> ARCoordinator {
        ARCoordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
           guard let referenceImages = ARReferenceImage.referenceImages(
                       inGroupNamed: "AR Resources", bundle: nil) else {
                       fatalError("Missing asset catalog.")
                   }
           
    
           arView.session.delegate = context.coordinator
           
           let configuration = ARImageTrackingConfiguration()
           configuration.isAutoFocusEnabled = true
           configuration.trackingImages = referenceImages
           configuration.maximumNumberOfTrackedImages = 1
           
           arView.session.run(configuration)
           return arView
       }
       
       func updateUIView(_ uiView: ARView, context: Context) {}
    
    
}


class ARCoordinator: NSObject, ARSessionDelegate {
    var player: AVPlayer
    let parent: ARViewRepresentable
    
    init(_ view: ARViewRepresentable) {
        self.parent = view
        
        guard let path = Bundle.main.path(forResource: "mac", ofType: "mov") else {
            fatalError("Video Not Found!!")
        }
        
        let videoURL = URL(fileURLWithPath: path)
        player = AVPlayer(url: videoURL)
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let macAnchor = anchors[0] as? ARImageAnchor else { return }
        
        let videoMaterial = VideoMaterial(avPlayer: player)
        
        let videoPlane = ModelEntity(mesh: .generatePlane(width: Float(macAnchor.referenceImage.physicalSize.width * 1.02), depth: Float(macAnchor.referenceImage.physicalSize.height * 1.02)), materials: [videoMaterial])
        
        if let imageName = macAnchor.name, imageName  == "mac" {
            let anchor = AnchorEntity(anchor: macAnchor)
            anchor.addChild(videoPlane)
            parent.arView.scene.addAnchor(anchor)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let imageAnchor = anchors[0] as? ARImageAnchor else {return}
        
        
        if imageAnchor.isTracked {
            player.play()
        } else {
            player.pause()
        }
    }
}
