//
//  ADClassBuilder.m
//  ADCoder
//
//  Created by Andy on 2018/11/29.
//  Copyright © 2018 Andy. All rights reserved.
//

#define ADClassBuilderFormatClassInterfaceBegin @"\n@interface %@ : %@\n\n"
#define ADClassBuilderFormatClassInterfaceEnd   @"\n@end\n\n"

#define ADClassBuilderFormatClassExtensionBegin @"\n@interface %@ ()\n\n"
#define ADClassBuilderFormatClassExtensionEnd   @"\n@end\n\n"

#define ADClassBuilderFormatClassImplementationBegin @"\n@implementation %@\n\n"
#define ADClassBuilderFormatClassImplementationEnd   @"\n@end\n\n"

#define ADClassBuilderFormatPropertyAssign  @"@property (nonatomic, assign) %@ %@;\n"
#define ADClassBuilderFormatPropertyWeak    @"@property (nonatomic, weak) %@ %@;\n"
#define ADClassBuilderFormatPropertyCopy    @"@property (nonatomic, copy) %@ %@;\n"
#define ADClassBuilderFormatPropertyStrong  @"@property (nonatomic, strong) %@ %@;\n"

#define ADClassBuilderFormatFunctionBegin       @"\n- (%@)%@"
#define ADClassBuilderFormatFunctionParameter   @":(%@)%@ "
#define ADClassBuilderFormatFunctionEnd         @"\n{\n\n}\n"

#import "ADClassBuilder.h"

@implementation ADClassBuilder

+ (void)run
{
    char path[256] = {};
SCANF_PATH:
    {
        printf("输入类描述文件绝对路径：\n");
        scanf("%s", path);
    }
    NSString *pathString = [[NSString alloc] initWithCString:path encoding:NSUTF8StringEncoding];
    if (pathString.length <= 0) {
        goto SCANF_PATH;
    }
    NSFileHandle *handel = [NSFileHandle fileHandleForReadingAtPath:pathString];
    if (!handel) {
        goto SCANF_PATH;
    }
    NSString *content = [[NSString alloc] initWithData:[handel readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    if (content.length <= 0) {
        return;
    }
    NSArray *classes = [content componentsSeparatedByString:@"@"];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSString *class in classes) {
        [result appendString:[self _dealClass:class]];
    }
    NSLog(@"\n\n<============== result begin ==============>\n\n%@<============== result end ==============>\n", result);
}

+ (NSString *)_dealClass:(NSString *)class
{
    class = [class stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (class.length <= 0) {
        return @"";
    }
    NSMutableString *rt = [[NSMutableString alloc] init];
    NSArray *lines = [class componentsSeparatedByString:@"\n"];
    if (lines.count < 1) {
        return rt;
    }
    
    NSString *classLine = lines.firstObject;
    NSArray *classAndSuperClass = [classLine componentsSeparatedByString:@":"];
    if (classAndSuperClass.count != 2) {
        return rt;
    }
    NSString *className = [classAndSuperClass.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *superClassName = [classAndSuperClass.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *findClassName = [self _findClass:superClassName retain:NULL];
    if (findClassName) {
        superClassName = [findClassName substringToIndex:findClassName.length - 2];
    }
    [rt appendFormat:ADClassBuilderFormatClassInterfaceBegin, className, superClassName];
    [rt appendString:ADClassBuilderFormatClassInterfaceEnd];
    
    [rt appendFormat:ADClassBuilderFormatClassExtensionBegin, className];
    
    if (lines.count < 2) {
        [rt appendString:ADClassBuilderFormatClassExtensionEnd];
        [rt appendFormat:ADClassBuilderFormatClassImplementationBegin, className];
        [rt appendString:ADClassBuilderFormatClassImplementationEnd];
        return rt;
    }
    
    NSString *propertyLine = [lines[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([propertyLine hasPrefix:@"$"]) {
        propertyLine = [propertyLine substringFromIndex:1];
    }
    [rt appendString:[self _dealProperty:propertyLine]];
    [rt appendString:ADClassBuilderFormatClassExtensionEnd];
    [rt appendFormat:ADClassBuilderFormatClassImplementationBegin, className];
    
    if (lines.count < 3) {
        [rt appendString:ADClassBuilderFormatClassImplementationEnd];
        return rt;
    }
    for (int i = 2; i < lines.count; i++) {
        NSString *line = [lines[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([line hasPrefix:@"^"]) {
            [rt appendString:[self _dealFunction:line]];
        }
    }
    [rt appendString:ADClassBuilderFormatClassImplementationEnd];
    
    return rt;
}

+ (NSString *)_dealProperty:(NSString *)property
{
    NSMutableString *rt = [[NSMutableString alloc] init];
    NSArray *properties = [property componentsSeparatedByString:@","];
    for (NSString *property in properties) {
        NSString *tmp = [property stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *pcAndPn = [tmp componentsSeparatedByString:@" "];
        if (pcAndPn.count != 2) {
            continue;
        }
        BOOL retain = YES;
        NSString *findClass = [self _findClass:pcAndPn.firstObject retain:&retain];
        NSString *pClass = findClass ? findClass : pcAndPn.firstObject;
        NSString *pName = pcAndPn.lastObject;
        if (retain) {
            [rt appendFormat:ADClassBuilderFormatPropertyStrong, pClass, pName];
        } else {
            [rt appendFormat:ADClassBuilderFormatPropertyAssign, pClass, pName];
        }
    }
    
    return rt;
}

+ (NSString *)_dealFunction:(NSString *)function
{
    NSMutableString *rt = [[NSMutableString alloc] init];
    return rt;
}

+ (NSString *)_findClass:(NSString *)class retain:(BOOL *)retain
{
    NSString *rt = nil;
    rt = [[self _assignClassMapper] objectForKey:class];
    if (rt) {
        if (retain != NULL) *retain = NO;
        return rt;
    }
    rt = [[self _retainClassMapper] objectForKey:class];
    if (rt) {
        if (retain != NULL) *retain = YES;
        return rt;
    }
    if (retain != NULL) *retain = YES;
    return rt;
}

+ (NSDictionary *)_assignClassMapper
{
    static NSDictionary *assignClassMapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assignClassMapper = @{
                              @"int"              : @"NSInteger",
                              @"integer"          : @"NSInteger",
                              @"long"             : @"NSInteger",
                              @"unsigned int"     : @"NSUInteger",
                              @"float"            : @"CGFloat",
                              @"bool"             : @"BOOL",
                              @"size"             : @"CGSize",
                              @"point"            : @"CGPoint",
                              @"rect"             : @"CGRect",
                              @"range"            : @"NSRange",
                              };
    });
    return assignClassMapper;
}

+ (NSDictionary *)_retainClassMapper
{
    static NSDictionary *retainClassMapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retainClassMapper = @{
                              @"id"               : @"id",
                              @"object"           : @"NSObject *",
                              @"null"             : @"NSNull *",
                              @"value"            : @"NSValue *",
                              @"number"           : @"NSNumber *",
                              @"string"           : @"NSString *",
                              @"mstring"          : @"NSMutableString *",
                              @"stringm"          : @"NSMutableString *",
                              @"astring"          : @"NSAttributeString *",
                              @"stringa"          : @"NSAttributeString *",
                              @"amstring"         : @"NSMutableAttributeString *",
                              @"mastring"         : @"NSMutableAttributeString *",
                              @"stringam"         : @"NSMutableAttributeString *",
                              @"stringma"         : @"NSMutableAttributeString *",
                              @"dictionary"       : @"NSDictionary *",
                              @"map"              : @"NSDictionary *",
                              @"mdictionary"      : @"NSMutableDictionary *",
                              @"mmap"             : @"NSMutableDictionary *",
                              @"dictionarym"      : @"NSMutableDictionary *",
                              @"mapm"             : @"NSMutableDictionary *",
                              @"array"            : @"NSArray *",
                              @"list"             : @"NSArray *",
                              @"marray"           : @"NSMutableArray *",
                              @"mlist"            : @"NSMutableArray *",
                              @"arraym"           : @"NSMutableArray *",
                              @"listm"            : @"NSMutableArray *",
                              @"set"              : @"NSSet *",
                              @"mset"             : @"NSMutableSet *",
                              @"setm"             : @"NSMutableSet *",
                              @"data"             : @"NSData *",
                              @"date"             : @"NSDate *",
                              @"url"              : @"NSURL *",
                              @"timer"            : @"NSTimer *",
                              @"error"            : @"NSError *",
                              @"exception"        : @"NSException *",
                              @"image"            : @"UIImage *",
                              @"color"            : @"UIColor *",
                              @"font"             : @"UIFont *",
                              @"view"             : @"UIView *",
                              @"window"           : @"UIWindow *",
                              @"control"          : @"UIControl *",
                              @"table"            : @"UITableView *",
                              @"scroll"           : @"UIScrollView *",
                              @"collection"       : @"UICollectionView *",
                              @"button"           : @"UIButton *",
                              @"label"            : @"UILabel *",
                              @"imageview"        : @"UIImageView *",
                              @"textf"            : @"UITextField *",
                              @"textfield"        : @"UITextField *",
                              @"textv"            : @"UITextView *",
                              @"textview"         : @"UITextView *",
                              @"touch"            : @"UITouch *",
                              @"gest"             : @"UIGestureRecognizer *",
                              @"gesture"          : @"UIGestureRecognizer *",
                              @"pan"              : @"UIPanGestureRecognizer *",
                              @"swip"             : @"UISwipeGestureRecognizer *",
                              @"press"            : @"UIPress *",
                              @"longpress"        : @"UILongPressGestureRecognizer *",
                              @"vc"               : @"UIViewController *",
                              @"viewcontroller"   : @"UIViewController *",
                              };
    });
    return retainClassMapper;
}

@end
