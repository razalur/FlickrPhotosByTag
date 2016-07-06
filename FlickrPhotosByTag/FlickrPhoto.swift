import Foundation
import UIKit

class FlickrPhoto {
    var photoID : String?
    var farm : Int?
    var server : String?
    var secret : String?
    
    var thumbnail : UIImage?
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    func imageWithSize(size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / thumbnail!.size.width;
        let aspectHeight:CGFloat = size.height / thumbnail!.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = thumbnail!.size.width * aspectRatio;
        scaledImageRect.size.height = thumbnail!.size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        thumbnail!.drawInRect(scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
}