/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoGroupCell.h"
#import "Masonry.h"
@implementation PhotoGroupCell

@synthesize imageView = _imageView,titleLabel = _titleLabel;
- (void)prepareForReuse{
    _imageView.image = nil;
    _titleLabel.text = @"";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self photoGroupCellWillLoad];
    }
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self photoGroupCellWillLoad];
}

- (void)photoGroupCellWillLoad{
    [self addSubImageView];
    [self addSubTitleLabel];
    [self addSubCategoryImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - AddSubviews
- (void)addSubImageView{
    _imageView = [[UIImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = true;
    [self.contentView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.width.equalTo(self.imageView.mas_height);
        
    }];

}

- (void)addSubTitleLabel{
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.imageView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        
    }];
}

- (void)addSubCategoryImageView{
    _categoryImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:_categoryImageView];
    [_categoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(15));
        make.bottom.mas_equalTo(-7);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    _categoryImageView.hidden = true;
}

@end

