//
//  MapViewController.swift
//  FlickrPhotosByTag
//
//  Created by Aleksey Razzhivaykin on 05.07.16.
//  Copyright © 2016 Aleksey Razzhivaykin. All rights reserved.
//

import UIKit
import GoogleMaps


class MapViewController: UIViewController {

    var photos: [Int : FlickrPhoto]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstPhotoLongitude = photos![1]!.longitude
        let firstPhotoLatitude = photos![1]!.latitude
        
        let camera = GMSCameraPosition.cameraWithLatitude(firstPhotoLatitude,
                                                        longitude: firstPhotoLongitude, zoom:1)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        for (_, photo) in photos! {
            
            print("id: \(photo.photoID!) longitude: \(photo.longitude) latitude: \(photo.latitude)")
            
            
            let photoMarker = GMSMarker()
            photoMarker.position = CLLocationCoordinate2DMake(photo.latitude, photo.longitude)
            
            photoMarker.appearAnimation = kGMSMarkerAnimationPop
            photoMarker.icon = photo.imageWithSize(CGSize(width: 50, height: 50))
            photoMarker.map = mapView
        }
        
        self.view = mapView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
