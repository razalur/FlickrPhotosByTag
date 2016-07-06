import Foundation
import Operations

class DonwloadPhotoLocationOperation: GroupOperation {
    let dataWrapper: DataWrapper
    let obj: FlickrPhoto
    
    init(obj: FlickrPhoto, dataWrapper: DataWrapper) {
        self.obj = obj
        self.dataWrapper = dataWrapper
        
        super.init(operations: [])
        name = "DownloadPhotoLocation"        
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=\(apiKey)&photo_id=\(self.obj.photoID!)&format=json&nojsoncallback=1"
        
        let URL = NSURL(string: URLString)!
        
        let request = NSMutableURLRequest(URL: URL)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            self.downloadFinished(data, response: response, error: error)
            self.finish()
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(url: request.URL!)
        taskOperation.addCondition(reachabilityCondition)
        
        addOperation(taskOperation)
        super.execute()
    }
    
    func downloadFinished(data: NSData?, response: NSURLResponse?, error: NSError?) {
        if let error = error {
            print("Can't download!")
            aggregateError(error)
        }
        else {
            self.dataWrapper.data!.appendData(data!)
            
            print("Success download")
            // Do nothing, and the operation will automatically finish.
        }
    }
}
