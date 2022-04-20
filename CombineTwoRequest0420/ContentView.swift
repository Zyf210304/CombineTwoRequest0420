//
//  ContentView.swift
//  CombineTwoRequest0420
//
//  Created by 张亚飞 on 2022/4/20.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State var index: String = ""
    @StateObject var vm = ContentView.ViewModel()
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text(vm.errorMessage).bold()
            
            HStack{
                
                TextField("Input index...", text: $index)
                    .frame(width: 100)
                    .padding()
                    .keyboardType(.numberPad)
                    .background {
                        Color.gray.opacity(0.1)
                    }
                    .padding()
                
                Button {
                    
                    vm.getUserSubject.send(index)
                } label: {
                    
                    Text("Get User and Post")
                        .padding()
                }
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()

            }
            
            Text(vm.message).bold()
        }
    }
}

extension ContentView {
    
    class ViewModel: ObservableObject {
        
        @Published var message: String = ""
        @Published var errorMessage: String = ""
        
        var cancellables = Set<AnyCancellable>()
        var getUserSubject = PassthroughSubject<String, Never>()
        
        
        init() {
            
            getUserSubject
//                .flatMap{ NetworkService.shared.fetchUser(index: $0)}
                .map{ NetworkService.shared.fetchUser(index: $0)}
                .switchToLatest()
                .catch { error -> AnyPublisher<UserModel, Error> in
                    
                    Fail(error: error).eraseToAnyPublisher()
                }
                .flatMap { usermodel -> AnyPublisher<PostMode, Error> in
                    print("begin to fetch post")
                    return NetworkService.shared.fetchPost(index: String(usermodel.id))
                }
                .catch { error -> AnyPublisher<PostMode, Error> in
                    
                    Fail(error: error).eraseToAnyPublisher()
                }
                .receive(on: RunLoop.main)
                .sink { completion in
                    
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = (error as! NetworkError).description
                    default:
                        print(completion)
                    }
                } receiveValue: { [weak self] postModel in
                    self?.message = postModel.body
                }
                .store(in: &cancellables)
        }
        
        func beginTofetch() {
            
            
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
