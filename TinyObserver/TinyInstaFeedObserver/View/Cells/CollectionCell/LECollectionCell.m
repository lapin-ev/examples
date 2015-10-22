
//  Created by Jack Lapin on 05.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//


#import "FOModel.h"
#import "LECollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+placeHolderImage.h"



@interface LECollectionCell()

@property (nonatomic, weak) IBOutlet UIImageView *modelImage;
@property (nonatomic, weak) IBOutlet UILabel *modelCaption;

@end

@implementation LECollectionCell

- (void)configWithModel:(FOModel *)model
{
    self.modelCaption.text = [model valueForKey:kModelDecription];
    NSURL *imageURL = [model valueForKey:kModelImg];
   [self.modelImage sd_setImageWithURL:imageURL placeholderImage:[UIImage setPlaceholderImage]];

}

@end
