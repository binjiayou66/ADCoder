//
//  ADPropertyLazyGetter.m
//  ADCoder
//
//  Created by Andy on 2018/11/28.
//  Copyright © 2018 Andy. All rights reserved.
//

#define ADPropertyLazyGetterFormatCommon @"\
- (%@)%@\n\
{\n\
    if (!_%@) {\n\
        _%@ = [[%@ alloc] init];\n\
    }\n\
    return _%@;\n\
}\n\n"

#define ADPropertyLazyGetterFormatUILabel @"\
- (%@)%@\n\
{\n\
    if (!_%@) {\n\
        _%@ = [[%@ alloc] init];\n\
        _%@.textColor = [UIColor ];\n\
        _%@.font = [UIFont systemFontOfSize:];\n\
    }\n\
    return _%@;\n\
}\n\n"

#define ADPropertyLazyGetterFormatUIButton @"\
- (%@)%@\n\
{\n\
    if (!_%@) {\n\
        _%@ = [[%@ alloc] init];\n\
        _%@.titleLabel.font = [UIFont systemFontOfSize:];\n\
        [_%@ setTitle:@\"\" forState:UIControlStateNormal];\n\
        [_%@ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];\n\
        [_%@ setImage:[UIImage imageNamed:@\"\"] forState:UIControlStateNormal];\n\
        [_%@ addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];\n\
    }\n\
    return _%@;\n\
}\n\n"

#define ADPropertyLazyGetterFormatUITextField @"\
- (%@)%@\n\
{\n\
    if (!_%@) {\n\
        _%@ = [[%@ alloc] init];\n\
        _%@.textColor = [UIColor ];\n\
        _%@.font = [UIFont systemFontOfSize:];\n\
        _%@.placeholder = @\"\";\n\
        _%@.delegate = self;\n\
    }\n\
    return _%@;\n\
}\n\n"

#define ADPropertyLazyGetterFormatUITableView @"\
- (%@)%@\n\
{\n\
    if (!_%@) {\n\
        _%@ = [[%@ alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];\n\
        _%@.dataSource = self;\n\
        _%@.delegate = self;\n\
        _%@.backgroundColor = [UIColor clearColor];\n\
        _%@.separatorStyle = UITableViewCellSeparatorStyleNone;\n\
        _%@.estimatedRowHeight = 0;\n\
        _%@.estimatedSectionHeaderHeight = 0;\n\
        _%@.estimatedSectionFooterHeight = 0;\n\
        [_%@ registerClass:[UITableViewCell class] forCellReuseIdentifier:@\"\"];\n\
        if (@available(iOS 11.0, *)) {\n\
            _%@.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;\n\
        } else {\n\
            self.automaticallyAdjustsScrollViewInsets = NO;\n\
        }\n\
    }\n\
    return _%@;\n\
}\n\n"

#import "ADPropertyLazyGetter.h"

@implementation ADPropertyLazyGetter

+ (NSString *)_getterStringWithClassName:(NSString *)className propertyName:(NSString *)propertyName isObject:(BOOL)isObject
{
    className = [className stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    propertyName = [propertyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *classNameFull = isObject ? [NSString stringWithFormat:@"%@ *", className] : className;
    propertyName = [propertyName substringToIndex:propertyName.length - 1];
    if ([className containsString:@"UILabel"]) {
        return [NSString stringWithFormat:ADPropertyLazyGetterFormatUILabel, classNameFull, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName];
    }
    if ([className containsString:@"UIButton"]) {
        return [NSString stringWithFormat:ADPropertyLazyGetterFormatUIButton, classNameFull, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName];
    }
    if ([className containsString:@"UITextField"]) {
        return [NSString stringWithFormat:ADPropertyLazyGetterFormatUITextField, classNameFull, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName];
    }
    if ([className containsString:@"UITableView"]) {
        return [NSString stringWithFormat:ADPropertyLazyGetterFormatUITableView, classNameFull, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName];
    }
    return [NSString stringWithFormat:ADPropertyLazyGetterFormatCommon, classNameFull, propertyName, propertyName, propertyName, className, propertyName];
}

+ (void)run
{
    char path[256] = {};
SCANF_PATH:
    {
        printf("输入文件绝对路径：\n");
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
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSString *line in lines) {
        if ([line containsString:@"@property"]) {
            NSUInteger index = [line rangeOfString:@")"].location;
            if (index != NSNotFound && line.length > index + 1) {
                NSString *subLine = [line substringFromIndex:index + 1];
                BOOL isObject = [subLine containsString:@"*"];
                NSString *separatorString = isObject ? @"*" : @" ";
                NSArray *tmp = [subLine componentsSeparatedByString:separatorString];
                if (tmp.count != 2) {
                    return;
                }
                NSString *getterString = [self _getterStringWithClassName:tmp.firstObject propertyName:tmp.lastObject isObject:isObject];
                [result appendString:getterString];
            }
        }
    }
    NSLog(@"\n\n<============== result begin ==============>\n\n%@<============== result end ==============>\n", result);
}

@end
