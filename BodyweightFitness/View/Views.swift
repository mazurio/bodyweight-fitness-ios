import SnapKit

class TitleLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 20)
        self.textColor = UIColor.black
    }
}

class ValueLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 17)
        self.textColor = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1.00)
    }
    
    class func create(text: String) -> UILabel {
        let label = ValueLabel()
        label.text = text
        return label
    }
}

class DescriptionTextView: UITextView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 17)
        self.textColor = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1.00)
        self.isEditable = false
        self.isSelectable = false
        self.isScrollEnabled = false
    }
}

class CardButton: UIButton {
    // This is here only because we need to pass it to a selector method, maybe there is a better way?
    var repositoryRoutine: RepositoryRoutine?
    var repositoryExercise: RepositoryExercise?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.contentHorizontalAlignment = .left
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.setTitleColor(UIColor.primaryDark(), for: .normal)
    }
}

