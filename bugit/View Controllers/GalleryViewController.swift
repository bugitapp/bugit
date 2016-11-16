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
    
    let screenshotReuseIdentifier = String(describing: ScreenshotCollectionViewCell.self)
    let headerReuseIdentifier = String(describing: ScreenshotSectionHeaderView.self)
    let sectionInsets = UIEdgeInsets(top: 40.0, left: 12.0, bottom: 40.0, right: 12.0)
    let itemsPerRow: CGFloat = 2.0
    
    var screenshotAssets: [PHAsset] = []
    var screenshotAssetSectionsArray: [ScreenshotAssetSearchResults] = [] {  //photoSectionsArray
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
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: "Gallery", attributes: [
            NSFontAttributeName : UIFont(name: "SFUIText-Light", size: 21)!,
            NSForegroundColorAttributeName : UIColor.darkText
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: userDidAllowGalleryLoadNotification, object: nil, queue: OperationQueue.main) { (notif: Notification) in
            dlog("authorized for photos")
            self.fetchScreenshotAssets()
        }
        
        NotificationCenter.default.addObserver(forName: userDidDenyGalleryLoadNotification, object: nil, queue: OperationQueue.main) { (notif: Notification) in
            dlog("denied photos")
            self.showBasicAlert(title: "Problem", message: "Bugit cannot function without access to Photos. Pleae go to the Settings app and allow Bugit access to Photos.")
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
            
            if segueId == "GalleryEditorPushSegue" {
                
                let editorVc = segue.destination as! EditorViewController
                let screenshotAsset = sender as! ScreenshotAsset
                editorVc.screenshotAsset = screenshotAsset
                
            }
            
        }
    }
    
    
    func showBasicAlert(title: String, message: String) {
        
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            dlog("OK pressed")
        }
        alertVc.addAction(OKAction)
        
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
        var assetSearchResults: [ScreenshotAssetSearchResults] = []
        for (key, val) in dateAssetDict {
            
            let assetResults = ScreenshotAssetSearchResults()
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
        
        cell.backgroundColor = UIColor.white
        cell.photoImageView.image = nil
        let phasset = asset(for: indexPath)
        let image = synchronousImage(for: phasset, at: indexPath)
        cell.photoImageView.image = image
        
        
        
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
        let screenshotAsset = ScreenshotAsset()
        screenshotAsset.screenshotAsset = phasset
        screenshotAsset.screenshotImage = image
        
        self.performSegue(withIdentifier: "GalleryEditorPushSegue", sender: screenshotAsset)
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
        let widthPerItem = (availableWidth / itemsPerRow) - 2.0
        //dlog("indexPath: \(indexPath), totalPad: \(paddingSpace), availableWdith: \(availableWidth)")
        //dlog("indexPath: \(indexPath), width: \(widthPerItem)")
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

