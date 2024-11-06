//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct MainView: View {
    @State private var isMainExposed: Bool = true
    @State private var isModalPresented: Bool = false
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @State var isdisplayEmojiPicker: Bool = false
    @State var selectedEmoji: Emoji?
    @State private var message: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isMainExposed {
                    RotationView(isModalPresented: $isModalPresented, isdisplayEmojiPicker: $isdisplayEmojiPicker)
                        .frame(width: 300, height: 300)
                        .zIndex(isModalPresented ? 2 : 1)
                } else {
                    MapView()
                        .zIndex(1)
                }
                
                MainTopView(isModalPresented: $isModalPresented, isMainExposed: $isMainExposed)
                    .zIndex(1)
                
                if isdisplayEmojiPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isdisplayEmojiPicker = false // 배경 터치 시 닫기
                        }
                        .zIndex(2)
                    
                    EmojiView(message: $message, selectedEmoji: $selectedEmoji)
                        .zIndex(3)
                }
            }
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
            }
        }
    }
}

struct MainTopView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    @Binding var isModalPresented: Bool
    @Binding var isMainExposed: Bool
    
    var body: some View {
        VStack {
            HStack() {
                Text("AZiT")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .bold()
                    .padding()
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        // 게시글 리로드
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                    }
                    .disabled(isModalPresented ? true : false)
                    
                    Button {
                        // 앨범 리스트
                    } label: {
                        Image(systemName: "photo.stack")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    }
                    
                    NavigationLink {
                        MyPageView()
                    } label: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    }
                    
                }
                .padding()
            }
            .foregroundStyle(.accent)
            
            Spacer()
            
            HStack{
                NavigationLink {
                    MessageView()
                } label: {
                    Image(systemName: "ellipsis.message.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .padding()
                
                Spacer()
                
                Button {
                    isMainExposed.toggle()
                } label: {
                    Image(systemName: isMainExposed ? "map" : "house")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                }
                .padding()
            }
        }
        .frame(maxWidth: screenBounds?.width, maxHeight: screenBounds?.height)
    }
}

#Preview {
    //    AuthView()
    //        .environmentObject(AuthManager())
    //        .environmentObject(UserInfoStore())
    //        .environmentObject(ChatListStore())
    //        .environmentObject(ChatDetailViewStore())
    MainView()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
}
