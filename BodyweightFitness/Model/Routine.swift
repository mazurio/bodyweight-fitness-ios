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
    let categoryId: String
    let type: RoutineType = RoutineType.Category
    let title: String
    var sections: NSMutableArray = []
    
    init(categoryId: String, title: String) {
        self.categoryId = categoryId
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
    let sectionId: String
    let type: RoutineType = RoutineType.Section
    let mode: SectionMode
    let title: String
    let desc: String
    var category: Category?
    var currentExercise: Exercise?
    var exercises: NSMutableArray = []
    
    init(sectionId: String, title: String, desc: String, mode: SectionMode) {
        self.sectionId = sectionId
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
    let exerciseId: String
    let level: String
    let title: String
    let desc: String
    let youTubeId: String
    let videoId: String
    let defaultSet: String
    var category: Category?
    var section: Section?
    var previous: Exercise?
    var next: Exercise?
    
    init(exerciseId: String, level: String, title: String, desc: String, youTubeId: String, videoId: String, defaultSet: String) {
        self.exerciseId = exerciseId
        self.level = level
        self.title = title
        self.desc = desc
        self.youTubeId = youTubeId
        self.videoId = videoId
        self.defaultSet = defaultSet
    }
    
    func getType() -> RoutineType {
        return type
    }
    
    func isTimed() -> Bool {
        return self.defaultSet == "timed"
    }
}

class Routine {
    var routineId: String = "routine0"
    var title: String = ""
    var subtitle: String = ""
    
    var categories: NSMutableArray = []
    var sections: NSMutableArray = []
    var exercises: NSMutableArray = []
    var categoriesAndSections: NSMutableArray = []
    var linkedExercises: NSMutableArray = []
    var linkedRoutine: NSMutableArray = []
    
    init(fileName: String) {
        let json = JSON(data: loadRoutineFromFile(fileName))
        
        self.routineId = json["routineId"].stringValue
        self.title = json["title"].stringValue
        self.subtitle = json["subtitle"].stringValue
        
        self.build(json)
    }
    
    init(fileName: String, dictionary: Dictionary<String, String>) {
        let json = JSON(data: loadRoutineFromFile(fileName))
        
        self.routineId = json["routineId"].stringValue
        self.title = json["title"].stringValue
        self.subtitle = json["subtitle"].stringValue
        
        self.build(json, dictionary: dictionary)
    }
    
    func build(json: JSON, dictionary: Dictionary<String, String> = Dictionary<String, String>()) {
        var currentCategory: Category?
        var currentSection: Section?
        var currentExercise: Exercise?
        
        for(_, item):(String, JSON) in json["routine"] {
            switch item["type"] {
            case "category":
                let category = Category(
                    categoryId: item["categoryId"].stringValue,
                    title: item["title"].stringValue)
                
                categories.addObject(category)
                categoriesAndSections.addObject(category)
                linkedRoutine.addObject(category)
                
                currentCategory = category
            case "section":
                let section = Section(
                    sectionId: item["sectionId"].stringValue,
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
                    exerciseId: item["exerciseId"].stringValue,
                    level: item["level"].stringValue,
                    title: item["title"].stringValue,
                    desc: item["description"].stringValue,
                    youTubeId: item["youTubeId"].stringValue,
                    videoId: item["videoId"].stringValue,
                    defaultSet: item["defaultSet"].stringValue)
                
                exercise.category = currentCategory
                exercise.section = currentSection
                
                currentSection?.exercises.addObject(exercise)
                exercises.addObject(exercise)
                
                if(currentSection?.mode == SectionMode.Levels || currentSection?.mode == SectionMode.Pick) {
                    if let currentExerciseSaved = dictionary[currentSection!.sectionId] as String? {
                        if(exercise.exerciseId == currentExerciseSaved) {
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
    
    func getMode(mode: String) -> SectionMode {
        if(mode == "pick") {
            return SectionMode.Pick
        } else if(mode == "levels") {
            return SectionMode.Levels
        } else {
            return SectionMode.All
        }
    }
    
    func getFirstExercise() -> Exercise {
        return linkedExercises[0] as! Exercise
    }

    func setProgression(exercise: Exercise) {
        let currentSectionExercise = exercise.section?.currentExercise
        
        currentSectionExercise?.previous?.next = exercise
        currentSectionExercise?.next?.previous = exercise
        
        exercise.previous = currentSectionExercise?.previous
        exercise.next = currentSectionExercise?.next
        
        exercise.section?.currentExercise = exercise
    }
    
    func loadRoutineFromFile(fileName: String) -> NSData {
        let fileRoot = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!

        do {
            return try NSData(contentsOfFile: fileRoot, options: .DataReadingMappedIfSafe)
        } catch _ {
            return NSData()
        }
    }
}
