//
//  BottomView.h
//  DemoShowImages
//
//  Created by apricity on 2023/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BottomViewDelegate <NSObject>

- (void)deleteButtonDidClicked;

@end

@interface BottomView : UIView

@property (weak, nonatomic) id <BottomViewDelegate> delegate;

- (void)updateSelectedCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
