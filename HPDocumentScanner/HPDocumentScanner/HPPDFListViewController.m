//
//  PDFListViewController.m
//  CradScanner
//
//  Created by ASPL on 5/12/16.
//  Copyright © 2016 ASPL. All rights reserved.
//

#import "HPPDFListViewController.h"

@interface HPPDFListViewController ()<UIDocumentInteractionControllerDelegate>

@end

@implementation HPPDFListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrListContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    
    cell.textLabel.text=[_arrListContent objectAtIndex:indexPath.row];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSURL *URL = [NSURL fileURLWithPath:[_documentDirectoryPath stringByAppendingPathComponent:[_arrListContent objectAtIndex:indexPath.row]]];
    
    if (URL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        
        
        
        // Preview PDF
        [self.documentInteractionController presentPreviewAnimated:YES];
        
        
    }
    
}

#pragma mark UIDocumentInteractionController delegates

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    
    return [self navigationController];
}

@end
