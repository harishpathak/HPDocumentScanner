//
//  CoolectionViewCell.h
//  CradScanner
//
//  Created by Harish Pathak on 5/12/16.
//  Copyright © 2018 ASPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageCell;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UILabel *lblDateCreated;

@end
