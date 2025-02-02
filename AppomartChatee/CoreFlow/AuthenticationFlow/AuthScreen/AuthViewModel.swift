//
//  AuthViewModel.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 30/1/25.
//

import FirebaseAuth
import RxSwift
import RxCocoa
import FirebaseFirestore

class AuthViewModel {
    
    let username = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let authResult = PublishSubject<Bool>()
    let errorMessage = PublishSubject<String>()
    var isLogin = true
    
    private let disposeBag = DisposeBag()

    func login() {
        isLoading.accept(true)
        Auth.auth().signIn(withEmail: email.value, password: password.value) { [weak self] result, error in
            self?.isLoading.accept(false)
            if let error = error {
                self?.errorMessage.onNext(error.localizedDescription)
            } else {
                self?.authResult.onNext(true)
            }
        }
    }
    
    func register() {
        isLoading.accept(true)
        
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        usersCollection
            .whereField("username_lowercase", isEqualTo: username.value.lowercased())
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading.accept(false)
                    self.errorMessage.onNext("Error checking username: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    self.isLoading.accept(false)
                    self.errorMessage.onNext("Username already exists. Choose another.")
                    return
                }
                
                self.isLoading.accept(true)
                self.createFirebaseUser()
            }
    }

    private func saveUsername(userId: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "username": username.value,
            "username_lowercase": username.value.lowercased(),
            "email": email.value,
            "chats": [] as [String]
        ]

        db.collection("users").document(userId).setData(userData) { [weak self] error in
            if let error = error {
                self?.errorMessage.onNext("Failed to save user: \(error.localizedDescription)")
            } else {
                print("User saved successfully!")
            }
        }
    }
    
    private func createFirebaseUser() {
        isLoading.accept(true)

        Auth.auth().createUser(withEmail: email.value, password: password.value) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading.accept(false)

            if let error = error {
                self.errorMessage.onNext(error.localizedDescription)
            } else if let userId = result?.user.uid {
                self.saveUsername(userId: userId)
                self.authResult.onNext(true)
            }
        }
    }
}
