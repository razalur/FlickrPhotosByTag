import UIKit
import CoreData
import Operations

class PhotosInfo: NSObject {
    dynamic var totalCount = 0
}

private var kvoContext = 0

class PhotosCollectionViewController: UICollectionViewController, UITextFieldDelegate {

    private dynamic let operationQueue = OperationQueue()
    private var photos = [Int : FlickrPhoto]()
    
    private let reuseIdentifier = "cell"
    private var searchText = ""
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    private let photosInfo = PhotosInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photosInfo.addObserver(self, forKeyPath: "totalCount", options: .New, context: &kvoContext)
        
        photos = grabPhotos()
        photosInfo.totalCount = photos.count
        
        self.collectionView?.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosInfo.totalCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = UIColor.whiteColor()
        
        // Photo is already loaded
        if let photo = photos[indexPath.row] {
            cell.imageView.image = photo.thumbnail
            
            print("Return cell for index:\(indexPath.row) (imageView)")
            return cell
        }
        
        cell.imageView.image = nil
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.frame = cell.bounds
        activityIndicator.startAnimating()
        
        cell.addSubview(activityIndicator)
        
        // Download information for this cell
        let data = DataWrapper()
        let photoObj = FlickrPhoto()
    
//        LogManager.severity = .Verbose
        
        let photoURL = getSearchURL(searchText, index: indexPath.row)
        let photoRequest = NSMutableURLRequest(URL: photoURL)
        
        let downloadData = DownloadDataOperation(request: photoRequest, dataWrapper: data)
        
        let photoDataToJson = FromDataToJsonOperation(dataObj: data, jsonObj: data)
        photoDataToJson.addDependency(downloadData)
        
        let getPhotosInfo = FromJsonToDictOperation(inJson: data, outJson: data, key: "photos")
        getPhotosInfo.addDependency(photoDataToJson)
        
        let getPhotoInfo = FromJsonToDictArrOperation(inJson: data, outJson: data, key: "photo")
        getPhotoInfo.addDependency(getPhotosInfo)
        
        let parsePhotoInfo = ParsePhotoInfoOperation(inJson: data, obj: photoObj)
        parsePhotoInfo.addDependency(getPhotoInfo)
        
        let data2 = DataWrapper()
        
        let downloadPhotoLocation = DonwloadPhotoLocationOperation(obj: photoObj, dataWrapper: data2)
        downloadPhotoLocation.addDependency(parsePhotoInfo)
        
        let locationDataToJson = FromDataToJsonOperation(dataObj: data2, jsonObj: data2)
        locationDataToJson.addDependency(downloadPhotoLocation)
        
        let getPhotoLocationInfo = FromJsonToDictOperation(inJson: data2, outJson: data2, key: "photo")
        getPhotoLocationInfo.addDependency(locationDataToJson)
        
        let getPhotoCoord = FromJsonToDictOperation(inJson: data2, outJson: data2, key: "location")
        getPhotoCoord.addDependency(getPhotoLocationInfo)

        let parseLocationInfo = ParseLocationInfoOperation(inJson: data2, obj: photoObj)
        parseLocationInfo.addDependency(getPhotoCoord)
        
        let setImage = BlockOperation {
//            print("Photo longitude: \(photoObj.longitude)")
//            print("Photo latitude: \(photoObj.latitude)")
            self.photos[indexPath.row] = photoObj
            cell.imageView.image = self.photos[indexPath.row]!.thumbnail
            
            self.savePhoto(photoObj)
            
            activityIndicator.removeFromSuperview()
        }
        setImage.addDependency(parseLocationInfo)
        
        operationQueue.addOperations([
            setImage,
            parseLocationInfo,
            getPhotoCoord,
            getPhotoLocationInfo,
            locationDataToJson,
            downloadPhotoLocation,
            parsePhotoInfo,
            getPhotoInfo,
            getPhotosInfo,
            photoDataToJson,
            downloadData
        ])
        
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard !textField.text!.isEmpty else {
            print("Search text is empty")
            return false
        }
        
        // Clear previous data
        photosInfo.totalCount = 0
        photos.removeAll()
        
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let coord = moc.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: Photo.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord!.executeRequest(deleteRequest, withContext: moc)
            
        } catch let error as NSError {
            print("Error while clearing CoreData. Description: \(error.localizedDescription)")
        }
        
        collectionView?.reloadData()
        
        searchText = textField.text!
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.frame = collectionView!.bounds
        activityIndicator.startAnimating()
        
        collectionView!.addSubview(activityIndicator)
        
        // Getting the photo's count
        let data = DataWrapper()
        
        let photosCountURL = getSearchURL(searchText)
        let photosCountRequest = NSMutableURLRequest(URL: photosCountURL)
        
        let downloadData = DownloadDataOperation(request: photosCountRequest, dataWrapper: data)
        
        let fromDataToJson = FromDataToJsonOperation(dataObj: data, jsonObj: data)
        fromDataToJson.addDependency(downloadData)
        
        let getPhotosInfo = FromJsonToDictOperation(inJson: data, outJson: data, key: "photos")
        getPhotosInfo.addDependency(fromDataToJson)
        
        let getPhotosCount = FromJsonToIntOperation(inJson: data, outJson: data, key: "total")
        getPhotosCount.addDependency(getPhotosInfo)
        
        let updateCollectionView = BlockOperation {
            
            if let photosCount = data.intVal {
                // This limit just for debug propose
                self.photosInfo.totalCount = min(photosCount, 100)
            }
            else {
                self.photosInfo.totalCount = 0
            }

            self.collectionView?.reloadData()
            activityIndicator.removeFromSuperview()
        }
        updateCollectionView.addDependency(getPhotosCount)
        
        operationQueue.addOperations([
            updateCollectionView,
            getPhotosCount,
            getPhotosInfo,
            fromDataToJson,
            downloadData
        ])
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let mapVC = segue.destinationViewController as! MapViewController
        
        mapVC.photos = self.photos
    }
    
    func grabPhotos() -> [Int : FlickrPhoto] {
        var photosDict = [Int : FlickrPhoto]()
        
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
        let photoRequest = NSFetchRequest(entityName: Photo.entityName)
        
        do {
            let photos: [Photo] = try moc.executeFetchRequest(photoRequest) as! [Photo]
            
            if photos.isEmpty {
                print("Photos dict from coredata is empty")
                return photosDict
            }
            
            for (index, element) in photos.enumerate() {
                let photo = FlickrPhoto()
                
                photo.photoID = element.photoID
                photo.farm = element.farm?.integerValue
                photo.secret = element.secret
                photo.server = element.server
                photo.latitude = (element.latitude?.doubleValue)!
                photo.longitude = (element.longitude?.doubleValue)!
                photo.thumbnail = UIImage(data: element.thumbnail!)
                
                photosDict[index] = photo
            }
            
        } catch let error as NSError! {
            print("Error while grabbing photos. Error description: \(error.localizedDescription)")
            return [Int : FlickrPhoto]()
        }
        
        return photosDict
    }
    
    func savePhoto(photoObj: FlickrPhoto) {
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        let entity =  NSEntityDescription.entityForName(Photo.entityName, inManagedObjectContext: moc)
        
        let photo = Photo(entity: entity!, insertIntoManagedObjectContext: moc)

        photo.photoID = photoObj.photoID
        photo.farm = photoObj.farm
        photo.secret = photoObj.secret
        photo.server = photoObj.server
        photo.latitude = photoObj.latitude
        photo.longitude = photoObj.longitude
        photo.thumbnail = UIImagePNGRepresentation(photoObj.thumbnail!)

        do {
            try moc.save()
        }
        catch let error as NSError  {
            print("Could not save \(error), \(error.localizedDescription)")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "totalCount" {
            guard let changesDict = change else {
                return
            }
            
            guard let photosCount = (changesDict["new"] as? Int) else {
                return
            }
            
            if photosCount > 0 {
                mapButton.enabled = true
            }
            else {
                mapButton.enabled = false
            }
        }
    }
}

