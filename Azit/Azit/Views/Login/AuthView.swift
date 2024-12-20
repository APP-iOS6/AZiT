//
//  AuthView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var locationManager: LocationManager
    
    @AppStorage("fcmToken") private var targetToken: String = ""
    
    @Binding var url: URL?
    
    var body: some View {
        VStack {
            // 로그인 상태에 따라 보이는 화면을 다르게 함
            switch authManager.authenticationState {
            case .splash:
                SplashView()
            case .unauthenticated, .authenticating:
                LoginView()
            case .authenticated:
                SwipeNavigationView(url: $url)
                    .environmentObject(authManager)
                    .environmentObject(userInfoStore)
                    .onAppear {
                        Task {
                            // 로그인 후, 해당 디바이스로 UserInfo에 토큰 저장
                            await userInfoStore.updateFCMToken(authManager.userID, fcmToken: targetToken)
                            
                            // 로그인 후, 메시지 개수 알림 배지로 표시
                            await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID))
                            
                            // 위치 권한 허용 check
                            locationManager.checkAuthorization()
                        }
                    }
            case .profileExist:
                ProfileDetailView()
            }
        }
    }
}

//#Preview {
//    AuthView()
//}
