//
//  StringHelper.h
//  PTLog
//
//  Created by Ellen Miner on 1/2/09.
//  Copyright 2009 RaddOnline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (StringHelper)
- (CGFloat)calHeightWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;
- (CGRect)frameForCellLabelWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;
/*
- (UILabel *)RAD_newSizedCellLabelWithSystemFontOfSize:(CGFloat)size;
- (void)RAD_resizeLabel:(UILabel *)aLabel WithSystemFontOfSize:(CGFloat)size;
*/

- (NSString *) baseHexEncode;
- (NSString *) baseHexDecode;

- (NSString *) fromHex; 
- (NSString *) toHex;

- (NSString *) md5;
- (NSString *) trim;
- (int) length2;


- (NSString *) documentPath;


//@interface NSString (NSString_JavaAPI)
- (int) compareTo: (NSString*) comp;
- (int) compareToIgnoreCase: (NSString*) comp;
- (bool) contains: (NSString*) substring;
- (bool) endsWith: (NSString*) substring;
- (bool) startsWith: (NSString*) substring;
- (int) indexOf: (NSString*) substring;
- (int) indexOf:(NSString *)substring startingFrom: (int) index;
- (int) lastIndexOf: (NSString*) substring;
- (int) lastIndexOf:(NSString *)substring startingFrom: (int) index;
- (NSString*) substringFromIndex:(int)from toIndex: (int) to;
- (NSArray*) split: (NSString*) token;
- (NSString*) replace: (NSString*) target withString: (NSString*) replacement;
- (NSArray*) split: (NSString*) token limit: (int) maxResults;


//@interface NSString(MPTidbits)

- (BOOL)isEmpty;
- (BOOL)isEmptyIgnoringWhitespace:(BOOL)ignoreWhitespace;
- (NSString *)stringByTrimmingWhitespace;


//custom
-(BOOL)isEmail;
- (BOOL)isMobileNumber;
-(BOOL)isValidateEmail;
-(BOOL)isValidatePwd;
+(NSString*) stringFromInteger:(NSInteger)num;
-(BOOL)isNull;
@end