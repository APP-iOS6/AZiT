//
//  RotationView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI
import EmojiPicker

struct RotationView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var isMyModalPresented: Bool // 사용자 자신의 모달 컨트롤
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var isDisplayEmojiPicker: Bool  // 사용자 자신의 게시글 작성 모달 컨트롤
    @Binding var isPassed24Hours: Bool // 사용자 자신의 게시글 작성 후 24시간에 대한 판별 여부
    
    @State private var rotation: Double = 270.0
    @State private var sortedUsers: [UserInfo] = [] // 거리 순 친구 정렬
    @State private var selectedIndex: Int = 0 // 선택 된 친구 스토리
    @State private var message: String = "" // 친구에게 보낼 메세지
    @State private var scale: CGFloat = 1.0 // 확대, 축소를 위한 스케일
    @State private var previousScale: CGFloat = 1.0 // 이전 스케일을 보존
    @State private var friendsStories: [Story] = [] // 친구들의 story
    @State private var numberOfCircles: Int = 0 // 친구 story 개수
    @State private var isShowAlert = false // QR로 앱 -> 알림 띄움 (친구추가)
    @State private var isShowYes = false // QR로 인해 친구추가 알림에서 Yes를 누를 경우
  
    var body: some View {
        ZStack {
            ZStack {
                // 사용자 본인의 Circle Button
                Button {
                    if isPassed24Hours {
                        isDisplayEmojiPicker = true
                    } else {
                        isMyModalPresented = true
                    }
                } label: {
                    MyContentEmojiView(isPassed24Hours: $isPassed24Hours, previousState: userInfoStore.userInfo?.previousState ?? "")
                }
                .zIndex(1)
                .offset(y: 250)
                // 타원 생성
                EllipsesView()
                
                // 친구들의 스토리 Circle
                if numberOfCircles > 0 {
                    ForEach(0..<numberOfCircles, id: \.self) { index in
                        let startEllipse = Constants.ellipses[3]
                        let endEllipse = Constants.ellipses[0]
                        let randomAngleOffset = Double.random(in: Constants.angles[index % 6].0..<Constants.angles[index % 6].1)
                        
                        let interpolationRatio: CGFloat = numberOfCircles > 1 ? CGFloat(index) / CGFloat(numberOfCircles - 1) : 0
                        
                        FriendsContentEmojiView(userInfo: $sortedUsers[index],
                                                rotation: $rotation,
                                                isFriendsModalPresented: $isFriendsModalPresented,
                                                selectedIndex: $selectedIndex,
                                                randomAngleOffset: randomAngleOffset,
                                                index: index,
                                                startEllipse: startEllipse,
                                                endEllipse: endEllipse,
                                                interpolationRatio: interpolationRatio)
                    }
                }
            }
            // 타원 위의 Circle들 각도 설정
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // 속도 설정 부
                        rotation += Double(value.translation.width) * 0.02
                    }
            )
            // 뷰의 크기 확대, 축소
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let newScale = previousScale * value
                        
                        if newScale > 0.3 && newScale < 2.0 {
                            scale = newScale
                        }
                    }
                    .onEnded { value in
                        previousScale = scale
                    }
            )
            .scaleEffect(scale)
            .padding()
            
            // Modal 분기
            ModalIdentificationView(isMyModalPresented: $isMyModalPresented,
                                    isFriendsModalPresented: $isFriendsModalPresented,
                                    isDisplayEmojiPicker: $isDisplayEmojiPicker,
                                    isPassed24Hours: $isPassed24Hours,
                                    users: $sortedUsers,
                                    message: $message,
                                    selectedIndex: $selectedIndex)
        }
        .onAppear {
            Task {
                // 사용자 본인의 정보 받아오기
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                // 사용자 본인의 친구 받아오기
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                
                var tempUsers: [UserInfo] = []
                // 스토리가 있는 친구들에서 공개가 되어있는지에 대한 분류
                for friend in userInfoStore.userInfo?.friends ?? [] {
                    do {
                        let tempStory = try await storyStore.loadRecentStoryById(id: friend)
                        
                        if tempStory.id != "" && (tempStory.publishedTargets.contains(userInfoStore.userInfo?.id ?? "") || tempStory.publishedTargets.isEmpty) {
                            try await tempUsers.append(userInfoStore.loadUsersInfoByEmail(userID: [friend])[0])
                        }
                    } catch { }
                }
                
                // 사용자 본인의 친구들을 거리를 바탕으로 정렬
                sortedUsers = Utility.sortUsersByDistance(from: userInfoStore.userInfo!, users: tempUsers)
                // 친구들의 최근 story 개수
                numberOfCircles = sortedUsers.count
                // 사용자 본인의 최근 story 불러오기
                let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                // 24시간이 지났는 지 판별
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("친구 추가"),
                message: Text("친구를 추가하겠습니까?"),
                primaryButton: .default(Text("Yes"), action: {
                    userInfoStore.addFriend(receivedUID: authManager.deepUserID, currentUserUID: authManager.userID)
                    authManager.deepUserID = ""
                    isShowYes = true
                }),
                secondaryButton: .cancel(Text("No"), action: {
                    authManager.deepUserID = "" // No 선택 시 deepUserID를 초기화하여 알림이 반복되지 않도록 함
                })
            )
        }
        .onChange(of: authManager.deepUserID) {
            Task {
                if !authManager.deepUserID.isEmpty {
                    isShowAlert = true
                }
                
                guard isShowYes else { return }
                
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                
                sortedUsers = try await Utility.sortUsersByDistance(from: userInfoStore.userInfo!, users: userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? []))
                numberOfCircles = userInfoStore.userInfo?.friends.count ?? 0 // 친구가 아니라 친구의 게시글이 numberOfCircle이 되어야 함
                
                let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
                
            }
        }
    }
}