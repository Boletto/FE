//
//  FeatureAction.swift
//  Boleto
//
//  Created by Sunho on 6/16/25.
//
import ComposableArchitecture

protocol FeatureAction {
    associatedtype UserAction      // 사용자 인터랙션
    associatedtype ExternalAction  // 외부 서비스 호출
    associatedtype InnerAction  // Reducer 내부 상태 변경
    
    static func user(_: UserAction) -> Self
    static func external(_: ExternalAction) -> Self
    static func inner(_: InnerAction) -> Self
}
