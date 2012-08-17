//
//  ANStatusViewCell.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ANStatusViewCell.h"
#import "NSDictionary+SDExtensions.h"
#import "NSDate+SDExtensions.h"
#import "NSDate+ANExtensions.h"

CGFloat const ANStatusViewCellTopMargin = 10.0;
CGFloat const ANStatusViewCellBottomMargin = 10.0;
CGFloat const ANStatusViewCellLeftMargin = 10.0;
CGFloat const ANStatusViewCellUsernameTextHeight = 15.0;
CGFloat const ANStatusViewCellAvatarHeight = 50.0;
CGFloat const ANStatusViewCellAvatarWidth = 50.0;

@interface ANStatusViewCell()
{
    UIButton *showUserButton;
    SDImageView *avatarView;
    UILabel *usernameTextLabel;
    UILabel *created_atTextLabel;
    UIView *postView;
}

- (void)registerObservers;
- (void)unregisterObservers;

@end

@implementation ANStatusViewCell
@synthesize postData, showUserButton, avatarView, statusTextLabel, postView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.clipsToBounds = YES;
        
        //turn this off for custom highlighting in setSelected
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(70,0,250,0)];
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        
        UIColor* borderColor = [UIColor colorWithRed:157.0/255.0 green:167.0/255.0 blue:178.0/255.0 alpha:1.0];
        UIColor* textColor = [UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0];
        // future avatar
        avatarView = [[SDImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        avatarView.backgroundColor = [UIColor clearColor];
        avatarView.layer.borderWidth = 1.0;
        avatarView.layer.borderColor = [borderColor CGColor];
        [self.contentView addSubview: avatarView];

        showUserButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        showUserButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: showUserButton];
        
        UIColor *postColor = [UIColor colorWithRed:243.0/255.0 green:247.0/255.0 blue:251.0/255.0 alpha:1.0];
        postView = [[UIView alloc] initWithFrame:CGRectMake(70,0,250,100)];
        postView.alpha = 1.0;
        self.postView.backgroundColor = postColor;
        
        _leftBorder = [[CALayer alloc] init];
        _leftBorder.frame = CGRectMake(0,0,1,self.bounds.size.height);
        _leftBorder.backgroundColor = [borderColor CGColor];
        [self.postView.layer addSublayer:_leftBorder];
        
        _bottomBorder = [[CALayer alloc] init];
        _bottomBorder.frame = CGRectMake(0,0,self.bounds.size.width,1);
        _bottomBorder.backgroundColor = [borderColor CGColor];
        [self.postView.layer addSublayer:_bottomBorder];
        
        _topBorder = [[CALayer alloc] init];
        _topBorder.frame = CGRectMake(1,0,self.bounds.size.width-1,1);
        _topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        [self.postView.layer addSublayer:_topBorder];
        
        _avatarConnector = [[CALayer alloc] init];
        _avatarConnector.frame = CGRectMake(60,0,10,1);
        _avatarConnector.backgroundColor = [borderColor CGColor];
        [self.contentView.layer addSublayer:_avatarConnector];
        
        [self.contentView addSubview: postView];
        
        // username
        usernameTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 15)];
        usernameTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        usernameTextLabel.backgroundColor = postColor;
        usernameTextLabel.textColor = textColor;
        [self.postView addSubview: usernameTextLabel];
        
        //created_atTextLabel
        created_atTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 10, 55, 15)];
        created_atTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        created_atTextLabel.backgroundColor = postColor;
        created_atTextLabel.textColor = [UIColor grayColor];
        created_atTextLabel.textAlignment = UITextAlignmentRight;
        [self.postView addSubview: created_atTextLabel];
        
        // status label
        statusTextLabel = [[ANPostLabel alloc] initWithFrame:CGRectMake(10, 27, 230, 100)];
        //statusTextLabel.dataDetectorTypes = UIDataDetectorTypeAll;
        statusTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        statusTextLabel.backgroundColor = postColor;
        //statusTextLabel.numberOfLines = 0;
        statusTextLabel.textColor = textColor;
        statusTextLabel.highlightedTextColor = textColor;
        statusTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        statusTextLabel.clipsToBounds = YES;
        
        // set the link style
        /*NSMutableDictionary *linkAttributes = [[NSMutableDictionary alloc] initWithCapacity:1];
        statusTextLabel.linkAttributes = linkAttributes;
        [linkAttributes setValue:(id)[[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0]
                                                        CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];*/
       
        [self.postView addSubview: statusTextLabel];
        
        // register observers
        [self registerObservers];
    }
    return self;
}

-(void) dealloc
{
    [self unregisterObservers];
}

- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"postData" options:0 context:0];
    [self addObserver:self forKeyPath:@"username" options:0 context:0];
    [self addObserver:self forKeyPath:@"created_at" options:0 context:0];

}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"postData"];
    [self removeObserver:self forKeyPath:@"username"];
    [self removeObserver:self forKeyPath:@"created_at"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"postData"])
    {
        statusTextLabel.postData = self.postData;
        
        // handle frame resize
        CGSize maxStatusLabelSize = CGSizeMake(240,120);
        CGSize statusLabelSize = [[self.postData objectForKey:@"text"] sizeWithFont: statusTextLabel.font
                                              constrainedToSize:maxStatusLabelSize
                                              lineBreakMode: statusTextLabel.lineBreakMode];
    
        CGRect statusLabelNewFrame = statusTextLabel.frame;
        statusLabelNewFrame.size.height = statusLabelSize.height;
        statusTextLabel.frame = statusLabelNewFrame;
        
        NSString *username = [self.postData stringForKeyPath:@"user.username"];
        usernameTextLabel.text = username;
        
        NSDate *createdAt = [NSDate dateFromISO8601String:[self.postData stringForKey:@"created_at"]];
        created_atTextLabel.text = [createdAt stringInterval];
        
        NSString *avatarURL = [self.postData stringForKeyPath:@"user.avatar_image.url"];
        avatarView.imageURL = avatarURL;
        
        statusTextLabel.enabled = YES;
    }
}

/*
 workaround to a bug.  will investigate more soon.
 
 the tap doesn't get triggered unless its in the first line's worth of control height.
 
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    CGRect statusFrame = statusTextLabel.frame;
    if (CGRectContainsPoint(statusFrame, point))
    {
        CGPoint newPoint = [self convertPoint:point toView:statusTextLabel];
        if ([statusTextLabel canTapAtPoint:newPoint])
             return statusTextLabel;
    }

    if (result == statusTextLabel)
    {
        CGPoint newPoint = [self convertPoint:point toView:statusTextLabel];
        if ([statusTextLabel canTapAtPoint:newPoint])
            return statusTextLabel;
        else
            return self;
    }
    return result;
}

- (void)prepareForReuse
{
    avatarView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    avatarView.backgroundColor = [UIColor clearColor];
    statusTextLabel.enabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)selected
{
    if(selected) {
        [self.postView.superview bringSubviewToFront:self.postView];
        self.postView.backgroundColor = [UIColor whiteColor];
    } else {
        self.postView.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:247.0/255.0 blue:251.0/255.0 alpha:1.0];
    }
}

-(void)layoutSubviews {
    // size the post views according to the height of the cell
    self.postView.frame = CGRectMake(self.postView.frame.origin.x,self.postView.frame.origin.y,
                                     self.postView.frame.size.width,self.frame.size.height);
    _leftBorder.frame = CGRectMake(_leftBorder.frame.origin.x,_leftBorder.frame.origin.y,
                                     _leftBorder.frame.size.width,self.frame.size.height);
    _bottomBorder.frame = CGRectMake(_bottomBorder.frame.origin.x,self.frame.size.height-1.0,
                                   _bottomBorder.frame.size.width,_bottomBorder.frame.size.height);
    
    _avatarConnector.frame = CGRectMake(_avatarConnector.frame.origin.x,round(10.0+avatarView.frame.size.height/2.0),
                                     _avatarConnector.frame.size.width,_avatarConnector.frame.size.height);
    
     self.selectedBackgroundView.frame = CGRectMake(self.selectedBackgroundView.frame.origin.x,
                                                    self.selectedBackgroundView.frame.origin.y,
                                                    self.selectedBackgroundView.frame.size.width,
                                                    self.frame.size.height);
}

@end
