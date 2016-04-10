import UIKit

class WeightUnitCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if PersistenceManager.getWeightUnit() == "lbs" {
            label.text = "Pounds (lbs)"
        } else {
            label.text = "Kilograms (kg)"
        }
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: "tapResponse:")
        
        tapGesture.numberOfTapsRequired = 1

        label.userInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
    }
    
    func tapResponse(recognizer: UITapGestureRecognizer) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(
            UIAlertAction(title: "Kilograms (kg)", style: .Default) { (action) in
                self.label.text = "Kilograms (kg)"
                
                PersistenceManager.setWeightUnit("kg")
            }
        )
        alertController.addAction(
            UIAlertAction(title: "Pounds (lbs)", style: .Default) { (action) in
                self.label.text = "Pounds (lbs)"
                
                PersistenceManager.setWeightUnit("lbs")
            }
        )
        
        appDelegate.settingsViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
