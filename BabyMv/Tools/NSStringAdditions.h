
#import <Foundation/Foundation.h>




//@interface myClass : NSObject {
//
//    
//    
//}
//-(void)test;
//@end
/**
 * Doxygen does not handle categories very well, so please refer to the .m file in general
 * for the documentation that is reflected on api.three20.info.
 */
@interface NSString (TTAdditions)


-(BOOL)isContain:(NSString*)asubstr;


-(BOOL)isPhoneNumber;

//-(BOOL)isPostCode;

-(BOOL)isEmail;

-(BOOL)isPhoneNumberOrEmail;

/**
 * Determines if the string contains only whitespace and newlines.
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 * Determines if the string is empty or contains only whitespace.
 * @deprecated Use StringWithAnyText() instead. Updating your use of
 * this method is non-trivial. See the note below.
 *
 * Notes for updating your use of isEmptyOrWhitespace:
 *
 * if (!textField.text.isEmptyOrWhitespace) {
 *
 * becomes
 *
 * if (StringWithAnyText(textField.text) && !textField.text.isWhitespaceAndNewlines) {
 *
 * and
 *
 * if (textField.text.isEmptyOrWhitespace) {
 *
 * becomes
 *
 * if (0 == textField.text.length || textField.text.isWhitespaceAndNewlines) {
 */
- (BOOL)isEmptyOrWhitespace;

/**
 * return yes if the str is nil or empty or contains only whitespace.
 */
+ (BOOL)isBlank:(NSString *)str;

/**
 * return no if the str is nil or empty or contains only whitespace.
 */
+ (BOOL)isNotBlank:(NSString *)str;

/**
 * return yes if the str is numeric ,otherwise no.
 */
+ (BOOL)isNumeric:(NSString *)str;

+ (BOOL)isNumericAndAlphabet:(NSString *)str;

/**
 * return string by base64.
 */
//+ (NSString *)base64StringFromData:(NSData *)data length:(int)length;

/**
 * Parses a URL query string into a dictionary.
 *
 * @deprecated Use queryContentsUsingEncoding: instead.
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding ;

/**
 * Parses a URL query string into a dictionary where the values are arrays.
 */
- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding;

/**
 * Parses a URL, adds query parameters to its query, and re-encodes it as a new URL.
 */
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query;

/**
 * Returns a string with all HTML tags removed.
 */
//- (NSString*)stringByRemovingHTMLTags;

/**
 * Compares two strings expressing software versions.
 *
 * The comparison is (except for the development version provisions noted below) lexicographic
 * string comparison. So as long as the strings being compared use consistent version formats,
 * a variety of schemes are supported. For example "3.02" < "3.03" and "3.0.2" < "3.0.3". If you
 * mix such schemes, like trying to compare "3.02" and "3.0.3", the result may not be what you
 * expect.
 *
 * Development versions are also supported by adding an "a" character and more version info after
 * it. For example "3.0a1" or "3.01a4". The way these are handled is as follows: if the parts
 * before the "a" are different, the parts after the "a" are ignored. If the parts before the "a"
 * are identical, the result of the comparison is the result of NUMERICALLY comparing the parts
 * after the "a". If the part after the "a" is empty, it is treated as if it were "0". If one
 * string has an "a" and the other does not (e.g. "3.0" and "3.0a1") the one without the "a"
 * is newer.
 *
 * Examples (?? means undefined):
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- numeric, not lexicographic
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)other;

@property(nonatomic, readonly)BOOL isNotEmpty;

/**
 * Calculate the md5 hash of this string using CC_MD5.
 *
 * @return md5 hash of this string
 */
@property (nonatomic, readonly) NSString* md5Hash;

/**
 * Calculate the SHA1 hash of this string using CommonCrypto CC_SHA1.
 *
 * @return NSString with SHA1 hash of this string
 */
@property (nonatomic, readonly) NSString* sha1Hash;

+(NSString*) stringWithUUID;

-(NSString*)trim;
-(NSString*)trimBegin:(NSString*)strBegin;
-(NSString*)trimEnd:(NSString*)strEnd;
-(NSString*)trim:(NSString*)strTrim;

-(NSString*)replaceCRWithNewLine;

-(NSString*)replaceOldString:(NSString*) strOld withNewString:(NSString*) strNew;

-(NSString *)prefixForLength:(int)length;
@end

