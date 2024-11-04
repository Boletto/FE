//
//  PhotoGridFeatureTests.swift
//  BoletoTests
//
//  Created by Sunho on 11/3/24.
//

import XCTest
import ComposableArchitecture

@testable import Boleto

final class PhotoGridFeatureTests: XCTestCase {
    func testUpdatePhotoSingleSuccess() async {
        var state = PhotoGridFeature.State(travelID: 1)
        state.selectedIndex = GridIndex(3)
        let testStore = await TestStore(initialState: state) {
            PhotoGridFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        await testStore.send(.updatePhoto(photoItem: .singlePhoto(.mock))) {
            $0.photos[state.selectedIndex!.row][state.selectedIndex!.col] = .singlePhoto(.mock)
        }
    }
    func testUpdatePhotoWhenFullSizeSuccess() async {
        var state = PhotoGridFeature.State(travelID: 1)
        state.selectedIndex = GridIndex(5)
        state.photos = [[.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock),nil]]
        let testStore = await TestStore(initialState: state) {
            PhotoGridFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        await testStore.send(.updatePhoto(photoItem: .singlePhoto(.mock))) {
            $0.photos[state.selectedIndex!.row][state.selectedIndex!.col] = .singlePhoto(.mock)
            $0.photos = [[.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock),.singlePhoto(.mock)], [nil,nil,nil,nil,nil,nil]]
        }
    }
    func testUpdatePhotoWithNewRowCreationSuccess() async {
        var state = PhotoGridFeature.State(travelID:2)
        state.selectedIndex = GridIndex(8)
        let testStore = await TestStore(initialState: state) {
            PhotoGridFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        await testStore.send(.updatePhoto(photoItem: .singlePhoto(.mock))) {
            $0.photos.append(Array(repeating: nil, count: 6))
            $0.photos[1][2] = .singlePhoto(.mock)
        }
    }
    func testAddPhotoTapped() async {
         let state = PhotoGridFeature.State(travelID: 1)
         let testStore = await TestStore(initialState: state) {
             PhotoGridFeature()
         } withDependencies: {
             $0.travelClient = .testValue
         }
         
         await testStore.send(.addPhotoTapped(GridIndex(0))) {
             $0.selectedIndex = GridIndex(0)
             $0.confirmationDialog = ConfirmationDialogState(titleVisibility: .visible) {
                 TextState("추가하기")
             } actions: {
                 ButtonState(action: .fourCutTapped){
                     TextState("네컷사진 추가")
                 }
                 ButtonState(action: .polaroidTapped) {
                     TextState("폴라로이드 사진 추가")
                 }
                 ButtonState(role:.cancel){
                     TextState("닫기")
                 }
             }
         }
     }
    
       func testDeletePhotoSuccess() async {
           var state = PhotoGridFeature.State(travelID: 1)
           state.selectedIndex = GridIndex(0)
           state.photos = [[.singlePhoto(.mock),nil,nil,nil,nil,nil]]
           
           let testStore = await TestStore(initialState: state) {
               PhotoGridFeature()
           } withDependencies: {
               $0.travelClient.deleteSinglePhoto = { _, _, _ in true }
           }
           
           await testStore.send(.deletePhoto)
           await testStore.receive(.successDelete) {
               $0.photos = [[nil,nil,nil,nil,nil,nil]]
           }
       }
    func testClickFullScreenImage() async {
           var state = PhotoGridFeature.State(travelID: 1)
           state.photos = [[.singlePhoto(.mock),nil,nil,nil,nil,nil]]
           
           let testStore = await TestStore(initialState: state) {
               PhotoGridFeature()
           } withDependencies: {
               $0.travelClient = .testValue
           }
           
           await testStore.send(.clickFullScreenImage(GridIndex(0))) {
               $0.selectedFullScreenItem = .singlePhoto(.mock)
               $0.selectedIndex = GridIndex(0)
           }
       }
    func testDismissFullScreenImage() async {
           var state = PhotoGridFeature.State(travelID: 1)
           state.selectedFullScreenItem = .singlePhoto(.mock)
           state.selectedIndex = GridIndex(0)
           
           let testStore = await TestStore(initialState: state) {
               PhotoGridFeature()
           } withDependencies: {
               $0.travelClient = .testValue
           }
           
           await testStore.send(.dismissFullScreenImage) {
               $0.selectedFullScreenItem = nil
               $0.selectedIndex = nil
           }
       }
    func testClickEditImage() async {
        let state = PhotoGridFeature.State(travelID: 1)
        
        let testStore = await TestStore(initialState: state) {
            PhotoGridFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        
        await testStore.send(.clickEditImage(GridIndex(0))) {
            $0.selectedIndex = GridIndex(0)
        }
    }
}
