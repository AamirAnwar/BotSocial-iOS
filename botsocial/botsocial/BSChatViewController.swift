//
//  BSChatViewController.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
//import JSQSystemSoundPlayer

class BSChatViewController: JSQMessagesViewController {
    public var receiver:BSUser!
    var receiverID:String! {
        get {
            return self.receiver.id
        }
    }
    var messages:[JSQMessage] = []
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var senderAvatarImageSource = BSAvatarImageDataSource()
    var receiverAvatarImageSource = BSAvatarImageDataSource()
    private var localTyping = false // 2
    var userIsTypingRef:DatabaseReference?
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            if let ref = userIsTypingRef {
                ref.child(senderId).setValue(newValue)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        let size:CGFloat = 22
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.init(width:size , height: size)
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.init(width:size , height: size)
        self.senderAvatarImageSource.setImageWith(userID: self.senderId) {
            self.collectionView.reloadData()
        }
        self.receiverAvatarImageSource.setImageWith(userID: self.receiverID) {
            self.collectionView.reloadData()
        }
        
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        APIService.sharedInstance.isUserTyping(senderID: self.senderId, receiverID: self.receiverID, completion: { (ref) in
            self.userIsTypingRef = ref
            ref?.child(self.receiverID).observe(.value, with: { (snapshot) in
                if let value = snapshot.value as? Bool {
                    self.showTypingIndicator = value
                    self.scrollToBottom(animated: true)
                }
                
                print(snapshot)
            })
        })
    }
    
    private func observeMessages() {
        guard let user = APIService.sharedInstance.currentUser else {return}
        APIService.sharedInstance.getMessagesWith(senderID: user.uid, receiverID: receiverID) { (message) in
            if let message = message {
                self.addMessage(message: message)
                self.finishReceivingMessage()
            }
            
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return senderAvatarImageSource
        }
        return receiverAvatarImageSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    func addMessage(message:BSMessage) {
        self.addMessage(withId: message.senderID, name: message.senderName, text: message.text)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.inputToolbar.contentView.textView.text = ""
        APIService.sharedInstance.sendMessageTo(receiver: receiver, message: text) { (message) in
            JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
            self.finishSendingMessage() // 5
        }
        isTyping = false
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }


}
