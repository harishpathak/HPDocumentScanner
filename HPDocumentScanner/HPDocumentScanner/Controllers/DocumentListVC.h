//
//  PDFListViewController.h
//  CradScanner
//
//  Created by Harish Pathak on 5/12/16.
//  Copyright © 2018 ASPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentListVC : UIViewController

@property(strong, nonatomic)NSMutableArray *arrListContent;
@property(strong, nonatomic)NSMutableArray *arrSelectedContent;
@property(strong, nonatomic)NSString *fileDirectoryPath;
@property(strong, nonatomic)UIDocumentInteractionController *documentInteractionController;
@property (weak, nonatomic) IBOutlet UIButton *btnExportToPDF;
@property (weak, nonatomic) IBOutlet UIButton *btnAddMoreImages;
@property (weak, nonatomic) IBOutlet UITableView *tblFileList;

@end
