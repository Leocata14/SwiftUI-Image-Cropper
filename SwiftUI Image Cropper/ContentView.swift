//
//  ContentView.swift
//  SwiftUI Image Cropper
//
//  Created by Jason Leocata on 20/10/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CropperView(image: UIImage(named: "demo"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CropperView: View {
    
    @State private var scale: CGFloat = 1.0
    @State private var degrees: Double = 0
    @State private var offset = CGSize.zero
    
    let image: UIImage?
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { (value) in
            self.scale = value.magnitude
        }
        
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5)).onChanged { (value) in
            self.degrees = value.degrees
        }
        
        let scaleAndRotateGesture = SimultaneousGesture(magnificationGesture, rotationGesture)
        
        let dragGesture = DragGesture().onChanged { (value) in
            let translation = value.translation
            print(translation)
            self.offset = translation
        }
        
        return image != nil ?
            ZStack {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(scale)
                    .rotationEffect(Angle(degrees: degrees))
                    .offset(self.offset)
                    .gesture(scaleAndRotateGesture)
                    .highPriorityGesture(dragGesture)
            }
            .frame(width: 300, height: 300)
            .clipped()
         : nil
    }
}
