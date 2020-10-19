//
//  ContentView.swift
//  SwiftUI Image Cropper
//
//  Created by Jason Leocata on 20/10/20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var croppedImage: UIImage? = UIImage(named: "demo")
    
    @State private var scale: CGFloat = 1.0
    @State private var degrees: Double = 0
    @State private var offset = CGSize.zero
    
    
    var body: some View {
        VStack {
            CropperView(scale: $scale, degrees: $degrees, offset: $offset, image: $croppedImage)
            
            Button {
                save()
            } label: {
                Text("Convert to Image")
            }

        }
        
    }
    
    func save() {
        let image = CropperView(scale: $scale, degrees: $degrees, offset: $offset, image: $croppedImage).asUIImage()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CropperView: View {
    
    @Binding var scale: CGFloat
    @Binding var degrees: Double
    @Binding var offset : CGSize
    
    @Binding var image: UIImage?
    
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

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        // here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
