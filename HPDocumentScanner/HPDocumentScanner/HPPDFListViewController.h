//
//  PDFListViewController.h
//  CradScanner
//
//  Created by ASPL on 5/12/16.
//  Copyright © 2016 ASPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPPDFListViewController : UITableViewController

@property(strong, nonatomic)NSMutableArray *arrListContent;
@property(strong, nonatomic)NSString *documentDirectoryPath;
@property(strong, nonatomic)UIDocumentInteractionController *documentInteractionController;

@end
