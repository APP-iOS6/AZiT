//
//  PostMessage.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

// 보낸 메시지
struct PostMessage: View {
    @EnvironmentObject var authManager: AuthManager
    var chat: Chat
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .trailing) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .trailing) {
                        if !chat.readBy.contains(where: { $0 != authManager.userID }) {
                            // authManager.userID 외 다른 UID가 없을 경우 (상대방 uid가 없을때)
                            VStack {
                                Text("1") // 미읽음 표시
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.green)
                            }
                        }
                        
                        // 보낸 시간
                        Text(chat.formattedCreateAt)
                            .font(.caption2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                    }
                    
                    // 보낸 내용
                    Text(chat.message)
                        .font(.headline)
                        .foregroundStyle(Color.black.opacity(0.5))
                        .multilineTextAlignment(.trailing)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(15)
                        .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
                        .id(chat.id)
                }
                .frame(maxWidth: 300, alignment: .trailing)
            }
        }
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    PostMessage(chat: Chat(createAt: Date(), message: "안녕하세요! 반갑습니다 어서오세요 안녕하세요! 반갑습니다 어서오세요 \n새로운 줄입니다!", sender: "parkjunyoung", readBy: ["parkjunyoung"]))
}
