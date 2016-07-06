import Foundation
import Operations

class FromJsonToDictOperation: Operation {
    let inJson: DataWrapper
    let outJson: DataWrapper
    let key: String
   
    init(inJson: DataWrapper, outJson: DataWrapper, key: String) {
        self.inJson = inJson
        self.outJson = outJson
        self.key = key
        
        super.init()
        
        name = "FromJsonToDict"
    }
    
    override func execute() {
        guard let json = inJson.dict else {
            print("Nothing to select from dictionary (by key: \(self.key))")
            finish()
            return
        }

        self.outJson.dict = json[self.key] as? Dictionary<String, AnyObject>
        
        finish()
    }
    
}
