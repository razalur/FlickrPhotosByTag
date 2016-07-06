import Foundation
import Operations

class ParsePhotoInfoOperation: Operation {
    let inJson: DataWrapper
    var obj: FlickrPhoto
   
    init(inJson: DataWrapper, obj: FlickrPhoto) {
        self.inJson = inJson
        self.obj = obj
        
        super.init()
        
        name = "ParsePhotoInfo"
    }
    
    override func execute() {
        guard let json = inJson.dictArr?.first else {
            print("Nothing to select from dictionary")
            cancel()
            return
        }
        
        let photoID = json["id"] as? String ?? ""
        let farm = json["farm"] as? Int ?? 0
        let server = json["server"] as? String ?? ""
        let secret = json["secret"] as? String ?? ""
        
        let size = "m"
        let imageUrlStr = "http://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg"
        let imageUrl = NSURL(string: imageUrlStr)!
        
        let imageData = NSData(contentsOfURL: imageUrl)

        self.obj.photoID = photoID
        self.obj.farm = farm
        self.obj.server = server
        self.obj.secret = secret
        self.obj.thumbnail = UIImage(data: imageData!)
        
        finish()
    }
    
}
