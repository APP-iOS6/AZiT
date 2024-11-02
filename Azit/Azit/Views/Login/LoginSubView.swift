//
//  LoginSubView.swift
//  Azit
//
//  Created by 김종혁 on 11/2/24.
//

import Foundation
import SwiftUI

enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

//MARK: 이메일 입력 필드
struct EmailTextField: View {
    var inputText: String
    @Binding var email: String
    @FocusState.Binding var focus: FocusableField?
    
    var body: some View {
        TextField("\(inputText)", text: $email)
            .font(.subheadline)
            .textInputAutocapitalization(.never) // 소문자로만 입력
            .disableAutocorrection(true)         // 자동 수정 비활성화
            .focused($focus, equals: .email)     // 이메일 포커스로 지정
            .onSubmit {
                focus = .password                // 다음 포커스로 비밀번호 필드로 이동
            }
            .padding()
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(focus == .email ? Color.accentColor : Color.black, lineWidth: 1) // 포커스에 따른 테두리 색상
            )
    }
}

//MARK: 비밀번호 입력 필드
struct PasswordTextField: View {
    @EnvironmentObject var authManager: AuthManager
    
    var inputText: String
    @Binding var password: String
    @FocusState.Binding var focus: FocusableField?
    var focusType: FocusableField   // 패스워드 혹은 패스워드 확인인지 파악하기 위해
    @State private var isPassword = false    // 비밀번호 보임/숨김
    var onSubmit: () -> Void
    
    
    var body: some View {
        HStack {
            if isPassword {
                TextField("\(inputText)", text: $password)
            } else {
                SecureField("\(inputText)", text: $password)
            }
            
            // 비밀번호 보임/숨김 아이콘 버튼
            Button {
                isPassword.toggle() // 아이콘 클릭 시 보임/숨김 상태 전환
            } label: {
                Image(systemName: isPassword ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .font(.subheadline)
        .focused($focus, equals: focusType) // 포커스를 비밀번호 필드로
        .onSubmit {
            onSubmit() // Submit 누르면 로그인 시도
        }
        .padding()
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(focus == focusType ? Color.accentColor : Color.black, lineWidth: 1)
        )
    }
}

//MARK: 로그인 및 회원가입 버튼
struct LoginButton: View {
    var inputText: String   // 버튼의 텍스트
    var isLoading: Bool     // 로그인 중일 때 로딩 상태
    var isValid: Bool     // 입력 없으면 버튼 비활성
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity) // 버튼 형식은 텍스트필드와 달리 가로가 전체로 먹지 않아서 사용
            } else {
                Text(inputText)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(!isValid)             // isEnabled가 false일 경우 버튼 비활성화
        .buttonStyle(.borderedProminent)  // 강조된 버튼 스타일 적용
        .cornerRadius(20)                 // 버튼 모서리를 둥글게 설정
    }
}

//MARK: 간편로그인버튼
struct SignInButton: View {
    var imageName: String
    var backColor: Color
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image("\(imageName)")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(10)
        }
        .background(backColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

//MARK: 텍스트필드 제외하고 빈 곳 터치하면 키보드 내리기
extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
