//
//  main.m
//  ADCoder
//
//  Created by Andy on 2018/11/28.
//  Copyright © 2018 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADPropertyLazyGetter.h"
#import "ADClassBuilder.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int function = 0;
    SCANF_FUNCTION:
        {
            printf("功能选择：\n 1.生成类代码\n 2.属性生成懒加载getter方法\n 99.退出\n");
            scanf("%d", &function);
        }
        switch (function) {
            case 1:
                [ADClassBuilder run];
                break;
            case 2:
                [ADPropertyLazyGetter run];
                break;
            case 99:
                exit(0);
            default:
                goto SCANF_FUNCTION;
                break;
        }
    }
    return 0;
}
