import Foundation

class RoutineStream {
    class var sharedInstance: RoutineStream {
        struct Static {
            static var instance: RoutineStream?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RoutineStream()
        }
        
        return Static.instance!
    }
    
    var routine: Routine
    
    init() {
        routine = PersistenceManager.getRoutine()
    }
}