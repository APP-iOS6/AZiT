//
//  qwer.swift
//  Azit
//
//  Created by 김종혁 on 11/20/24.
//

import Foundation

//MARK: 서버로 메시지 알림 전송 (제목, 메시지, 토큰, 배지) & 공백으로 제목, 메시지 보낼 시 배지 업데이트
func sendNotificationToServer(myNickname: String, message: String, fcmToken: String, badge: Int) {
    // Node.js 서버 URL
    let url = URL(string: "https://deafening-delinda-bbell428-f7f2eaff.koyeb.app/send-notification")!
    
    // 요청 설정
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // 요청 본문 설정
    let payload: [String: Any] = [
        "title": myNickname,
        "body": message,
        "token": fcmToken,
        "badge": badge // 서버로 전달할 배지 값
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
    
    // HTTP 요청 실행
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
        
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("Response data: \(responseString)")
        }
    }
    task.resume()
}
