import UIKit

class DropdownViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let values = ["AUTH", "PREAUTH", "PURCHASE"]
    
    var dropdownButton: UIButton!
    var dropdownPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropdownButton = UIButton(type: .custom)
        dropdownButton.setTitle("Select", for: .normal)
        dropdownButton.setTitleColor(.black, for: .normal)
        dropdownButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        dropdownButton.addTarget(self, action: #selector(showDropdown), for: .touchUpInside)
        view.addSubview(dropdownButton)
        
        dropdownPicker = UIPickerView()
        dropdownPicker.dataSource = self
        dropdownPicker.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dropdownDone))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        let dropdownTextField = UITextField()
        dropdownTextField.inputView = dropdownPicker
        dropdownTextField.inputAccessoryView = toolbar
        view.addSubview(dropdownTextField)
    }
    
    @objc func showDropdown() {
        dropdownPicker.isHidden = false
    }
    
    @objc func dropdownDone() {
        dropdownPicker.isHidden = true
        view.endEditing(true)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = values[row]
        dropdownButton.setTitle(selectedValue, for: .normal)
    }
}
