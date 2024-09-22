//
//  KeyChainManager.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation

class KeyChainManager {
    static let shared = KeyChainManager()
    enum TokenType {
        case accessToken
        case refreshToken
    }
    private init() {
        
    }
    func save(key: TokenType, token : String) {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        SecItemDelete(query)
    }
    func read(key: TokenType ) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data, let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            return nil
        }
    }
    func delete(key: TokenType) {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query)
    }
}
