//
//  ChatViewModel.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 1/2/25.
//

import FirebaseFirestore
import RxSwift
import RxCocoa

class ChatViewModel {
    
    let messages = BehaviorRelay<[MessageModel]>(value: [])
    let newMessage = PublishRelay<String>()
    
    private let chatId: String
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()

    init(chatId: String) {
        self.chatId = chatId
        observeMessages()
    }

    private func observeMessages() {
        db.collection("chats").document(chatId).collection("messages")
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else { return }
                
                let messages = snapshot.documents.compactMap { doc -> MessageModel? in
                    let data = doc.data()
                    return MessageModel(
                        senderId: data["senderId"] as? String ?? "",
                        text: data["text"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                self.messages.accept(messages)
            }
    }

    func sendMessage(text: String, senderId: String) {
        guard !text.isEmpty else { return }
        
        let messageData: [String: Any] = [
            "senderId": senderId,
            "text": text,
            "date": Timestamp(date: Date())
        ]
        
        let chatRef = db.collection("chats").document(chatId)
        
        chatRef.collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }

        chatRef.updateData([
            "lastMessage": text,
            "date": Timestamp(date: Date())
        ])
    }
}

