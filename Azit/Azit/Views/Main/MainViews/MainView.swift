//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import BackgroundTasks
import AlertToast

struct MainView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var isMainExposed: Bool = true // 메인 화면인지 맵 화면인지
    @State private var isMyModalPresented: Bool = false // 사용자 자신의 모달 컨트롤
    @State private var isFriendsModalPresented: Bool = false // 친구의 모달 컨트롤
    @State private var isDisplayEmojiPicker: Bool = false // 사용자 자신의 게시글 작성 모달 컨트롤
    @State private var isPassed24Hours: Bool = false // 사용자 자신의 게시글 작성 후 24시간에 대한 판별 여부
    @State private var scale: CGFloat = 0.1 // EmojiView 애니메이션
    @State private var isShowToast = false
    
    var body: some View {
        NavigationStack() {
            ZStack {
                // 메인 화면일 때 타원 뷰
                if isMainExposed {
                    RotationView(isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours, isShowToast: $isShowToast)
                        .frame(width: 300, height: 300)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isDisplayEmojiPicker ? 2 : 1)
                // 맵 화면일 때 맵 뷰
                } else {
                    MapView(isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours, isShowToast: $isShowToast)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isDisplayEmojiPicker ? 2 : 1)
                }
                
                // 메인 화면의 메뉴들
                MainTopView(isMainExposed: $isMainExposed, isShowToast: $isShowToast)
                    .zIndex(1)
            }
        }
        .toast(isPresenting: $isShowToast, alert: {
            AlertToast(displayMode: .banner(.pop), type: .systemImage("envelope.open", Color.white), title: "전송 완료", style: .style(backgroundColor: .subColor1, titleColor: Color.white))
        })
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
