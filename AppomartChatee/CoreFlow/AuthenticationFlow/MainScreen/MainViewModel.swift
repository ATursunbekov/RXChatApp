//
//  MainViewModel.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 31/1/25.
//

import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseAuth

class MainViewModel {
    
    let chats = BehaviorRelay<[ChatModel]>(value: [])
    let errorMessage = PublishSubject<String>()
    
    private let disposeBag = DisposeBag()
    private let db = Firestore.firestore()
    
    func fetchChats() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage.onNext("User not authenticated.")
            return
        }

        db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage.onNext("Failed to fetch chats: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self?.errorMessage.onNext("No chats found.")
                    return
                }

                var chatsArray: [ChatModel] = []
                let group = DispatchGroup() 

                for document in documents {
                    let data = document.data()
                    let chatId = document.documentID
                    let participants = data["participants"] as? [String] ?? []

                    let otherUserId = participants.first { $0 != currentUserId } ?? "Unknown"

                    var chatName = "Unknown"

                    group.enter()
                    self?.db.collection("users").document(otherUserId).getDocument { userSnapshot, error in
                        if let userData = userSnapshot?.data(), let username = userData["username"] as? String {
                            chatName = username
                        }

                        group.leave()
                    }

                    let date: String
                    if let timestamp = data["date"] as? Timestamp {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        date = dateFormatter.string(from: timestamp.dateValue())
                    } else {
                        date = "Unknown"
                    }

                    group.notify(queue: .main) {
                        let chat = ChatModel(
                            id: chatId,
                            name: chatName,
                            lastMessage: data["lastMessage"] as? String ?? "",
                            date: date
                        )
                        chatsArray.append(chat)
                        self?.chats.accept(chatsArray)
                    }
                }
            }
    }
    
    func checkIfUsernameExists(username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        usersCollection.whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking username: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkIfChatExists(userId: String, otherUserId: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let chatsCollection = db.collection("chats")

        chatsCollection.whereField("participants", arrayContains: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking existing chat: \(error.localizedDescription)")
                completion(nil)
                return
            }

            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let participants = data["participants"] as? [String] ?? []
                
                if participants.contains(otherUserId) {
                    completion(document.documentID)
                    return
                }
            }
            completion(nil)
        }
    }

    
    func createChat(userId: String, otherUserId: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let chatsCollection = db.collection("chats")

        let newChatRef = chatsCollection.document()
        let chatId = newChatRef.documentID

        let chatData: [String: Any] = [
            "participants": [userId, otherUserId],
            "lastMessage": "",
            "date": Timestamp(date: Date()),
            "messages": []
        ]

        newChatRef.setData(chatData) { error in
            if let error = error {
                print("Error creating chat: \(error.localizedDescription)")
                completion(nil)
                return
            }

            let usersCollection = db.collection("users")

            usersCollection.document(userId).updateData([
                "chats": FieldValue.arrayUnion([chatId])
            ])
            
            usersCollection.document(otherUserId).updateData([
                "chats": FieldValue.arrayUnion([chatId])
            ])

            print("Chat created successfully with ID: \(chatId)")
            completion(chatId)
        }
    }

    func startChat(otherUsername: String, completion: @escaping (String?, String?) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        usersCollection.whereField("username_lowercase", isEqualTo: otherUsername.lowercased()).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking username: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }

            guard let snapshot = snapshot, let document = snapshot.documents.first else {
                print("User with username \(otherUsername) not found.")
                completion(nil, nil)
                return
            }

            let otherUserId = document.documentID

            self.checkIfChatExists(userId: currentUserId, otherUserId: otherUserId) { existingChatId in
                if let chatId = existingChatId {
                    print("Chat already exists with ID: \(chatId)")
                    completion(chatId, otherUsername)
                } else {
                    self.createChat(userId: currentUserId, otherUserId: otherUserId) { newChatId in
                        completion(newChatId, otherUsername)
                    }
                }
            }
        }
    }

}
