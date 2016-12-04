//
//  GalleryViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import Photos


/*
 How to populate the Screenshots 'smart album':
 Run the simulator and take lots of screenshots (File->Take ScreenShot).
 Next, open the Photos app, select the Albums tab, and drag one screenshot taken earlier into the album main page,
 but not into one of the existing smart albums; the Screenshots 'smart' album will be created with one screenshot.
 Drag remaining screenshots into the Screenshots smart album.
 
 */


class GalleryViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var permissionView: UIView!
    @IBOutlet weak var permissionViewBottomConstraint: NSLayoutConstraint!
    
    let screenshotReuseIdentifier = String(describing: ScreenshotCollectionViewCell.self)
    let headerReuseIdentifier = String(describing: ScreenshotSectionHeaderView.self)
    let sectionInsets = UIEdgeInsets(top: 40.0, left: 12.0, bottom: 40.0, right: 12.0)
    let itemsPerRow: CGFloat = 2.0
    
    var screenshotAssets: [PHAsset] = []
    var screenshotAssetSectionsArray: [ScreenshotAssetSearchResultsModel] = [] {  //photoSectionsArray
        didSet {
            //dlog("b4 sort: \(screenshotAssetSectionsArray)")
            screenshotAssetSectionsArray.sort(by: >)
            //dlog("after sort: \(screenshotAssetSectionsArray)")
            self.photosCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dlog("in")
        //set in the appearance manager now
        //let titleLabel = UILabel()
        //let titleText = NSAttributedString(string: "Gallery", attributes: [
        //NSFontAttributeName : UIFont(name: "SFUIText-Light", size: 21)!])
        //titleLabel.attributedText = titleText
        //titleLabel.sizeToFit()
        //navigationItem.titleView = titleLabel
        
        navigationItem.title = "Screenshot Gallery"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(launchIntroGuide))
        
        if let willLaunchIntroGuide = UserDefaults.standard.value(forKey: "ud1_launch_intro_guide") as! Bool! {
            if willLaunchIntroGuide {
                UserDefaults.standard.set(false, forKey: "ud1_launch_intro_guide")
                launchIntroGuide()
            }
        }
    }
    
    func launchIntroGuide() {
        let storyboard = UIStoryboard(name: "IntroGuide", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"step1ViewController") 
        self.present(viewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: userDidAllowGalleryLoadNotification, object: nil, queue: OperationQueue.main) { (notif: Notification) in
            dlog("authorized for photos")
            self.hideOpenSettingsPanel()
            self.fetchScreenshotAssets()
        }
        
        NotificationCenter.default.addObserver(forName: userDidDenyGalleryLoadNotification, object: nil, queue: OperationQueue.main) { (notif: Notification) in
            dlog("denied photos")
            self.showOpenSettingsPanel()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        checkPhotoLibraryPermission()
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observer: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let segueId = segue.identifier {
            
            if segueId == "EditorSegue" {
                
                let editorVc = segue.destination as! EditorViewController
                let screenshotAsset = sender as! ScreenshotAssetModel
                editorVc.screenshotAssetModel = screenshotAsset
                
            }
            /*else if segueId == "GalleryGalleryDetailModalSegue" {
                
                let detailNavVc = segue.destination as! UINavigationController
                let screenshotAsset = sender as! ScreenshotAsset
                let detailVc = detailNavVc.viewControllers.first as! GalleryDetailViewController
                detailVc.screenshotAsset = screenshotAsset
                
            }
            */
        }
    }
    
    func showOpenSettingsPanel() {
        permissionView.isHidden = false
        permissionViewBottomConstraint.constant = 0.0
        
    }
    
    func hideOpenSettingsPanel() {
        permissionView.isHidden = true
        permissionViewBottomConstraint.constant = -permissionView.bounds.height

    }
    
    @IBAction func onOpenSettingsPressed(_ sender: AnyObject) {
        
        if let appSettingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(appSettingsUrl)
        }

        
    }
    
    func showBasicAlert(title: String, message: String) {
        
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            dlog("OK pressed")
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            if let appSettingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettingsUrl)
            }
        }
        
        alertVc.addAction(OKAction)
        alertVc.addAction(settingsAction)
        self.present(alertVc, animated: true)
        
    }

    func checkPhotoLibraryPermission() {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
        //handle authorized status
            dlog("authorized")
            NotificationCenter.default.post(name: userDidAllowGalleryLoadNotification, object: nil, userInfo: nil)
        
        case .notDetermined, .denied, .restricted:
            // ask for permissions
            dlog("asking")
            
            PHPhotoLibrary.requestAuthorization() { status in
                
                dlog("statusblock: \(status), thread: \(Thread.current)")
                
                switch status {
                    
                case .authorized:
                    dlog("authorized")
                    NotificationCenter.default.post(name: userDidAllowGalleryLoadNotification, object: nil, userInfo: nil)

                case .denied, .restricted:
                    dlog("denied")
                    NotificationCenter.default.post(name: userDidDenyGalleryLoadNotification, object: nil, userInfo: nil)

                case .notDetermined:
                    dlog("shouldn't happen, not ask asking again")
                }
            }
        }
    }
    
    func fetchScreenshotAssets() {
        
        
        let fetchOptions: PHFetchOptions? = nil
        let albumType: PHAssetCollectionType = .smartAlbum
        let albumSubType: PHAssetCollectionSubtype = .smartAlbumScreenshots
        
        
        /* junk: testing another album
         var fetchOptions: PHFetchOptions? = nil
         var albumType: PHAssetCollectionType = .smartAlbum
         var albumSubType: PHAssetCollectionSubtype = .smartAlbumScreenshots
         if Platform.isSimulator {
         let albumName = "Screenshots"  //make yr own album for testing.
         fetchOptions = PHFetchOptions()
         fetchOptions?.predicate = NSPredicate(format: "localizedTitle = %@", albumName)
         albumType = .album
         albumSubType = .any
         }
         */
        
        let collections: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubType, options: fetchOptions)
        
        let colCount = collections.count
        
        dlog("collectionCount: \(colCount)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var dateAssetDict: [String: [PHAsset]] = [:]
        
        for i in 0..<colCount {
            let collection: PHAssetCollection = collections.object(at: i)
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let photoAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: options)
            let assetCount = photoAssets.count
            dlog("collection: \(collection.localizedTitle) assetCount: \(assetCount)")
            
            
            for j in 0..<assetCount {
                
                let asset: PHAsset = photoAssets.object(at: j)
                //dlog("j: \(j) mediaType: \(asset.mediaType == .image ? "image" : "audio/video"), w: \(asset.pixelWidth), h: \(asset.pixelHeight), date: \(asset.creationDate)")
                screenshotAssets.append(asset)
                
                guard let assetDate = asset.creationDate else {
                    continue
                }
                let dateString = dateFormatter.string(from: assetDate)
                
                if var assetsOnDate = dateAssetDict[dateString] {
                    assetsOnDate.append(asset)
                    dateAssetDict[dateString] = assetsOnDate //copy semantics much?
                }
                else {
                    var assetsOnDate: [PHAsset] = []
                    assetsOnDate.append(asset)
                    dateAssetDict[dateString] = assetsOnDate
                }
            }
        }
        dlog("dateAssetDict: \(dateAssetDict.count)")
        var assetSearchResults: [ScreenshotAssetSearchResultsModel] = []
        for (key, val) in dateAssetDict {
            
            let assetResults = ScreenshotAssetSearchResultsModel()
            assetResults.creationDate = dateFormatter.date(from: key)!
            assetResults.screenShotAssets = val
            assetResults.titleString = key
            assetSearchResults.append(assetResults)
            
        }
        dlog("dateAssetSearchResults: \(assetSearchResults), thread: \(Thread.current)")
        screenshotAssetSectionsArray = assetSearchResults
        
    }

}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return screenshotAssetSectionsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshotAssetSectionsArray[section].screenShotAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ScreenshotSectionHeaderView
            headerView.headerLabel.text = screenshotAssetSectionsArray[indexPath.section].titleString
            return headerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: screenshotReuseIdentifier, for: indexPath) as! ScreenshotCollectionViewCell
        
        cell.photoImageView.image = nil
        let phasset = asset(for: indexPath)
        let image = synchronousImage(for: phasset, at: indexPath)
        cell.photoImageView.image = image
        cell.photoImageView.contentMode = .scaleAspectFit
        cell.photoImageView.backgroundColor = lightLightGrayThemeColor
       
        /*
        if let img = image {
            let aspect = img.size.height / img.size.width
            dlog("indexPath: \(indexPath) image h/w aspect: \(aspect)")
            let imageOrientation = img.imageOrientation
            switch imageOrientation {
            case .down, .up, .upMirrored, .downMirrored:
                dlog("indexPath: \(indexPath) image is Vertical: \(imageOrientation.rawValue)")
            
            case .left, .right, .leftMirrored, .rightMirrored:
                dlog("indexPath: \(indexPath) image is Horizontal: \(imageOrientation.rawValue)")

            }
        }
        */
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        //largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let phasset = asset(for: indexPath)
        let image = synchronousImage(for: phasset, at: indexPath)
        let screenshotAsset = ScreenshotAssetModel()
        screenshotAsset.screenshotAsset = phasset
        screenshotAsset.screenshotImage = image
        self.performSegue(withIdentifier: "EditorSegue", sender: screenshotAsset)
    }

    
    
    func asset(for indexPath: IndexPath) -> PHAsset {
        return screenshotAssetSectionsArray[indexPath.section].screenShotAssets[indexPath.row]
    }
    
    func synchronousImage(for asset: PHAsset, at indexPath: IndexPath) -> UIImage? {
        
        var image: UIImage? = nil
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
        
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .aspectFit,
                                  options: options) { (finalResult: UIImage?, metaDict: [AnyHashable : Any]?) in
                                      image = finalResult
                                      //dlog("setting image: \(image) for indexPath: \(indexPath), thread: \(Thread.current)")
                                    
        }
        return image
    }
    
}


extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = photosCollectionView.bounds.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow)
        //dlog("indexPath: \(indexPath), totalPad: \(paddingSpace), availableWdith: \(availableWidth)")
        //dlog("indexPath: \(indexPath), width: \(widthPerItem)")
        let heightPerItem = ((16.0 * widthPerItem) / 9.0)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

