//
//  ChatRoomListView.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

// 메시지 채팅방 List View
struct ChatRoomListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var chatListStore: ChatListStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    
    @Binding var isShowToast: Bool
    
    @State private var dragOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 20) { // Divider로 구분하므로 spacing은 0으로 설정
                    ForEach(Array(chatListStore.chatRoomList.enumerated()), id: \.element.id) { index, chatroom in
                        // 다른 참가자 찾기
                        if let otherParticipantID = chatroom.participants.first(where: { $0 != authManager.userID }),
                           let friend = userInfoStore.friendInfo[otherParticipantID] {
                            
                            NavigationLink {
                                MessageDetailView(
                                    friend: friend,
                                    roomId: chatroom.roomId,
                                    nickname: friend.nickname,
                                    userId: friend.id,
                                    profileImageName: friend.profileImageName,
                                    isShowToast: $isShowToast
                                )
                            } label: {
                                HStack {
                                    // 프로필 이미지 원
                                    ZStack(alignment: .center) {
                                        Circle()
                                            .fill(Color.subColor4) // 색상 수정 가능
                                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                        
                                        Text(friend.profileImageName) // 프로필 이미지가 문자열로 설정된 경우
                                            .font(.largeTitle)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(alignment: .leading)
                                    .padding(.leading, 20)
                                    
                                    // 채팅 내용
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(friend.nickname) // 친구의 닉네임
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            
                                            Text(chatroom.formattedLastMessageAt) // 보내고 나서 지난 시간
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                        }
                                        
                                        // 메시지 길이가 12 보다 크다면 생략표시
                                        Text(chatroom.lastMessage.count > 15 ? "\(chatroom.lastMessage.prefix(15))..." : chatroom.lastMessage)
                                            .font(.subheadline)
                                            .fontWeight(.thin)
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                    
                                    // 읽지 않은 메시지 표시
                                    if let unreadCount = chatroom.unreadCount[authManager.userID], unreadCount > 0 {
                                        ZStack(alignment: .center) {
                                            Circle()
                                                .fill(Color.red) // 색상 수정 가능
                                                .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                                            
                                            Text("\(unreadCount)") // 프로필 이미지가 문자열로 설정된 경우
                                                .font(.subheadline)
                                                .foregroundStyle(.white)
                                        }
                                        //.frame(alignment: .trailing)
                                        .padding(.trailing, 30)
                                    }
                                }
                                .frame(height: geometry.size.height * 0.1)
                            }
                        }
                    }
                }
            }
        }
        .gesture(
            DragGesture()
//                .onEnded { value in
//                    if value.translation.width < -50 { // 왼쪽으로 드래그
//                        isRightToLeftSwipe = true
//                    }
//                    if value.translation.width > 50 { // 오른쪽으로 드래그
//                        dismiss()
//                    }
//                }
                .onChanged { value in
                    if value.translation.width > 0 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                    
                    dragOffset = 0
                }
        )
        .offset(x: dragOffset)
        .animation(.easeInOut, value: dragOffset)
    }
}
