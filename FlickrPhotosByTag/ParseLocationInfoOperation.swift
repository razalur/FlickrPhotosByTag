import Foundation
import Operations

class ParseLocationInfoOperation: Operation {
    let inJson: DataWrapper
    var obj: FlickrPhoto
   
    init(inJson: DataWrapper, obj: FlickrPhoto) {
        self.inJson = inJson
        self.obj = obj
        
        super.init()
        
        name = "ParseLocationInfo"
    }
    
    override func execute() {
        guard let json = inJson.dict else {
            print("Nothing to select from dictionary")
            finish()
            return
        }
        
        let latitude = (json["latitude"] as? NSString)!.doubleValue ?? 0.0
        let longitude = (json["longitude"] as? NSString)!.doubleValue ?? 0.0

        self.obj.latitude = latitude
        self.obj.longitude = longitude
        
        finish()
    }
    
}
