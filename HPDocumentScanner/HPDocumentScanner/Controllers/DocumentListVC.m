//
//  PDFListViewController.m
//  CradScanner
//
//  Created by Harish Pathak on 5/12/16.
//  Copyright © 2018 ASPL. All rights reserved.
//

#import "DocumentListVC.h"
#import "FileHelper.h"
#import "CameraOverlay.h"

#define kPadding 20

@interface DocumentListVC ()<UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    CGSize pageSize;
    BOOL isSelectionOn;
    UIImagePickerController *imagePickController;
    BOOL singleModeOn;
    CameraOverlay *viewOverlay;
    NSMutableArray *arrImages;
}

@end

@implementation DocumentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageSize = CGSizeMake(680, 930);
    [self setArrListContent:[NSMutableArray arrayWithArray:[FileHelper listFileAtPath:self.fileDirectoryPath]]];
    self.arrSelectedContent = [NSMutableArray array];
    arrImages = [NSMutableArray array];
    singleModeOn = NO;
    isSelectionOn = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"select" style:UIBarButtonItemStylePlain target:self action:@selector(selectRows:)];
    
    
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.arrListContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    UIImageView *imgThumb = [cell viewWithTag:101];
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[_fileDirectoryPath stringByAppendingPathComponent:[_arrListContent objectAtIndex:indexPath.row]]]];
    UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
    if (!thumbNail) {
        imgThumb.image = [UIImage imageNamed:@"pdf_icon.png"];
    }else{
        imgThumb.image = thumbNail;
    }
    
    //Selection/Deselection
    if ([self.arrSelectedContent containsObject:[self.arrListContent objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UILabel *lblName = [cell viewWithTag:102];
    lblName.text = [_arrListContent objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isSelectionOn) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (![self.arrSelectedContent containsObject:[self.arrListContent objectAtIndex:indexPath.row]]) {
            [self.arrSelectedContent addObject:[self.arrListContent objectAtIndex:indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            [self.arrSelectedContent removeObject:[self.arrListContent objectAtIndex:indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else{
     
        NSURL *URL = [NSURL fileURLWithPath:[_fileDirectoryPath stringByAppendingPathComponent:[_arrListContent objectAtIndex:indexPath.row]]];
        if (URL) {
            // Initialize Document Interaction Controller
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
            // Configure Document Interaction Controller
            [self.documentInteractionController setDelegate:self];
            // Preview PDF
            [self.documentInteractionController presentPreviewAnimated:YES];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *fileName = [_arrListContent objectAtIndex:indexPath.row];
    NSString *filePath = [_fileDirectoryPath stringByAppendingPathComponent:fileName];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if ([FileHelper deleteFileAtPath:filePath]) {
            
            [self.arrListContent removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSLog(@"unable to delete file");
        }
        
    }
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

    [FileHelper saveImagesToDirectory:arrImages andPath:self.fileDirectoryPath];
    //After saving remove all images from array
    [arrImages removeAllObjects];
    [self updateUI];
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
    
    //Single mode
    if (singleModeOn) {
        [self dismissViewControllerAnimated:YES completion:nil];
        singleModeOn = NO;
        [FileHelper saveImagesToDirectory:arrImages andPath:self.fileDirectoryPath];
        [arrImages removeAllObjects];
        [self updateUI];
    }
    
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIDocumentInteractionController delegates

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    
    return [self navigationController];
}

#pragma mark - action methods

- (IBAction)addMoreImages:(id)sender {
    
    [self openCamera];
}

- (IBAction)exportToPDF:(id)sender {
    
    if([self.arrListContent count]>0){
        NSMutableArray *arrOfImages = [self fillArrayOfImages];
        if (arrOfImages.count) {
            UIImage *image = [arrOfImages lastObject];
            //Set PDF Page Size
            pageSize = CGSizeMake(image.size.width+80, image.size.height+120);
            [self didClickMakePDFwithImagesArray:[NSMutableArray arrayWithArray:arrOfImages]];
        }
    }
}

-(void)selectRows:(UIBarButtonItem *)sender{
    
    isSelectionOn = !isSelectionOn;
    
    isSelectionOn?[self.navigationItem.rightBarButtonItem setTitle:@"cancel"]:[self.navigationItem.rightBarButtonItem setTitle:@"select"];
    
    if (!isSelectionOn) {
        [self.arrSelectedContent removeAllObjects];
        [_tblFileList reloadData];
    }
    
}

-(NSMutableArray *)fillArrayOfImages{
    
    NSMutableArray *arrImages = [NSMutableArray array];
    NSArray *file_list = _arrListContent;
    if (isSelectionOn) {
        file_list = _arrSelectedContent;
    }
    
    //Get Images in array from file system.
    for (NSString *name in file_list) {
        
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[_fileDirectoryPath stringByAppendingPathComponent:name]]];
        UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
        
        if (thumbNail) {
            [arrImages addObject:thumbNail];
        }
        
    }
    return arrImages;
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)msg{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}

#pragma mark - PDF Conversion Methods

- (void)didClickMakePDFwithImagesArray:(NSMutableArray *)images {
    NSString *uniqueName = @"file_export";
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir;
    NSString *path = [self.fileDirectoryPath stringByAppendingPathComponent:@"file_export.pdf"];
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir]){
        
        [self setupPDFDocumentNamed:uniqueName Width:680 Height:930];//680x930
        
        for (UIImage *anImage in images) {
            
            [self beginPDFPage];
            [self addImage:anImage atPoint:CGPointMake((pageSize.width/2)-(anImage.size.width/2), kPadding)];
            
        }
        
        [self finishPDF];
    }else{
        [self showAlertWithTitle:@"Warning" message:@"An exported PDF file already exists, please delete old file to export new pdf file."];
    }
}


-(UIImage *)getImageFromURL:(NSString *)url{
    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    
    UIImage *img = [UIImage imageWithData:dbFile];
    
    return img;
}

- (CGRect)addImage:(UIImage*)image atPoint:(CGPoint)point {
    
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
    
    return imageFrame;
}

- (void)beginPDFPage {
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
}

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height {
    
    //    pageSize = CGSizeMake(width, height);
    
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
    
    NSString *pdfPath = [self.fileDirectoryPath stringByAppendingPathComponent:newPDFName];
    
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
    
}


- (void)finishPDF {
    UIGraphicsEndPDFContext();
    
    [self showAlertWithTitle:@"Success!!!" message:@"PDF saved with name file_exported.pdf, you can find the same in the list."];
    [self updateUI];
}

-(void)updateUI{
    //Update file list
    [self setArrListContent:[NSMutableArray arrayWithArray:[FileHelper listFileAtPath:self.fileDirectoryPath]]];
    
    if (isSelectionOn) {
        [self selectRows:nil];
    }
    
    //Reload table
    [self.tblFileList reloadData];
}


@end
