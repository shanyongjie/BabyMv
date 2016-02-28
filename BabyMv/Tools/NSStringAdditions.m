

#import "NSStringAdditions.h"
#import "NSDataAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
//TT_FIX_CATEGORY_BUG(NSStringAdditions)

@implementation NSString (TTAdditions)

-(BOOL)isNotEmpty
{
	return [self length] > 0;		
}
-(BOOL)isContain:(NSString*)asubstr
{
    if (asubstr == nil) {
        return NO;
    }
	NSRange rg = [self rangeOfString:asubstr];
	return rg.length>0; 
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespaceAndNewlines {
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  for (NSInteger i = 0; i < self.length; ++i) {
    unichar c = [self characterAtIndex:i];
    if (![whitespace characterIsMember:c]) {
      return NO;
    }
  }
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Deprecated - https://github.com/facebook/three20/issues/367
 */
- (BOOL)isEmptyOrWhitespace {
  // A nil or NULL string is not the same as an empty string
  return 0 == self.length ||
         ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
}

+ (BOOL)isBlank:(NSString *)str{
    return str == nil || [str isEmptyOrWhitespace]; 
}

+ (BOOL)isNotBlank:(NSString *)str{
    return ![NSString isBlank:str];
}

+ (BOOL)isNumeric:(NSString *)str{
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSInteger hold;
    if ([scanner scanInteger:&hold] && [scanner isAtEnd]) return YES;
    return NO;
}

+ (BOOL)isNumericAndAlphabet:(NSString *)str{
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet lowercaseLetterCharacterSet]; 
    [charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    return [[str.lowercaseString stringByTrimmingCharactersInSet:charSet] isEqualToString:@""];
}

//+ (NSString *)base64StringFromData:(NSData *)data length:(int)length{
//    char base64EncodingTable[64] = {
//        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
//        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
//        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
//        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
//    };
//    unsigned long ixtext, lentext;
//    long ctremaining;
//    unsigned char input[3], output[4];
//    short i, charsonline = 0, ctcopy;
//    const unsigned char *raw;
//    NSMutableString *result;
//    
//    lentext = [data length]; 
//    if (lentext < 1)
//        return @"";
//    result = [NSMutableString stringWithCapacity: lentext];
//    raw = [data bytes];
//    ixtext = 0; 
//    
//    while (true) {
//        ctremaining = lentext - ixtext;
//        if (ctremaining <= 0) 
//            break;        
//        for (i = 0; i < 3; i++) { 
//            unsigned long ix = ixtext + i;
//            if (ix < lentext)
//                input[i] = raw[ix];
//            else
//                input[i] = 0;
//        }
//        output[0] = (input[0] & 0xFC) >> 2;
//        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
//        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
//        output[3] = input[2] & 0x3F;
//        ctcopy = 4;
//        switch (ctremaining) {
//            case 1: 
//                ctcopy = 2; 
//                break;
//            case 2: 
//                ctcopy = 3; 
//                break;
//        }
//        
//        for (i = 0; i < ctcopy; i++)
//            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
//        
//        for (i = ctcopy; i < 4; i++)
//            [result appendString: @"="];
//        
//        ixtext += 3;
//        charsonline += 4;
//        
//        if ((length > 0) && (charsonline >= length))
//            charsonline = 0;
//    }     
//    return result;
//}

-(BOOL)isPhoneNumber{
    if (![NSString isNumeric:self] || [NSString isBlank:self] || self.length != 11) {
        return NO;
    }
    unichar first = [self characterAtIndex:0];
    if (first != toascii('1')) {
        return NO;
    }
    unichar second = [self characterAtIndex:1];
    if (second < toascii('3') || second > toascii('8')) {
        return NO;
    }
    return YES;
}

-(BOOL)isEmail
{
    NSArray *validateAtSymbol = [self componentsSeparatedByString:@"@"];
    if ([validateAtSymbol count] != 2)
        return NO;
    
    NSArray *validateDotSymbol = [[validateAtSymbol objectAtIndex:1] componentsSeparatedByString:@"."];
    return [validateDotSymbol count]>=2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//- (NSString*)stringByRemovingHTMLTags {
//  TTMarkupStripper* stripper = [[[TTMarkupStripper alloc] init] autorelease];
//  return [stripper parse:self];
//    ASSERT(0);
//    ASSERT(0 && @"TODO" != NULL);
//    return nil;
//}

-(BOOL) isPhoneNumberOrEmail
{
    return [self isEmail] || [self isPhoneNumber];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
 * Deprecated
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[[NSScanner alloc] initWithString:self] autorelease];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSString* value = [[kvPair objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:encoding];
      [pairs setObject:value forKey:key];
    }
  }

  return [NSDictionary dictionaryWithDictionary:pairs];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[[NSScanner alloc] initWithString:self] autorelease];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 1 || kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSMutableArray* values = [pairs objectForKey:key];
      if (nil == values) {
        values = [NSMutableArray array];
        [pairs setObject:values forKey:key];
      }
      if (kvPair.count == 1) {
        [values addObject:[NSNull null]];

      } else if (kvPair.count == 2) {
        NSString* value = [[kvPair objectAtIndex:1]
                           stringByReplacingPercentEscapesUsingEncoding:encoding];
        [values addObject:value];
      }
    }
  }
  return [NSDictionary dictionaryWithDictionary:pairs];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [query keyEnumerator]) {
    NSString* value = [query objectForKey:key];
    value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }

  NSString* params = [pairs componentsJoinedByString:@"&"];
  if ([self rangeOfString:@"?"].location == NSNotFound) {
    return [self stringByAppendingFormat:@"?%@", params];

  } else {
    return [self stringByAppendingFormat:@"&%@", params];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)versionStringCompare:(NSString *)other {
  NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
  NSArray *twoComponents = [other componentsSeparatedByString:@"a"];

  // The parts before the "a"
  NSString *oneMain = [oneComponents objectAtIndex:0];
  NSString *twoMain = [twoComponents objectAtIndex:0];

  // If main parts are different, return that result, regardless of alpha part
  NSComparisonResult mainDiff;
  if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
    return mainDiff;
  }

  // At this point the main parts are the same; just deal with alpha stuff
  // If one has an alpha part and the other doesn't, the one without is newer
  if ([oneComponents count] < [twoComponents count]) {
    return NSOrderedDescending;

  } else if ([oneComponents count] > [twoComponents count]) {
    return NSOrderedAscending;

  } else if ([oneComponents count] == 1) {
    // Neither has an alpha part, and we know the main parts are the same
    return NSOrderedSame;
  }

  // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
  // numerically. If it's not a valid number (including empty string) it's treated as zero.
  NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
  NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
  return [oneAlpha compare:twoAlpha];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
  return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)sha1Hash {
  return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
}


+(NSString*) stringWithUUID {
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString    *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
 }

-(NSString*)trim
{
    return  [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString*)trimBegin:(NSString*)strBegin
{
    if ([strBegin length]==0) {
        return self;
    }
    if ([self hasPrefix:strBegin]) {
        return [self substringFromIndex:[strBegin length]];
    }else
        return self;
}

-(NSString*)trimEnd:(NSString*)strEnd
{
    if ([strEnd length]==0) {
        return self;
    }
    if ([self hasSuffix:strEnd]) {
        return [self substringToIndex:[self length]-[strEnd length]];
    }
    return self;
}
-(NSString*)trim:(NSString*)strTrim
{
    return  [self trimEnd:[self trimBegin:strTrim]];
}

-(NSString*)replaceOldString:(NSString*) strOld withNewString:(NSString*) strNew
{
    NSMutableString* strMutale = [NSMutableString stringWithString:self];
    NSRange r;
    r.location = 0; r.length = [self length];
    [strMutale replaceOccurrencesOfString:strOld withString:strNew options:NSCaseInsensitiveSearch range:r];
    return [NSString stringWithString:strMutale];
}

-(NSString*)replaceCRWithNewLine
{
    return [self replaceOldString:@"{CR}" withNewString:@"\n"];
}

-(NSString *)prefixForLength:(int)length{
    if ([NSString isNumericAndAlphabet:self]) {
        length *= 2;
        length--;
    }
    if (self.length >= length) {
        return [NSString stringWithFormat:@"%@...",[self substringToIndex:length - 1]];
    }
    return [[self copy] autorelease];
}

@end
