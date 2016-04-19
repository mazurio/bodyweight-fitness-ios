import Foundation

public extension String {
    var NS: NSString { return (self as NSString) }
}

class PersistenceManager {
    class func getWeightUnit() -> String {
        let fileManager = NSFileManager.defaultManager()
        let directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.stringByAppendingPathComponent("weightUnit.archive")
        
        if(fileManager.fileExistsAtPath(dataFilePath)) {
            if let weightUnit = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath) as? String {
                return weightUnit
            }
        }
        
        return "kg"
    }
    
    class func setWeightUnit(weightUnit: String) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.stringByAppendingPathComponent("weightUnit.archive")
        
        NSKeyedArchiver.archiveRootObject(weightUnit, toFile: dataFilePath)
    }
    
    class func getTimer(id: String) -> Int {
        let fileManager = NSFileManager.defaultManager()
        let directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.stringByAppendingPathComponent("timer.\(id).archive")
        
        if(fileManager.fileExistsAtPath(dataFilePath)) {
            if let seconds = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath) as? Int {
                return seconds
            }
        }
        
        return 60
    }
    
    class func storeTimer(id: String, seconds: Int) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = directoryPath[0] 
        let dataFilePath = documentsDirectory.NS.stringByAppendingPathComponent("timer.\(id).archive")
        
        NSKeyedArchiver.archiveRootObject(seconds, toFile: dataFilePath)
    }
    
    class func getRoutine() -> Routine {
        let fileManager = NSFileManager.defaultManager()
        let directoryPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask,
            true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.stringByAppendingPathComponent("routine.archive")
        
        if(fileManager.fileExistsAtPath(dataFilePath)) {
            if let currentExercises = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath) as? Dictionary<String, String> {
                return Routine(dictionary: currentExercises)
            }
        }
        
        return Routine()
    }
    
    class func storeRoutine(routine: Routine) {
        let directoryPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask,
            true)
        let documentsDirectory = directoryPath[0]
        let dataFilePath = documentsDirectory.NS.stringByAppendingPathComponent("routine.archive")
        
        var currentExercises = Dictionary<String, String>()
        for anySection in routine.sections {
            if let section = anySection as? Section {
                if(section.mode == SectionMode.Pick || section.mode == SectionMode.Levels) {
                    currentExercises[section.title] = section.currentExercise?.id
                }
            }
        }
        
        NSKeyedArchiver.archiveRootObject(currentExercises, toFile: dataFilePath)
    }
}