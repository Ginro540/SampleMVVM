//
//  TopViewModel.swift
//  SampleMVVM
//
//  Created by 古賀貴伍社用 on 2023/09/12.
//

import Foundation
import Combine

protocol TopViewModelInput {
    var fetchGetUsersTrigger: PassthroughSubject <Void, Never> { get }
    var fetchGetUserName:   PassthroughSubject <String, Never> { get }
    var fetchGetUserNames:   PassthroughSubject <String, Never> { get }
}

protocol TopViewModelOutput {
    var users: AnyPublisher<[User], Never> { get }
    var userName: AnyPublisher<String, Never> { get }
    var appData: AnyPublisher<[App]?, Never> { get }
}

final class TopViewModel: TopViewModelInput, TopViewModelOutput {

    var input:  TopViewModelInput { return self }
    var output: TopViewModelOutput { return self }
    
    // 発行者 Publisher イベントを発行する
    var fetchGetUsersTrigger = PassthroughSubject<Void, Never> ()
    var fetchGetUserName = PassthroughSubject<String, Never> ()
    var fetchGetUserNames = PassthroughSubject <String, Never> ()
    // @Published ObservableObjectプロトコルに準拠したクラス内のプロパティを監視し、
    // 変化があった際にViewに対して通知を行う
    @Published private var _users: [User] = []
    @Published private var _name: String = ""
    @Published private var _app: [App]? = nil
    
    private var cancellable: [AnyCancellable] = []

    var users: AnyPublisher<[User], Never> {
        return $_users.eraseToAnyPublisher()
    }
    
    var userName: AnyPublisher<String, Never> {
        return $_name.eraseToAnyPublisher()
    }
    
    var appData: AnyPublisher<[App]?, Never> {
        return $_app.eraseToAnyPublisher()
    }
    
    init(){
        // 発行者 Publisher
        fetchGetUsersTrigger
            // (購読)Subscribe
            .sink(
                receiveCompletion: {
                    print ("completion: \($0)")
                },
                receiveValue: { [weak self] in
                    self?.ferchUsers()
                }
            ).store(in: &cancellable)
        
        fetchGetUserName
            .sink(
                receiveValue: { [weak self] value in
                    self?._name = value
                }
            ).store(in: &cancellable)
        
        fetchGetUserNames
            .sink { completion in
                    print(completion)
            } receiveValue: { [weak self] value in
                self?._name = value
            }.store(in: &cancellable)
    }
    
    func getApp() {
        
        let appUrl = "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json"
        
        WebServiceManager.shared.getData(endpoint: appUrl, type: AppsResponse.self)
            .sink{ completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                }
            }receiveValue: { [weak self] appResponce in
                self?._app = appResponce.feed.results
            }.store(in: &cancellable)
    }
    
    func testAnyPublisher() -> AnyPublisher<User,APIError> {
            
        return Future<User, APIError> { promis in
            promis(.success(self.fetchUser(operation: { _ in
                
            })))
        }.eraseToAnyPublisher()
        
    }
    
    func testAnyPublisher2() -> AnyPublisher<User,APIError> {
        return Future<User, APIError> { promis in
            promis(.success(self.fetchUser2()))
        }.eraseToAnyPublisher()
        
    }
    
    private func fetchUser(operation: @escaping (User) -> Void) -> User{
        operation(User(name: "koga"))
        return User(name: "koga")
    }
    
    private func fetchUser2() -> User{
        return User(name: "koga")
    }

    private func ferchUsers() {
        print("ferchUsers 実行")
        let users: [User] = [.init(name: "勇次郎"),.init(name: "刃牙")]
        self._users = users
    }
    
    private func feachUser() async throws {
        let users: [User] = [.init(name: "勇次郎"),.init(name: "刃牙")]
        self._users = users
    }
    
    func first() -> AnyPublisher<Int, Error> {
        // 戻り値　Future 戻り値がString、Errorの場合はAPIErrorを返す
        return Future<Int, Error> { promis in
            promis(.success(1))
        }
        .eraseToAnyPublisher()
    }
    
    func second(num: Int) -> AnyPublisher<Int, Error> {
        // 戻り値　Future 戻り値がString、Errorの場合はAPIErrorを返す
        return Future<Int, Error> { promis in
            promis(.success(num + 1))
        }
        .eraseToAnyPublisher()
    }
    
    func third(num: Int) -> AnyPublisher<Int, Error> {
        // 戻り値　Future 戻り値がString、Errorの場合はAPIErrorを返す
        return Future<Int, Error> { promis in
            promis(.success(num + 1))
        }
        .eraseToAnyPublisher()
    }
    
    func publisherTest() {
        let myRange = (0...3)
        _ = myRange.publisher
            .sink(receiveCompletion: {
                print ("completion: \($0)")
            },
            receiveValue: { print ("value: \($0)") })
    }
}
