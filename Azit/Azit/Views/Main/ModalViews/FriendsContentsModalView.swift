//
//  FriendsContentsModalView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI
import AlertToast

struct FriendsContentsModalView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @Binding var message: String
    @Binding var selectedUserInfo: UserInfo
    
    @State var story: Story? = nil
    @State private var isLiked: Bool = false
    @State private var scale: CGFloat = 0.1
    
    @State private var showToast = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            ContentsModalTopView(story: $story, selectedUserInfo: selectedUserInfo)
            
            StoryContentsView(story: $story)
                        
            HStack {
                            ZStack(alignment: .trailing) {
                                TextField("message", text: $message, prompt: Text("\(selectedUserInfo.nickname)에게 메세지 보내기")
                                    .font(.caption))
                                .padding(3)
                                .padding(.leading, 10)
                                .frame(height: 30)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.accent, lineWidth: 1)
                                )
                                .onSubmit {
                                    sendMessage()
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if !message.isEmpty {
                                    sendMessage()
                                } else {
                                    isLiked.toggle()
                                }
                            }) {
                                Image(systemName: !message.isEmpty ? "paperplane.fill" : (isLiked ? "heart.fill" : "heart"))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.accent)
                                    .frame(width: 25, height: 25)
                            }
                        }
        }
        .toast(isPresenting: $showToast, alert: {
                    AlertToast(displayMode: .alert, type: .systemImage("envelope.open", Color.white), title: "전송 완료", style: .style(backgroundColor: .subColor1, titleColor: Color.white))
                })
        .padding()
        .background(.subColor4)
        .cornerRadius(8)
        .scaleEffect(scale)
        .onAppear {
            Task {
                // 선택 된 친구의 story
                if story == nil {
                    try await story = storyStore.loadRecentStoryById(id: selectedUserInfo.id)
                }
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
            }
            
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 0.1
            }
        }
        .frame(width: (screenBounds?.width ?? 0) - 32)
    }
    
    private func sendMessage() {
            Task {
                guard !message.isEmpty else { return }
                chatDetailViewStore.sendMessage(
                    text: message,
                    myId: userInfoStore.userInfo?.id ?? "",
                    friendId: story?.userId ?? "",
                    storyId: story?.id ?? ""
                )
                print("메시지 전송에 성공했습니다!")
                message = ""
                showToast.toggle()
            }
        }
}
