//
//  chatInputAccessoryView.swift
//  apukendemo1
//
//  Created by 刈田修平 on 2020/12/29.
//

import Foundation
import UIKit

protocol ChatInputAccessoryViewDelegate: AnyObject {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
//
    @IBAction func tappedSendButton(_ sender: Any) {
        chatTextView.resignFirstResponder()
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    @IBAction func tappedCloseButton(_ sender: Any) {
        chatTextView.resignFirstResponder()
    }
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        sendButton.isEnabled = false
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        print(self)

        self.addSubview(view)
    }
    func tappedAroundKeyboard() {
        print("しまう")
        //        print(self)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    @objc func hideKeyboard() {
        chatTextView.resignFirstResponder()
//        chatTextView.endEditing(true)
    }
    
}

extension ChatInputAccessoryView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
//    func tappedAroundKeyboard() {
//        print("しまう")
//        print(self)
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tap.cancelsTouchesInView = false
//        tap.delegate = self
//        view.addGestureRecognizer(tap)
//    }
//    @objc func hideKeyboard() {
//        UIView.endEditing(true)
//    }

}
