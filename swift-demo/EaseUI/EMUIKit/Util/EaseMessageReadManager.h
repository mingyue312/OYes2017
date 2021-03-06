
#import <Foundation/Foundation.h>

#import "MWPhotoBrowser.h"
#import "EaseMessageModel.h"

typedef void (^FinishBlock)(BOOL success);
typedef void (^PlayBlock)(BOOL playing, EaseMessageModel *messageModel);

@class EMChatFireBubbleView;
@interface EaseMessageReadManager : NSObject<MWPhotoBrowserDelegate>

@property (strong, nonatomic) MWPhotoBrowser *photoBrowser;
@property (strong, nonatomic) FinishBlock finishBlock;

@property (strong, nonatomic) EaseMessageModel *audioMessageModel;

+ (id)defaultManager;

//default
- (void)showBrowserWithImages:(NSArray *)imageArray
                       chatVC:(UIViewController *)rootVC;

- (BOOL)prepareMessageAudioModel:(EaseMessageModel *)messageModel
            updateViewCompletion:(void (^)(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel))updateCompletion;

- (EaseMessageModel *)stopMessageAudioModel;

@end
