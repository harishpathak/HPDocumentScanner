//
//  ViewController.m
//  CradScanner
//
//  Created by Harish Pathak on 5/11/16.
//  Copyright © 2018 ASPL. All rights reserved.
//

#import "HomeViewController.h"
#import "HPPDFImageConverter.h"
#import "DocumentListVC.h"
#import "FolderCollectionViewCell.h"
#import <Photos/Photos.h>
#import "CameraOverlay.h"
#import "FileHelper.h"

@interface HomeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *arrImages;
    NSMutableArray *arrFolders;
    UIImagePickerController *imagePickController;
    NSString *documentsDirectory;
    CameraOverlay *viewOverlay;
    BOOL singleModeOn;
    NSDateFormatter *dateFormatter;
}

@property(nonatomic , strong) PHFetchResult *assetsFetchResults;
@property(nonatomic , strong) PHCachingImageManager *imageManager;

@property (weak, nonatomic) IBOutlet UIButton *btnTakePic;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewImages;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIImageView *imgVwBGView;


@end

@implementation HomeViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    singleModeOn = NO;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yy hh:mm:ss";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CRMNEXT_FOLDERS/"];
    
    [FileHelper createDirectoryAtPath:documentsDirectory];
    
    arrImages = [NSMutableArray array];
    arrFolders = [NSMutableArray array];
    arrFolders = [FileHelper listFileAtPath:documentsDirectory];
    
    UINib *nib = [UINib nibWithNibName:@"FolderCollectionViewCell" bundle: nil];
    [_collectionViewImages registerNib:nib forCellWithReuseIdentifier:@"imageCell"];
    
    // Configure layout
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(150, 150)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    [self.collectionViewImages setCollectionViewLayout:self.flowLayout];
    self.collectionViewImages.bounces = YES;
    [self.collectionViewImages setShowsHorizontalScrollIndicator:NO];
    [self.collectionViewImages setShowsVerticalScrollIndicator:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.imgVwBGView.hidden = [arrFolders count]>0?YES:NO;
    [self.collectionViewImages reloadData];
}

#pragma mark - Custom Methods

- (IBAction)addPictureToFolder:(id)sender {
    
    [self openCamera];
    
}

-(void)openCamera{
    
    //Pick from Camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        imagePickController=[[UIImagePickerController alloc]init];
        imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickController.showsCameraControls = NO;
        imagePickController.delegate=self;
        
        // Add overlay view with custom button on it. Set frames to button as per your choice.
        viewOverlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] objectAtIndex:0];
        [viewOverlay.btnSingleMode addTarget:self action:@selector(takeSinglePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [viewOverlay.btnBatchMode addTarget:self action:@selector(takeBatchPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [viewOverlay.btnFinish addTarget:self action:@selector(finishTakingPhotos:) forControlEvents:UIControlEventTouchUpInside];
        [viewOverlay.btnBack addTarget:self action:@selector(cancelTakingPhotos:) forControlEvents:UIControlEventTouchUpInside];
        
        imagePickController.cameraOverlayView = viewOverlay;
        
        [self presentViewController:imagePickController animated:YES completion:nil];
    }else{
        NSLog(@"No camera hardware found...");
    }
}

#pragma mark - Camera Overlay Methods

-(void)takeSinglePhoto:(UIBarButtonItem *)sender{
    NSLog(@"take photo in single mode.");
    //Remove other pics if exists
    [arrImages removeAllObjects];
    [imagePickController takePicture];
    singleModeOn = YES;
}

-(void)takeBatchPhoto:(UIBarButtonItem *)sender{
    NSLog(@"take photos in batch mode.");
    [imagePickController takePicture];
}


-(void)finishTakingPhotos:(UIBarButtonItem *)sender{
    NSLog(@"Finish taking photos.");
    
    //Create a new project folder
    NSString *directoryName = [FileHelper getUniqueName:@"Doc_"];
    NSString *fileDirectoryPath = [documentsDirectory stringByAppendingPathComponent:directoryName];
    
    [FileHelper saveImagesToDirectory:arrImages andPath:fileDirectoryPath];
    //After saving remove all images from array
    [arrImages removeAllObjects];
    arrFolders = [FileHelper listFileAtPath:documentsDirectory];
    [_collectionViewImages reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelTakingPhotos:(UIBarButtonItem *)sender{
    NSLog(@"Cancel taking photos.");
    [arrImages removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePicker Methods

//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [arrImages addObject:image];
    //Thumbnail icon
    viewOverlay.imgVwPreview.image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
    viewOverlay.lblBadge.text = [NSString stringWithFormat:@"%ld",[arrImages count]];
    
    [_collectionViewImages reloadData];
    self.imgVwBGView.hidden = [arrImages count]>0?YES:NO;
    
    //Single mode
    if (singleModeOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
        singleModeOn = NO;
       
        //Create a new project folder
        NSString *directoryName = [FileHelper getUniqueName:@"Doc_"];
        NSString *fileDirectoryPath = [documentsDirectory stringByAppendingPathComponent:directoryName];
        
        [FileHelper saveImagesToDirectory:arrImages andPath:fileDirectoryPath];
        //After saving remove all images from array
        [arrImages removeAllObjects];
        arrFolders = [FileHelper listFileAtPath:documentsDirectory];
    }
    
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionView delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [arrFolders count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FolderCollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    if (cell) {
        
        //        cell.imageCell.image=[arrImages objectAtIndex:indexPath.row];
        cell.lblCount.text = [NSString stringWithFormat:@"%ld", [[FileHelper listFileAtPath:[documentsDirectory stringByAppendingPathComponent:[arrFolders objectAtIndex:indexPath.row]]] count]];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSDictionary* attrs = [fm attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:[arrFolders objectAtIndex:indexPath.row]] error:nil];
        
        if (attrs != nil) {
            NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
            NSLog(@"Date Created: %@", [date description]);
            cell.lblDateCreated.text = [dateFormatter stringFromDate:date];
        }
        else {
            NSLog(@"Not found");
        }
        
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *folderName = [arrFolders objectAtIndex:indexPath.row];
    NSString *fileDirectoryPath = [documentsDirectory stringByAppendingPathComponent:folderName];
    // Get reference to the destination view controller
    DocumentListVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentListVC"];
    // Pass any objects to the view controller here, like...
    [vc setFileDirectoryPath:fileDirectoryPath];
    vc.navigationController.navigationItem.title=@"Documents List";
    [self.navigationController pushViewController:vc animated:YES];
}


@end
