//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import BackgroundTasks
import AlertToast
import WidgetKit

struct MainView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @Environment(\.scenePhase) private var scenePhase
    
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
    @State private var isRightToLeftSwipe = false // 오른쪽에서 왼쪽 스와이프 여부
    @State private var isLeftToRightSwipe = false // 왼쪽에서 오른쪽 스와이프 여부
    
    @Binding var isClosedSwipe: Bool // 특정 화면으로 넘어가면 스와이프를 못하게 막음
    
    var body: some View {
        NavigationStack() {
            ZStack {
                // 메인 화면일 때 타원 뷰
                if isMainExposed {
                    RotationView(isMainExposed: $isMainExposed, isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours, isShowToast: $isShowToast, isClosedSwipe: $isClosedSwipe)
                        .frame(width: 300, height: 300)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isDisplayEmojiPicker ? 2 : 1)
                // 맵 화면일 때 맵 뷰
                } else {
                    MapView(isMainExposed: $isMainExposed, isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours, isShowToast: $isShowToast, isClosedSwipe: $isClosedSwipe)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isDisplayEmojiPicker ? 2 : 1)
                }
                
                // 메인 화면의 메뉴들
                MainTopView(isMainExposed: $isMainExposed, isShowToast: $isShowToast)
                    .zIndex(1)
            }
//            .navigationDestination(isPresented: $isRightToLeftSwipe) {
//                MessageView(isShowToast: $isShowToast)
//            }
//            .navigationDestination(isPresented: $isLeftToRightSwipe) {
//                MyPageView()
//            }
        }
        .toast(isPresenting: $isShowToast, alert: {
            AlertToast(displayMode: .banner(.pop), type: .systemImage("envelope.open", Color.white), title: "전송 완료", style: .style(backgroundColor: .subColor1, titleColor: Color.white))
        })
//        .gesture (
//            DragGesture()
//                .onEnded { value in
//                    if value.translation.width < -50 { // 왼쪽으로 드래그
//                        isRightToLeftSwipe = true
//                    }
//                    else if value.translation.width > 50 { // 오른쪽으로 드래그
//                        isLeftToRightSwipe = true
//                    }
//                }
//        )
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                userInfoStore.updateSharedUserDefaults(user: userInfoStore.userInfo!)
                WidgetCenter.shared.reloadTimelines(ofKind: "AzitWidget")
                print("background")
            case .active:
                print("active")
            case .inactive:
                print("inactive")
            @unknown default:
                break
            }
        }
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
