import Foundation
import Operations

class FromJsonToIntOperation: Operation {
    let inJson: DataWrapper
    let outJson: DataWrapper
    let key: String
   
    init(inJson: DataWrapper, outJson: DataWrapper, key: String) {
        self.inJson = inJson
        self.outJson = outJson
        self.key = key
        
        super.init()
        
        name = "From Json To Int Operation"
    }
    
    override func execute() {
        guard let json = inJson.dict else {
            print("Nothing to select from dictionary (by key: \(self.key))")
            finish()
            return
        }
        
        let intString = json[self.key] as? NSString
        self.outJson.intVal = intString?.integerValue
        
        finish()
    }
    
}
