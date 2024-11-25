//
//  LoginSubView.swift
//  Azit
//
//  Created by 김종혁 on 11/2/24.
//

import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseAuth

enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
    case nickname
}

//MARK: 이메일 입력 필드
struct EmailTextField: View {
    var inputText: String
    @Binding var email: String
    @FocusState.Binding var focus: FocusableField?
    @Binding var isErrorEmail: Bool
    
    
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
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        focus == .email ? Color.accentColor : (isErrorEmail ? Color.red : Color.gray), lineWidth: 1
                    ) // 포커스에 따른 테두리 색상
                
            )
            .keyboardType(.emailAddress) // 키보드를 이메일 형식
    }
}

//MARK: 회원가입 이메일 입력 필드
struct SignUpEmailTextField: View {
    @EnvironmentObject var authManager: AuthManager
    var inputText: String
    @Binding var email: String
    @FocusState.Binding var focus: FocusableField?
    @Binding var selectedDomain: String?
    
    @Binding var isErrorEmail: Bool
    
    let domains = ["naver.com", "gmail.com", "icloud.com"]
    
    var body: some View {
        HStack {
            TextField("\(inputText)", text: $email)
                .font(.subheadline)
                .textInputAutocapitalization(.never) // 소문자로만 입력
                .disableAutocorrection(true)         // 자동 수정 비활성화
                .focused($focus, equals: .email)     // 이메일 포커스로 지정
                .onSubmit {
                    focus = .password                // 다음 포커스로 비밀번호 필드로 이동
                }
                .onChange(of: email) {
                    if email.contains("@") {
                        selectedDomain = nil // 입력하면서 @가 입력되면 선택 도메인 nil
                    } else {
                        selectedDomain = "naver.com"
                    }
                }
                .keyboardType(.emailAddress) // 키보드를 이메일 형식
            
            // '@' 이메일에 포함되지 않은 경우에만 메뉴 표시
            if !email.contains("@") {
                Menu {
                    ForEach(domains, id: \.self) { domain in
                        Button {
                            selectedDomain = domain
                        } label: {
                            Text(domain)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("@")
                            .foregroundStyle(Color.black)
                        Text(selectedDomain ?? "")
                            .foregroundColor(.accentColor)
                            .underline()
                        Image(systemName: "arrowtriangle.down.fill")
                            .padding(.top, 4)
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding()
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    focus == .email ? Color.accentColor : (isErrorEmail ? Color.red : Color.gray), lineWidth: 1
                ) // 포커스에 따른 테두리 색상
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
    
    @Binding var isErrorPassword: Bool
    
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
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    focus == focusType ? Color.accentColor : (isErrorPassword ? Color.red : Color.gray),
                    lineWidth: 1
                )
        )
    }
}

//MARK: 로그인 및 회원가입 버튼
struct LoginButton: View {
    var inputText: String   // 버튼의 텍스트
    var isLoading: Bool     // 로그인 중일 때 로딩 상태
    var isValid: Bool     // 입력 없으면 버튼 비활성
    var action: () -> Void
    
    @FocusState.Binding var focus: FocusableField?
    
    var body: some View {
        Button {
            focus = nil
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
        .cornerRadius(15)                 // 버튼 모서리를 둥글게 설정
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
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
        }
        .frame(width: 44, height: 44)
        .background(backColor)
        .clipShape(RoundedRectangle(cornerRadius: imageName == "GoogleLogo" ? 0 : 8))
    }
}

//MARK: 프로필 디테일
// 닉네임 입력 필드
struct NicknameTextField: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    
    var inputText: String
    @Binding var nickname: String
    
    @FocusState.Binding var focus: FocusableField?
    @Binding var isShowNickname: Bool
    @Binding var isNicknameExists: Bool
    
    var body: some View {
        TextField("\(inputText)", text: $nickname)
            .font(.subheadline)
            .focused($focus, equals: .nickname)
            .onSubmit {
                //
            }
            .padding()
            .cornerRadius(15)
            .multilineTextAlignment(.center)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(focus == .nickname ? Color.accentColor : Color.gray, lineWidth: 1) // 포커스에 따른 테두리 색상
            )
            .onChange(of: nickname) {
                // 특수문자와 공백을 제외한 문자열로 필터링
                let filteredNickname = nickname.filter { $0.isLetter || $0.isNumber }
                
                // 필터링된 결과로 업데이트
                if filteredNickname != nickname {
                    nickname = filteredNickname
                }
                
                // 한글 자음/모음만 입력된 경우 확인
                let hasSingleConsonantOrVowel = nickname.contains { char in
                    let scalar = char.unicodeScalars.first!
                    return (0x3131...0x318E).contains(scalar.value) // 한글 자음 및 모음 범위
                }
                
                // 닉네임 길이 조건에 따라 isShowNickname 설정
                if nickname.count > 0 && nickname.count < 9 && !hasSingleConsonantOrVowel {
                    Task {
                        if await userInfoStore.isNicknameExists(nickname) {
                            isShowNickname = false
                            isNicknameExists = true
                        } else {
                            isShowNickname = true
                            isNicknameExists = false
                        }
                    }
                } else {
                    isShowNickname = false
                }
            }
        
    }
}

// 프로필 디테일 뷰에서 시작하기 버튼
struct StartButton: View {
    var inputText: String   // 버튼의 텍스트
    var isLoading: Bool     // 로그인 중일 때 로딩 상태
    var isShowNickname: Bool     // 입력 없으면 버튼 비활성
    var isShowEmoji: Bool     // 이모지 없으면 버튼 비활성
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
        .disabled(!isShowNickname || !isShowEmoji)
        .buttonStyle(.borderedProminent)
        .cornerRadius(15)
    }
}

struct EmojiSheetView: View {
    @Binding var show: Bool
    @Binding var txt: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(self.getEmojiList(), id: \.self) { row in
                        HStack(spacing: 25) {
                            ForEach(row, id: \.self) { codePoint in
                                Button(action: {
                                    let emoji = String(UnicodeScalar(codePoint)!)
                                    self.txt = emoji // 이모지를 바인딩에 전달
                                }) {
                                    ZStack {
                                        if let scalar = UnicodeScalar(codePoint),
                                           scalar.properties.isEmoji {
                                            Text(String(scalar))
                                                .font(.system(size: 55))
                                                .frame(width: 70, height: 70)
                                                .background(txt == String(scalar) ? Color.accentColor.opacity(0.2) : Color.clear) // 선택 상태 배경색
                                                .cornerRadius(10)
                                        } else {
                                            Text("")
                                                .frame(width: 70, height: 70)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 40)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)
            .background(Color.white)
            .cornerRadius(25)
            
            Button(action: {
                self.show.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
    
    func getEmojiList() -> [[Int]] {
        var emojis: [[Int]] = []
        for i in stride(from: 0x1F601, to: 0x1F64F, by: 4) {
            var temp: [Int] = []
            for j in i...i+3 {
                temp.append(j)
            }
            emojis.append(temp)
        }
        return emojis
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
