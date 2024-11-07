//
//  MapView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/6/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @State private var region = MKCoordinateRegion()
    @State var users: [UserInfo] = []
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: users) { user in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)) {
                    Button {
                        
                    } label: {
                        VStack {
                            Text(user.nickname)
                                .font(.caption)
                                .foregroundStyle(.black)
                                .padding(.top, max(-40, min(-20, -40 * (1.0 / (region.span.latitudeDelta * 12.5)))))
                                
                            
                            ZStack {
                                Circle()
                                    .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
                                                         center: .center,
                                                         startRadius: 0,
                                                         endRadius: 20))
                                
                                Circle()
                                    .fill(.white.opacity(0.7))
                                    .overlay(
                                        ZStack {
                                            Circle()
                                                .stroke(.accent, lineWidth: 3)
                                            Text(user.previousState)
                                                .font(.system(size: 45))
                                        }
                                    )
                                    .offset(x: 0, y: -30)
                                    .frame(width: 60, height: 60)
                            }
                            .scaleEffect(max(0.5, min(1.0, 1.0 / (region.span.latitudeDelta * 12.5))))
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                if users.isEmpty {
                    await userInfoStore.loadUserInfo(userID: authManager.userID)
                    userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                    
                    users = try await userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? [])
                    
                    let userLat = userInfoStore.userInfo?.latitude ?? 0
                    let userLng = userInfoStore.userInfo?.longitude ?? 0
                    
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: userLat,
                            longitude: userLng
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
        .onDisappear {
            users = []
        }
    }
}

#Preview {
    MapView()
}
