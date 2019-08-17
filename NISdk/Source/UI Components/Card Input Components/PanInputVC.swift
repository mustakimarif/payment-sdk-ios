//
//  NIPanInput.swift
//  NISdk
//
//  Created by Johnny Peter on 16/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation

class PanInputVC: UIViewController, UITextFieldDelegate {
    let panTextField: UITextField = UITextField()
    
    @objc let onChangeText: onChangeTextClosure
    
    init(onChangeText: @escaping onChangeTextClosure) {
        self.onChangeText = onChangeText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPanFieldChange(textField: UITextField) {
        self.onChangeText(textField)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // return NO to not change text
//        return true
//    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        panTextField.placeholder = "Card Number"
        panTextField.text = ""
        panTextField.borderStyle = UITextField.BorderStyle.none
        panTextField.backgroundColor = .white
        panTextField.textColor = .black
        panTextField.delegate = self
        panTextField.addTarget(self, action: #selector(onPanFieldChange), for: .editingChanged)
        panTextField.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        
        let stackBackgroundView = UIView()
        stackBackgroundView.layoutIfNeeded()
        stackBackgroundView.addBorder(.bottom, color: UIColor(hexString: "#dbdbdc") , thickness: 1)

        let label = UILabel()
        label.text = "Number"
        
        let hStack = UIStackView(arrangedSubviews: [label, panTextField])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .fill
        hStack.spacing = 50
        
        view.addSubview(hStack)
        stackBackgroundView.pinAsBackground(to: hStack)
        hStack.anchor(top: nil,
                      leading: view.safeAreaLayoutGuide.leadingAnchor,
                      bottom: nil,
                      trailing: view.safeAreaLayoutGuide.trailingAnchor,
                      padding: .zero,
                      size: CGSize(width: 0, height: 60))
    }
}
