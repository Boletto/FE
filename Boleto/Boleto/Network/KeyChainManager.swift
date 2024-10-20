//
//  KeyChainManager.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation

class KeyChainManager {
    static let shared = KeyChainManager()
    enum TokenType: String {
        case accessToken
        case refreshToken
        case id
        case deviceToken
    }
    private init() {
        
    }
    func save(key: TokenType, token : String) {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    func deleteAll() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        
        for itemClass in secItemClasses {
            let query: NSDictionary = [
                kSecClass: itemClass
            ]
            SecItemDelete(query)
        }
    }
    func read(key: TokenType ) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key.rawValue,
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
            kSecAttrAccount: key.rawValue
        ]
        SecItemDelete(query)
    }
}
