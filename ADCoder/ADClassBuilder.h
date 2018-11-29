//
//  ADClassBuilder.h
//  ADCoder
//
//  Created by Andy on 2018/11/29.
//  Copyright © 2018 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ！！以换行符作为代码分隔！！！
 
 @AClass:BClass ==> 声明一个名为继承自BClass的AClass的类
 <AProtocal ==> 遵循AProtocal协议
 $string aString,float height ==> 声明一个名为aProperty的属性和一个名为height的float类型属性
 ^fooWithParam1:param2:?string name,int age ==> 声明一个函数，函数名为fooWithParam1:param2:，函数名与参数之间用?分隔，参数与参数之间用,连接，形参类型与形参名之间用 分隔
 
 类型对照表：
 int/integer/long                   : NSInteger
 unsigned int                       : NSUInteger
 float                              : CGFloat
 bool                               : BOOL
 size                               : CGSize
 point                              : CGPoint
 rect                               : CGRect
 range                              : NSRange
 id                                 : id
 object                             : NSObject *
 null                               : NSNull *
 value                              : NSValue *
 number                             : NSNumber *
 string                             : NSString *
 mstring/stringm                    : NSMutableString *
 astring/stringa                    : NSAttributeString *
 amstring/stringam/stringma         : NSMutableAttributeString *
 dictionary/map                     : NSDictionary *
 mdictionary/mmap/dictionarym/mapm  : NSMutableDictionary *
 array/list                         : NSArray *
 marray/mlist/arraym/listm          : NSMutableArray *
 set                                : NSSet *
 mset/setm                          : NSMutableSet *
 data                               : NSData *
 date                               : NSDate *
 url                                : NSURL *
 timer                              : NSTimer *
 error                              : NSError *
 exception                          : NSException *
 
 image                              : UIImage *
 color                              : UIColor *
 font                               : UIFont *
 view                               : UIView *
 window                             : UIWindow *
 control                            : UIControl *
 table                              : UITableView *
 scroll                             : UIScrollView *
 collection                         : UICollectionView *
 button                             : UIButton *
 label                              : UILabel *
 imageview                          : UIImageView *
 textf/textfield                    : UITextField *
 textv/textview                     : UITextView *
 touch                              : UITouch *
 gest/gesture                       : UIGestureRecognizer *
 pan                                : UIPanGestureRecognizer *
 swip                               : UISwipeGestureRecognizer *
 press                              : UIPress *
 longpress                          : UILongPressGestureRecognizer *
 */

NS_ASSUME_NONNULL_BEGIN

@interface ADClassBuilder : NSObject

+ (void)run;

@end

NS_ASSUME_NONNULL_END
