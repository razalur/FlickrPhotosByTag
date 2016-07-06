import Foundation

// Flickr key
let apiKey = "{your_key}"

class DataWrapper {
    var data: NSMutableData?
    var stringList: [String]?
    var dict: [String: AnyObject]?
    var dictArr: [[String: AnyObject]]?
    var intVal: Int?
    
    init() {
        self.data = NSMutableData()
    }
}

func getSearchURL(textForSearch: String, index: Int? = nil) -> NSURL {
    
    let expectedCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
    let escapedText = textForSearch.stringByAddingPercentEncodingWithAllowedCharacters(expectedCharSet)!
    
    // If we need to return page by index
    var pageNumStr = ""
    if index != nil {
        pageNumStr = String("&page=\(index! + 1)")
    }
    
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&tags=\(escapedText)&has_geo=1&per_page=1&format=json&nojsoncallback=1\(pageNumStr)"
    
    print("pic: \(URLString)")
    
    return NSURL(string: URLString)!
}