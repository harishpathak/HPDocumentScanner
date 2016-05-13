//
//  ViewController.m
//  CradScanner
//
//  Created by ASPL on 5/11/16.
//  Copyright © 2016 ASPL. All rights reserved.
//

#import "HPHomeViewController.h"
#import "HPPDFImageConverter.h"
#import "HPPDFListViewController.h"
#import "HPCollectionViewCell.h"

#define kPadding 20

@interface HPHomeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *arrImages;
    CGSize _pageSize;
    UIImagePickerController *imagePickController;
    NSString *documentsDirectory;
    
}


@property (weak, nonatomic) IBOutlet UIButton *btnTakePic;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewImages;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;


@end

@implementation HPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MyPDF"];
    
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDir]){
        if(![fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:NULL]){
            NSLog(@"Error: Create folder failed %@", documentsDirectory);
        }
    }
    
    arrImages = [NSMutableArray array];
    UINib *nib = [UINib nibWithNibName:@"HPCollectionViewCell" bundle: nil];
    [_collectionViewImages registerNib:nib forCellWithReuseIdentifier:@"imageCell"];
    
    // Configure layout
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(110, 110)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    [self.collectionViewImages setCollectionViewLayout:self.flowLayout];
    self.collectionViewImages.bounces = YES;
    [self.collectionViewImages setShowsHorizontalScrollIndicator:NO];
    [self.collectionViewImages setShowsVerticalScrollIndicator:NO];
    
}

- (void)didClickMakePDFwithImagesArray:(NSMutableArray *)images {
    NSString *uniqueName = @"CRMNEXT";
    NSString *timestamp = [NSString stringWithFormat:@"%zd",[[self listFileAtPath:documentsDirectory] count]+1];
    [self setupPDFDocumentNamed:[uniqueName stringByAppendingString:timestamp] Width:680 Height:930];
    
    for (UIImage *anImage in images) {
        
        [self beginPDFPage];
        [self addImage:anImage atPoint:CGPointMake((_pageSize.width/2)-(anImage.size.width/2), kPadding)];
        
    }
    
    [self finishPDF];
}
- (IBAction)clearItems:(id)sender {
    
    [arrImages removeAllObjects];
    [_collectionViewImages reloadData];
}
- (IBAction)takePicture:(id)sender {
    //Pick from Camera
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
    
        imagePickController=[[UIImagePickerController alloc]init];
        imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickController.delegate=self;
        imagePickController.allowsEditing=TRUE;
        
        [self presentViewController:imagePickController animated:YES completion:nil];
    }else{
        NSLog(@"No camera hardware found...");
    }
    
    
    
}

//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    
    [arrImages addObject:image];
    [_collectionViewImages reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)savePDF
{
    if([arrImages count]>0){
        [self didClickMakePDFwithImagesArray:[NSMutableArray arrayWithArray:arrImages]];
        [arrImages removeAllObjects];
        [_collectionViewImages reloadData];
    }
    
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pageSize.width, _pageSize.height), nil);
}

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height {
    
    _pageSize = CGSizeMake(width, height);
    
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
    
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];
    
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);

}


- (void)finishPDF {
    UIGraphicsEndPDFContext();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"toList"])
    {
        // Get reference to the destination view controller
      HPPDFListViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setArrListContent:[NSMutableArray arrayWithArray:[self listFileAtPath:documentsDirectory]]];
        [vc setDocumentDirectoryPath:documentsDirectory];
        vc.navigationController.navigationItem.title=@"PDF List";
    }
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

#pragma mark--- UicollectionView delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [arrImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HPCollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    if (cell) {
    
        cell.imageCell.image=[arrImages objectAtIndex:indexPath.row];
    //[cell.backgroundView addSubview:[[UIImageView alloc] initWithImage:[arrImages objectAtIndex:indexPath.row]]];
    
    }
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
