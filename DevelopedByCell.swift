import UIKit

class DevelopedByCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(onClick))
        
        tapGesture.numberOfTapsRequired = 1
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        
    }
    
    func onClick(recognizer: UITapGestureRecognizer) {
        if let requestUrl = NSURL(string: "https://github.com/mazurio") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
