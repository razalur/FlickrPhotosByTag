import Foundation
import CoreData
import Operations

class FromDataToJsonOperation2: Operation {
    let dataObj: DataWrapper
    let jsonObj: DataWrapper
   
    init(dataObj: DataWrapper, jsonObj: DataWrapper) {
        self.dataObj = dataObj
        self.jsonObj = jsonObj
        
        super.init()
        
        name = "FromDataToJson2"
    }
    
    override func execute() {
        guard let data = self.dataObj.data else {
            print("Warning! Extract from data to dictionary, but data is nil")
            finish()
            return
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? [String:AnyObject]
            
            self.jsonObj.dict = json
            
        } catch let jsonError as NSError {
            print("Error while extraction from data to dictionary. Error description: \(jsonError.localizedDescription)")
            finish(jsonError)
            return
        }
        
        finish()
    }
    
}
