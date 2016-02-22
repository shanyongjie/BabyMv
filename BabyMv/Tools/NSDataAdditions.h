
#import <Foundation/Foundation.h>




@interface NSData (TTCategory)

/**
 * Calculate the md5 hash of this data using CC_MD5.
 *
 * @return md5 hash of this data
 */
@property (nonatomic, readonly) NSString* md5Hash;

/**
 * Calculate the SHA1 hash of this data using CC_SHA1.
 *
 * @return SHA1 hash of this data
 */
@property (nonatomic, readonly) NSString* sha1Hash;

+(NSData *)dataFromBase64String:(NSString *)base64String;
-(id)initWithBase64String:(NSString *)base64String;
-(NSString *)base64EncodedString;

@end
