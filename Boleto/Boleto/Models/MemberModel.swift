//
//  MemberModel.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import Foundation
struct MemberModel: Equatable, Identifiable {
    let id: Int
    let name: String
    let nickname :String
    let imageUrl: String?
}
extension MemberModel{
    static let mockSelf = MemberModel(id: 1, name: "선호", nickname: "선데이", imageUrl: nil)
       static let mockFriend = MemberModel(id: 2, name: "지우", nickname: "주주", imageUrl: nil)
       static let mockFamily = MemberModel(id: 3, name: "현우", nickname: "우디", imageUrl: nil)
       
    
    static let dummyList: [MemberModel] = [.init(id: 13, name: "현ㄷㅈㄹㅈㅂㄷ우", nickname: "woody", imageUrl: nil),
                                           .init(id: 15, name: "ㄹㅂㄷㅈㄹㄹㄷㅂ", nickname: "응짝", imageUrl: nil),
                                           .init(id: 17, name: "지ㅂㄹㄷㅈㄷㅈㄹ우", nickname: "주주주주베베베", imageUrl: nil),
                                           .init(id: 18, name: "선호ㄹㅂㄷㄷㅈㅂ", nickname: "개쩐다", imageUrl: nil)]
    
}
