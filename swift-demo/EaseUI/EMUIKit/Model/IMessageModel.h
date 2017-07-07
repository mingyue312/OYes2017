
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <HyphenateLite/HyphenateLite.h>

@class EMMessage;
@protocol IMessageModel <NSObject>

@property (nonatomic) CGFloat cellHeight;
@property (strong, nonatomic, readonly) EMMessage *message;
@property (strong, nonatomic, readonly) NSString *messageId;
@property (nonatomic, readonly) EMMessageStatus messageStatus;
@property (nonatomic, readonly) EMMessageBodyType bodyType;
@property (nonatomic) BOOL isMessageRead;
// if the current login user is message sender
@property (nonatomic) BOOL isSender;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *avatarURLPath;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSAttributedString *attrBody;
//Placeholder image if it fails downloading iamge
@property (strong, nonatomic) NSString *failImageName;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGSize thumbnailImageSize;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) BOOL isMediaPlaying;
@property (nonatomic) BOOL isMediaPlayed;
@property (nonatomic) CGFloat mediaDuration;
@property (strong, nonatomic) NSString *fileIconName;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileSizeDes;
//progress of uploading or downloading the attachment message
@property (nonatomic) float progress;
@property (strong, nonatomic) NSString *fileLocalPath;
@property (strong, nonatomic) NSString *thumbnailFileLocalPath;
@property (strong, nonatomic) NSString *fileURLPath;
@property (strong, nonatomic) NSString *thumbnailFileURLPath;

- (instancetype)initWithMessage:(EMMessage *)message;

@end
