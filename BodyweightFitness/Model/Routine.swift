import Foundation
import SwiftyJSON

enum RoutineType: Int {
    case Category
    case Section
    case Exercise
}

enum SectionMode: Int {
    case All
    case Pick
    case Levels
}

protocol LinkedRoutine: class {
    func getType() -> RoutineType
}

class Category: LinkedRoutine {
    let type: RoutineType = RoutineType.Category
    let title: String
    var sections: NSMutableArray = []
    
    init(title: String) {
        self.title = title
    }
    
    func getType() -> RoutineType {
        return type
    }
    
    func insertSection(section: Section) {
        sections.addObject(section)
    }
}

class Section: LinkedRoutine {
    let type: RoutineType = RoutineType.Section
    let mode: SectionMode
    let title: String
    let desc: String
    var category: Category?
    var currentExercise: Exercise?
    var exercises: NSMutableArray = []
    
    init(title: String, desc: String, mode: SectionMode) {
        self.title = title
        self.desc = desc
        self.mode = mode
    }
    
    func getType() -> RoutineType {
        return type
    }
    
    func insertExercise(exercise: Exercise) {
        exercises.addObject(exercise)
    }
}

class Exercise: LinkedRoutine {
    let type: RoutineType = RoutineType.Exercise
    let id: String
    let level: String
    let title: String
    let desc: String
    let youTubeId: String
    var category: Category?
    var section: Section?
    var previous: Exercise?
    var next: Exercise?
    
    init(id: String, level: String, title: String, desc: String, youTubeId: String) {
        self.id = id
        self.level = level
        self.title = title
        self.desc = desc
        self.youTubeId = youTubeId
    }
    
    func getType() -> RoutineType {
        return type
    }
}

class Routine {
    var categories: NSMutableArray = []
    var sections: NSMutableArray = []
    var exercises: NSMutableArray = []
    var categoriesAndSections: NSMutableArray = []
    var linkedExercises: NSMutableArray = []
    var linkedRoutine: NSMutableArray = []
    
    ///
    /// Parse JSON file.
    ///
    init(dictionary: Dictionary<String, String> = Dictionary<String, String>()) {
        let json = JSON(data: loadRoutineFromFile())
        
        var currentCategory: Category?
        var currentSection: Section?
        var currentExercise: Exercise?
        
        for(_, item):(String, JSON) in json["routine"] {
            switch item["type"] {
            case "category":
                let category = Category(title: item["title"].stringValue)
                
                categories.addObject(category)
                categoriesAndSections.addObject(category)
                linkedRoutine.addObject(category)
                
                currentCategory = category
            case "section":
                let section = Section(
                    title: item["title"].stringValue,
                    desc: item["description"].stringValue,
                    mode: getMode(item["mode"].stringValue))
                
                section.category = currentCategory
                
                sections.addObject(section)
                categoriesAndSections.addObject(section)
                linkedRoutine.addObject(section)
                
                currentSection = section
            case "exercise":
                let exercise = Exercise(
                    id: item["id"].stringValue,
                    level: item["level"].stringValue,
                    title: item["title"].stringValue,
                    desc: item["description"].stringValue,
                    youTubeId: item["youTubeId"].stringValue)

                exercise.category = currentCategory
                exercise.section = currentSection
                
                currentSection?.exercises.addObject(exercise)
                exercises.addObject(exercise)
                
                if(currentSection?.mode == SectionMode.Levels || currentSection?.mode == SectionMode.Pick) {
                    if let currentExerciseSaved = dictionary[currentSection!.title] as String? {
                        if(exercise.id == currentExerciseSaved) {
                            linkedExercises.addObject(exercise)
                            exercise.previous = currentExercise
                            currentExercise?.next = exercise
                            currentExercise = exercise
                            
                            currentSection?.currentExercise = exercise
                        }
                    } else {
                        if(currentSection?.exercises.count == 1) {
                            linkedExercises.addObject(exercise)
                            exercise.previous = currentExercise
                            currentExercise?.next = exercise
                            currentExercise = exercise
                            
                            currentSection?.currentExercise = exercise
                        }

                    }
                } else {
                    linkedExercises.addObject(exercise)
                    exercise.previous = currentExercise
                    currentExercise?.next = exercise
                    currentExercise = exercise
                }
                
                linkedRoutine.addObject(exercise)
            default:
                print("Unknown item in JSON File.")
            }
        }
    }
    
    ///
    /// Returns section mode from string.
    ///
    func getMode(mode: String) -> SectionMode {
        if(mode == "pick") {
            return SectionMode.Pick
        } else if(mode == "levels") {
            return SectionMode.Levels
        } else {
            return SectionMode.All
        }
    }
    
    ///
    /// Returns first exercise in the routine. 
    /// All exercises are linked together.
    ///
    func getFirstExercise() -> Exercise {
        return linkedExercises[0] as! Exercise
    }
    
    ///
    /// Set progression in given section.
    ///
    func setProgression(exercise: Exercise) {
        let currentSectionExercise = exercise.section?.currentExercise
        
        currentSectionExercise?.previous?.next = exercise
        currentSectionExercise?.next?.previous = exercise
        
        exercise.previous = currentSectionExercise?.previous
        exercise.next = currentSectionExercise?.next
        
        exercise.section?.currentExercise = exercise
    }
    
    ///
    /// Load JSON from file.
    ///
    func loadRoutineFromFile() -> NSData {
        let fileRoot = NSBundle.mainBundle().pathForResource("Routine", ofType: "json")!
        
        if let data: AnyObject = NSData.dataWithContentsOfMappedFile(fileRoot) {
            return data as! NSData
        } else {
            return NSData()
        }
    }
}
