import Foundation
import Operations

class FromJsonToDictArrOperation: Operation {
    let inJson: DataWrapper
    let outJson: DataWrapper
    let key: String
   
    init(inJson: DataWrapper, outJson: DataWrapper, key: String) {
        self.inJson = inJson
        self.outJson = outJson
        self.key = key
        
        super.init()
        
        name = "FromJsonToDictArr"
    }
    
    override func execute() {
        guard let json = inJson.dict else {
            print("Nothing to select from dictionary (by key: \(self.key))")
            finish()
            return
        }
        
        self.outJson.dictArr = json[self.key] as? [[String: AnyObject]]
        
        finish()
    }
    
}
