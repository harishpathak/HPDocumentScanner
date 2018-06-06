//
//  CameraOverlay.h
//  KotakPOC
//
//  Created by Harish Pathak on 30/05/18.
//  Copyright © 2018 CRMNEXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraOverlay : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imgVwPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblBadge;
@property (weak, nonatomic) IBOutlet UIButton *btnBatchMode;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSingleMode;

@end
