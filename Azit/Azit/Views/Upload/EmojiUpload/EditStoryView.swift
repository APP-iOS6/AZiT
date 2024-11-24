//
//  EditStoryView.swift
//  Azit
//
//  Created by 홍지수 on 11/8/24.
//

import SwiftUI
//import EmojiPicker

struct EditStoryView : View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var locationManager: LocationManager
    
    @Binding var isDisplayEmojiPicker: Bool // MainView에서 전달받은 바인딩 변수
    @Binding var isMyModalPresented: Bool // 내 스토리에 대한 모달
  
    @State var publishedTargets: [String] = []
    @State var isShowingsheet: Bool = false
    @State var isPicture:Bool = false
    @State var firstNaviLinkActive = false
    @State private var isLimitExceeded: Bool = false
    @State private var scale: CGFloat = 0.1
    @State var friendID: String = ""
    private let characterLimit = 20
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    var isShareEnabled: Bool {
        return storyDraft.emoji.isEmpty && storyDraft.content.isEmpty
    }
    
    var body : some View{
        VStack {
            NavigationStack {
                // 상단 바
                HStack {
                    // 위치
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(Color.accentColor)
                        Text(storyDraft.address)
                            .font(.caption2)
                    }
                    Spacer()
                    
                    // 공개 범위
                    Button(action: {
                        isShowingsheet.toggle()
                        Task {
                            friendID = try await userInfoStore.getUserNameById(id: storyDraft.publishedTargets[0])
                        }
                    }) {
                        HStack {
                            Image(systemName: "person")
                            
                            if storyDraft.publishedTargets.count == userInfoStore.userInfo?.friends.count {
                                Text("ALL")
                            } else if storyDraft.publishedTargets.count == 1 {
                                Text("\(friendID)")
                            } else {
                                Text("\(friendID) 외 \(storyDraft.publishedTargets.count - 1)명")
                            }
                            
                            Text(">")
                        }
                        .font(.caption2)
                    }
                }
                .padding([.horizontal, .bottom])
                
                // 이모지피커 뷰 - 서치 바와 리스트
                EmojiPickerView(selectedEmoji: $storyDraft.emoji, searchEnabled: false,  selectedColor: Color.accent)
                    .background(Color.subColor4)
                
            }.frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height * 1.1 / 3)
                .padding(.bottom)
            
            // 메시지 입력
            TextField("상태 메시지를 입력하세요.", text: $storyDraft.content)
                .padding(.leading, 10)
                .frame(width: 340, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.subColor1, lineWidth: 0.5)
                        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)))
                )
                .padding(.bottom, 5)
                .onChange(of: storyDraft.content) { newValue in
                    if newValue.count >= characterLimit {
                        storyDraft.content = String(newValue.prefix(characterLimit))
                        isLimitExceeded = true
                    } else {
                        isLimitExceeded = false
                    }
                }
            
            if isLimitExceeded {
                Text("최대 20자까지 입력할 수 있습니다.")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            // 수정 완료 버튼
            Button (action:{
                isDisplayEmojiPicker = false
            }) {
                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                    .stroke(Color.accentColor, lineWidth: 0.5)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .fill(Color.white))
                    .frame(width: 340, height: 40)
                    .overlay(Text("수정 완료")
                        .padding(.bottom, 10)
                        .foregroundColor(Color.accentColor)
                    )
            }
        }
        .padding()
        .frame(width: (screenBounds?.width ?? 0) - 32, height: 500) // 팝업창 크기
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.subColor4)
                .shadow(radius: 10)
        )
        .sheet(isPresented: $isShowingsheet) {
            PublishScopeView()
                .presentationDetents([.medium, .large])
        }
        .onTapGesture {
            self.endTextEditing()
        }
        .contentShape(Rectangle()) // 전체 뷰가 터치 가능하도록 설정
        .scaleEffect(scale)
        .onAppear {
            if let location = locationManager.currentLocation {
                fetchAddress()
            } else {
                print("위치 정보가 아직 준비되지 않았습니다.")
            }
            // 공개 범위에 모두를 넣음
            storyDraft.publishedTargets = userInfoStore.userInfo?.friends ?? []
            
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 0.1
            }
        }
    }
    
    // 저장 후 초기화 함수
    func resetStory() {
//        storyDraft.id = ""
//        storyDraft.userId = ""
        storyDraft.likes = []
        storyDraft.latitude = 0.0
        storyDraft.longitude = 0.0
        storyDraft.address = ""
        storyDraft.emoji = ""
        storyDraft.image = ""
        storyDraft.content = ""
        storyDraft.publishedTargets = []
        storyDraft.readUsers = []
    }
    
    private func fetchAddress() {
        if let location = locationManager.currentLocation {
            reverseGeocode(location: location) { addr in
                storyDraft.address = addr ?? ""
            }
        } else {
            print("위치를 가져올 수 없습니다.")
        }
    }
}



