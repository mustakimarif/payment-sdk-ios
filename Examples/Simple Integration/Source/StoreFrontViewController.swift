//
//  StoreFrontViewController.swift
//  Simple Integration
//
//  Created by Johnny Peter on 22/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation
import UIKit
import NISdk
import PassKit

class StoreFrontViewController:
    UIViewController,
    UITextFieldDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    CardPaymentDelegate,
    StoreFrontDelegate,
    ApplePayDelegate {
    
    var collectionView: UICollectionView?
    let transactionTypeButton = UIButton(type: .system)
    var transactionTypePicker = UIPickerView()
    let orderTypeButton = UIButton(type: .system)
    var orderTypePicker = UIPickerView()
    let recurringTypeButton = UIButton(type: .system)
    var recurringTypePicker = UIPickerView()
    let frequencyButton = UIButton(type: .system)
    var frequencyPicker = UIPickerView()
    var numberOfTenureField = UITextField()
    let payButton = UIButton()
    
    let transactionTypes = ["AUTH", "SALE", "PURCHASE"]
    let orderTypes = ["SINGLE", "RECURRING","UNSCHEDULED"]
    let recurringTypes = ["FIXED", "VARIABLE"]
    let frequencies = ["HOURLY", "WEEKLY", "MONTHLY", "YEARLY"]
    
    var transactionType = "SALE"
    var orderType = "SINGLE"
    var recurringType: String? = nil
    var numberOfTenure: Int? = nil
    var frequency: String? = nil
    
    lazy var applePayButton = PKPaymentButton(paymentButtonType: .buy , paymentButtonStyle: .black)
    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 5
        return stack
    }()
    let payButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    let transactionAndOrderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    let recurringDetailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    let pets = ["🐊", "🐅", "🐆", "🦓", "🦏", "🦠", "🐙", "🐡", "🐋", "🐳"]
    var total: Double = 0 {
        didSet { showHideMainStack() }
    }
    var selectedItems: [Product] = []
    var paymentRequest: PKPaymentRequest?
    
    fileprivate func setupTransactionTypePicker() {
        transactionTypePicker.tag = 1
        transactionTypePicker.frame = CGRect(x: 50, y: 100, width: 200, height: 300)
        transactionTypePicker.delegate = self
        transactionTypePicker.dataSource = self
        transactionTypePicker.backgroundColor = .darkGray
        
        transactionTypeButton.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        transactionTypeButton.setTitle("Transaction Type", for: .normal)
        transactionTypeButton.addTarget(self, action: #selector(transactionTypeButtonTapped), for: .touchUpInside)
        transactionTypeButton.backgroundColor = .darkGray
        
        transactionTypePicker.isHidden = true
    }
    
    fileprivate func setupOrderTypePicker() {
        orderTypePicker.tag = 2
        orderTypePicker.delegate = self
        orderTypePicker.dataSource = self
        
        orderTypePicker.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        orderTypeButton.setTitle("Order Type", for: .normal)
        orderTypeButton.addTarget(self, action: #selector(orderTypeButtonTapped), for: .touchUpInside)
        orderTypeButton.backgroundColor = .darkGray
        
        orderTypePicker.isHidden = true
    }
    
    fileprivate func setupNumberOfTenureInput() {
        numberOfTenureField.text = ""
        numberOfTenureField.placeholder = "No of Tenure"
        numberOfTenureField.keyboardType = .numberPad
        numberOfTenureField.textAlignment = .center
        numberOfTenureField.backgroundColor = .darkGray
        numberOfTenureField.delegate = self
    }
    
    fileprivate func setupRecurringTypePicker() {
        recurringTypePicker.tag = 3
        recurringTypePicker.delegate = self
        recurringTypePicker.dataSource = self
        
        recurringTypePicker.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        recurringTypeButton.setTitle("Recurring Type", for: .normal)
        recurringTypeButton.addTarget(self, action: #selector(recurringTypeButtonTapped), for: .touchUpInside)
        recurringTypeButton.backgroundColor = .darkGray
        
        recurringTypePicker.isHidden = true
    }
    
    fileprivate func setupFrequencyPicker() {
        frequencyPicker.tag = 4
        frequencyPicker.delegate = self
        frequencyPicker.dataSource = self
        
        frequencyPicker.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        frequencyButton.setTitle("Frequency", for: .normal)
        frequencyButton.addTarget(self, action: #selector(frequencyButtonTapped), for: .touchUpInside)
        frequencyButton.backgroundColor = .darkGray
        
        frequencyPicker.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransactionTypePicker()
        setupOrderTypePicker()
        setupRecurringTypePicker()
        setupNumberOfTenureInput()
        setupFrequencyPicker()

        setupPaymentButtons()
        
        title = "Zoomoji Store"
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.register(ProductViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView?.delegate = self
        collectionView?.allowsSelection = true
        collectionView?.allowsMultipleSelection = true
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.white
        if #available(iOS 13, *) {
            collectionView?.backgroundColor = UIColor.systemBackground
        }
        view.addSubview(collectionView!)
    }
    
    func resetSelection() {
        total = 0
        selectedItems = []
        collectionView?.deselectAllItems(animated: true, resetHandler: {
            cell in
            if let cell = cell as! ProductViewCell? {
                cell.updateBorder(selected: false)
            }
        })
    }
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentDidComplete(with status: PaymentStatus) {
        if(status == .PaymentSuccess) {
            resetSelection()
            showAlertWith(title: "Payment Successfull", message: "Your Payment was successfull.")
            return
        } else if(status == .PaymentFailed) {
            showAlertWith(title: "Payment Failed", message: "Your Payment could not be completed.")
        } else if(status == .PaymentCancelled) {
            showAlertWith(title: "Payment Aborted", message: "You cancelled the payment request. You can try again!")
        }
    }
    
    @objc func authorizationDidComplete(with status: AuthorizationStatus) {
        if(status == .AuthFailed) {
            print("Auth Failed :(")
            return
        }
         print("Auth Passed :)")
    }
    
    @objc func didSelectPaymentMethod(paymentMethod: PKPaymentMethod) -> PKPaymentRequestPaymentMethodUpdate {
        if let paymentRequest = self.paymentRequest {
            return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }
        let summaryItem = [PKPaymentSummaryItem(label: "NGenius merchant", amount: NSDecimalNumber(value: 0))]
        return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: summaryItem)
    }
    
    @objc func transactionTypeButtonTapped() {
        transactionTypeButton.isHidden = true
        transactionTypePicker.isHidden = false
    }
    
    @objc func orderTypeButtonTapped() {
        orderTypeButton.isHidden = true
        orderTypePicker.isHidden = false
    }
    
    @objc func recurringTypeButtonTapped() {
        recurringTypeButton.isHidden = true
        recurringTypePicker.isHidden = false
    }
    
    
    @objc func frequencyButtonTapped() {
        frequencyButton.isHidden = true
        frequencyPicker.isHidden = false
    }
    
    @objc func payButtonTapped() {
        let orderCreationViewController = OrderCreationViewController(paymentAmount: total, cardPaymentDelegate: self, storeFrontDelegate: self, using: .Card, with: selectedItems, transactionType: transactionType,orderType: orderType,recurringType: recurringType,numberOfTenure: numberOfTenure, frequency: frequency)
        orderCreationViewController.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        orderCreationViewController.modalPresentationStyle = .overCurrentContext
        self.present(orderCreationViewController, animated: false, completion: nil)
    }

    @objc func applePayButtonTapped(applePayPaymentRequest: PKPaymentRequest) {
        let orderCreationViewController = OrderCreationViewController(paymentAmount: total, cardPaymentDelegate: self, storeFrontDelegate: self, using: .ApplePay, with: selectedItems, transactionType: transactionType,orderType: orderType,recurringType: recurringType,numberOfTenure: numberOfTenure, frequency: frequency)
        orderCreationViewController.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        orderCreationViewController.modalPresentationStyle = .overCurrentContext
        self.present(orderCreationViewController, animated: true, completion: nil)
    }
    
    // Used to update the paymentRequest object
    func updatePKPaymentRequestObject(paymentRequest: PKPaymentRequest) {
        self.paymentRequest = paymentRequest
    }
    
    func setupPaymentButtons() {
        
        configureButtonStack()
        configureTransactionAndOrderStack()
        configureRecurringDetailsStack()
        
        navigationController?.view.addSubview(mainStack)
        if let parentView = navigationController?.view {
            mainStack.translatesAutoresizingMaskIntoConstraints = false
            mainStack.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20).isActive = true
            mainStack.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20).isActive = true
            mainStack.heightAnchor.constraint(equalToConstant: 140).isActive = true
            mainStack.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -10).isActive = true
            mainStack.isHidden = true
        }
        
//        payButtonStack.translatesAutoresizingMaskIntoConstraints = false
//        payButtonStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 20).isActive = true
//        payButtonStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: 20).isActive = true

        
        mainStack.addArrangedSubview(payButtonStack)
        mainStack.addArrangedSubview(transactionAndOrderStack)
        mainStack.addArrangedSubview(recurringDetailsStack)
        recurringDetailsStack.isHidden = true
        
        // Pay button for card
        payButton.backgroundColor = .black
        payButton.setTitleColor(.white, for: .normal)
        payButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        payButton.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 0.6), for: .highlighted)
        payButton.setTitle("Pay", for: .normal)
        payButton.layer.cornerRadius = 5
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
//        buttonStack.anchor(top: 10, leading: 10, bottom: 10, trailing: 10)
        payButtonStack.addArrangedSubview(payButton)
        
        
        // Pay button for Apple Pay
        if(NISdk.sharedInstance.deviceSupportsApplePay()) {
            applePayButton.addTarget(self, action: #selector(applePayButtonTapped), for: .touchUpInside)
//            if let parentView = navigationController?.view {
//                applePayButton.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -50).isActive = true
//            }
            payButtonStack.addArrangedSubview(applePayButton)
        }
        
        transactionAndOrderStack.addArrangedSubview(transactionTypeButton)
        transactionAndOrderStack.addArrangedSubview(transactionTypePicker)
        transactionAndOrderStack.addArrangedSubview(orderTypeButton)
        transactionAndOrderStack.addArrangedSubview(orderTypePicker)
        
        recurringDetailsStack.addArrangedSubview(recurringTypeButton)
        recurringDetailsStack.addArrangedSubview(recurringTypePicker)
        recurringDetailsStack.addArrangedSubview(frequencyButton)
        recurringDetailsStack.addArrangedSubview(frequencyPicker)
        recurringDetailsStack.addArrangedSubview(numberOfTenureField)
    }
    
    func configureButtonStack() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.pinAsBackground(to: payButtonStack)
    }
    
    func configureTransactionAndOrderStack() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.pinAsBackground(to: transactionAndOrderStack)
    }
    
    func configureRecurringDetailsStack() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.pinAsBackground(to: recurringDetailsStack)
    }
    
    func showHideMainStack() {
        if(total > 0) {
            mainStack.isHidden = false
            payButton.setTitle("Pay Aed \(total)", for: .normal)
        } else {
            setupTransactionTypePicker()
            setupOrderTypePicker()
            setupRecurringTypePicker()
            setupNumberOfTenureInput()
            setupFrequencyPicker()
            mainStack.isHidden = true
        }
    }
    
    func add(amount: Double, emoji: String) {
        total += amount
        selectedItems.append(Product(name: emoji, amount: amount))
    }
    
    func remove(amount: Double, emoji: String) {
        total -= amount
        selectedItems = selectedItems.filter { $0.name != emoji}
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! ProductViewCell
        if cell.isSelected {
            cell.updateBorder(selected: true)
        } else {
            cell.updateBorder(selected: false)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductViewCell
        cell.isSelected = true
        cell.updateBorder(selected: true)
        add(amount: cell.price, emoji: cell.productLabel.text!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductViewCell
        cell.isSelected = false
        cell.updateBorder(selected: false)
        remove(amount: cell.price, emoji: cell.productLabel.text!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath) as! ProductViewCell
        
        cell.productLabel.text = pets[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let length = (screenWidth / 2) - 20
        return CGSize(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 80, right: 15)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) { return transactionTypes.count }
        else if (pickerView.tag == 2) { return orderTypes.count }
        else if (pickerView.tag == 3) { return recurringTypes.count }
        else {return frequencies.count }
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1) { return transactionTypes[row] }
        else if (pickerView.tag == 2) { return orderTypes[row] }
        else if (pickerView.tag == 3) { return recurringTypes[row] }
        else {return frequencies[row]}
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedValue: String!
        if (pickerView.tag == 1) {
            selectedValue = transactionTypes[row]
            transactionTypePicker.isHidden = true
            transactionTypeButton.backgroundColor = .black
            transactionTypeButton.setTitleColor(.white, for: .normal)
            transactionTypeButton.isHidden = false
            transactionType = selectedValue
            transactionTypeButton.setTitle(selectedValue, for: .normal)
            
        } else if (pickerView.tag == 2) {
            selectedValue = orderTypes[row]
            orderTypePicker.isHidden = true
            orderTypeButton.backgroundColor = .black
            orderTypeButton.setTitleColor(.white, for: .normal)
            orderTypeButton.isHidden = false
            orderType = selectedValue
            orderTypeButton.setTitle(selectedValue, for: .normal)
            if (selectedValue == "RECURRING") {
                print("enabling details")
                mainStack.heightAnchor.constraint(equalToConstant: 210).isActive = true
                recurringDetailsStack.isHidden = false
            } else {
                mainStack.heightAnchor.constraint(equalToConstant: 140).isActive = true
                recurringDetailsStack.isHidden = true
            }
        } else if (pickerView.tag == 3) {
            selectedValue = recurringTypes[row]
            recurringTypePicker.isHidden = true
            recurringTypeButton.backgroundColor = .black
            recurringTypeButton.setTitleColor(.white, for: .normal)
            recurringTypeButton.setTitle(selectedValue, for: .normal)
            recurringTypeButton.isHidden = false
            recurringType = selectedValue
            
            if (selectedValue == "UNSCHEDULED") {
                setupNumberOfTenureInput()
                setupFrequencyPicker()
                frequencyButton.isHidden = true
                numberOfTenureField.isHidden = true
            } else {
                frequencyButton.isHidden = false
                numberOfTenureField.isHidden = false
            }
        } else {
            selectedValue = frequencies[row]
            frequencyPicker.isHidden = true
            frequencyButton.backgroundColor = .black
            frequencyButton.setTitleColor(.white, for: .normal)
            frequencyButton.setTitle(selectedValue, for: .normal)
            frequencyButton.isHidden = false
            frequency = selectedValue
        }
        print("Selected Value: \(selectedValue ?? "")")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.backgroundColor = .black
        textField.textColor = .white
       
           // Get the numeric value from the text field
        let text  = textField.text
        if text != "" {
            numberOfTenure = Int(text!)
           } else {
              numberOfTenure = nil
           }
           return true
       }
}

protocol StoreFrontDelegate {
    func updatePKPaymentRequestObject(paymentRequest: PKPaymentRequest)
}
