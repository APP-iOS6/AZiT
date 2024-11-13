//
//  CameraView.swift
//  Azit
//
//  Created by 홍지수 on 11/1/24.
//
import SwiftUI
import AVFoundation
import PhotosUI

struct TakePhotoView: View {
    @EnvironmentObject var cameraService : CameraService
    @State private var isPhotoTaken = false
    @State private var isGalleryPresented = false
    @Binding var firstNaviLinkActive: Bool
    @Binding var isMainDisplay: Bool // MainView에서 전달받은 바인딩 변수
    
    var body: some View {
        VStack {
            ProgressView(value: 1, total: 2)
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(x: 1, y: 3, anchor: .center)
                .frame(height: 10)
                .cornerRadius(6)
                .padding()
            
            CameraPreview(session: cameraService.session)
                .onAppear { cameraService.startSession() }
                .onDisappear { cameraService.stopSession() }
                .aspectRatio(3/4, contentMode: .fit)
            
            Spacer()
            
            HStack {
                Button(action: {
                    isGalleryPresented = true
                }) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                }
                .padding([.leading, .bottom])
                .sheet(isPresented: $isGalleryPresented) {
                    // 사진 가져와서 capturedImage에 담아야 함.
                    PhotoPicker(image: $cameraService.capturedImage)
                        .onChange(of: cameraService.capturedImage){
                            self.isPhotoTaken = true
                            print("HI")
                        }
                }
                
                Spacer()
                
                Button(action: {
                    cameraService.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 6)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .onReceive(cameraService.$capturedImage) { image in
                    if image != nil {
                        self.isPhotoTaken = true
                    }
                }
                Spacer()
                    Button(action: {}) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.clear)
                    }
                    .padding([.trailing, .bottom])
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
            
            NavigationLink(
                destination: PhotoReviewView(firstNaviLinkActive: $firstNaviLinkActive,isMainDisplay: $isMainDisplay , image: cameraService.capturedImage),
                isActive: $isPhotoTaken,
                label: { EmptyView() }
            )
            
        }
        .navigationBarTitle("사진 촬영", displayMode: .inline)
    }
}

//#Preview {
//    NavigationStack {
//        TakePhotoView()
//    }
//}
