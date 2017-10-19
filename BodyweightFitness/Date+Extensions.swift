import Foundation

extension Date {
    public var globalDescription: String {
        get {
            let month = dateFormattedStringWithFormat("MMMM", fromDate: self)
            let year = dateFormattedStringWithFormat("YYYY", fromDate: self)
            
            return "\(month) \(year)"
        }
    }
    
    public var commonDescription: String {
        get {
            let day = dateFormattedStringWithFormat("dd", fromDate: self)
            let month = dateFormattedStringWithFormat("MMMM", fromDate: self)
            let year = dateFormattedStringWithFormat("YYYY", fromDate: self)
            
            return "\(day) \(month) \(year)"
        }
    }
    
    func dateFormattedStringWithFormat(_ format: String, fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
}
