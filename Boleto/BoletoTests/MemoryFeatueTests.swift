import XCTest
import ComposableArchitecture

@testable import Boleto
//
//@MainActor
//final class MemoryFeatureTests: XCTestCase {
//    let store = TestStore(initialState: MemoryFeature.State(travelId: 1, ticketColor: .blue)) {
//        MemoryFeature()
//    } withDependencies: {
//        $0.travelClient = .testValue
//        $0.photoLibrary = .testValue
//    }
//    func testFetchMemory() async {
//    
//        await store.send(.fetchMemory)
//        await store.receive(.updateMemory([], [], [], false))
//    }
//    func testToggleLock() async throws {
//
//        await store.send(.changeEditMode)
//        await store.receive(.toggleLock) {
//            $0.editMode = true
//            $0.isLocked = true
//        }
//        await store.receive(.stickersAction(.unselectSticker))
//    }
//    
//    func testShowDeleteAlert() async {
//        
//        
//        await store.send(.showDeleteAlert) {
//            $0.alert = AlertState {
//                TextState("삭제")
//            } actions: {
//                ButtonState(role: .cancel) {
//                    TextState("Cancel")
//                }
//                ButtonState(action: .deleteButtonTapped) {
//                    TextState("삭제")
//                }
//            } message: {
//                TextState("이 사진을 삭제하시겠습니까?")
//            }
//        }
//    }
//    func testUpdateMemory() async {
//        await store.send(.updateMemory([FourCutModel.mock], [PhotoItem.mock], [Sticker.mock], true)) {
//            $0.photoGridState.photos = [[nil, .fourCut(FourCutModel.mock), nil,nil,nil,nil]]
//            $0.stickersState.stickers =  [Sticker.mock]
//            $0.isLocked = true
//        }
//    }
//    
//    func testCaptureGridContent() async {
//        await store.send(.captureGridContent(UIImage(systemName: "photo")!))
//        await store.receive(.issuccessSave(true)) {
//            $0.alert = AlertState(
//                title: TextState("저장 완료"),
//                message: TextState("성공적으로 갤러리에 저장되었습니다."),
//                dismissButton: .default(TextState("확인"))
//            )
//            
//        }
//    }
//    
//    
//
//}
