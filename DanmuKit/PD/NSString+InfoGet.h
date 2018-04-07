//
//  NSString+InfoGet.h
//  
//
//  Created by LuChen on 16/2/26.
//
//

#import <Foundation/Foundation.h>

struct postPack {
    unsigned int length;
    unsigned int lengthTwice;
    unsigned int postCode;
};
typedef struct postPack PostPack;

static const int kReadTimeOut = -1;
static const unsigned int kMaxBuffer = 1024;
static const unsigned int kPostCode = 0x2b1;
static const int16_t kstart = 0x6;
static const int16_t kend = 0x2;
static const int16_t kendless = 0x0;

@interface NSString (InfoGet)

- (NSString *)getMd5_32Bit;//MD5加密
+ (NSString *)uuid;//获取随机UUID
+ (NSString *)timeString;//获取时间戳（秒）
- (NSMutableData *)stringToHexData;//转换16位的data
- (NSData *)packToData:(NSString *)string;

- (BOOL)isPureInt;
- (NSString *)componentsFirstMatchedByRegex:(NSString *)regexStr;

@end
