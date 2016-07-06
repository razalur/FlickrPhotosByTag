import Foundation
import Operations

class DownloadDataOperation: GroupOperation {
    let dataWrapper: DataWrapper
    let request: NSMutableURLRequest
    
    init(request: NSMutableURLRequest, dataWrapper: DataWrapper) {
        self.request = request
        self.dataWrapper = dataWrapper
        
        super.init(operations: [])
        name = "DownloadData"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            self.downloadFinished(data, response: response, error: error)
            self.finish()
        }

        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(url: request.URL!)
        taskOperation.addCondition(reachabilityCondition)
        
        self.addOperation(taskOperation)
    }
    
    func downloadFinished(data: NSData?, response: NSURLResponse?, error: NSError?) {
        if let error = error {
            print("Can't download! (url: \(self.request.URL))")
            aggregateError(error)
        }
        else {
            self.dataWrapper.data!.appendData(data!)
            
            print("Success download (url: \(self.request.URL!))")
            // Do nothing, and the operation will automatically finish.
        }
    }
}
