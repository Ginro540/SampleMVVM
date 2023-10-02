//
//  TopViewController.swift
//  SampleMVVM
//
//  Created by 古賀貴伍社用 on 2023/09/13.
//

import Foundation
import UIKit
import Combine

final class TopViewController: UIViewController {
    
    let viewModel = TopViewModel()
    private var cancellable: [AnyCancellable] = []
    
    @IBAction func detailButton(_ sender: Any) {
        viewModel.fetchGetUserName.send("koga")
        self.test()
        self.test()

    }
    
    @IBAction func sendButton(_ sender: Any) {
        viewModel.fetchGetUsersTrigger.send()
        viewModel.publisherTest()
    }
    
    @IBAction func actionButton(_ sender: Any) {
        viewModel.fetchGetUserNames.send("iikun")
        viewModel.getApp()
    }

    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.output.users
            .subscribe(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    print ("completion: \(completion)")
                },
                receiveValue: { [weak self] users in
                    self?.recive(value: users)
                }
            ).store(in: &cancellable)
        viewModel.output.userName
            .subscribe(on: DispatchQueue.main)
            .sink{ name in
                self.name.text = name
            }
            .store(in: &cancellable)
        viewModel.output.appData
            .subscribe(on: DispatchQueue.main)
            .sink{ appdata in
                guard appdata != nil else { return }
                print(appdata)
            }
            .store(in: &cancellable)
        
    }
    
    private func recive(value: [User]){
        
        
        
        
    }
    
    func test(){
        viewModel.first()
            .flatMap( { firstResult in self.viewModel.second(num: firstResult) })
            .flatMap( { secondResult in self.viewModel.third(num: secondResult) })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("success")
                case let .failure(error):
                    print("failare", error)
                }
            }, receiveValue: { result in
                print(result)
            })
            .store(in: &cancellable)
    }
}
