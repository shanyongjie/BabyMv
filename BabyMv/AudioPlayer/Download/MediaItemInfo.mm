//
//  MediaItemInfo.mm
//  KWPlayer
//
//  Created by YeeLion on 11-1-22.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import "MediaItemInfo.h"
#import "utility.h"


@implementation MediaItemInfo

@synthesize type;
@synthesize persistentId;
@synthesize file;
//@synthesize url;
@synthesize source;
@synthesize title;
@synthesize album;
@synthesize artist;
@synthesize bitRate;
@synthesize duration;
@synthesize uniqueId;

- (void) dealloc {
	[file release];
	//[url release];
	[source release];
	[title release];
	[album release];
	[artist release];
    [uniqueId release];
	[super dealloc];
}

//- (NSString*) url {
//    return url ? url : @"";
//}

- (NSString*) title {
	return title ? title : @"";
}

- (NSString*) album {
	return album ? album : @"";
}

- (NSString*) artist {
	return artist ? artist : @"";
}

- (NSString*) uniqueId {
    if (uniqueId)
        return uniqueId;
    
    if ([self isIPodMediaItem]) {
        char identifier[64];
        NSString* temp = [NSString stringWithFormat:@"%@-%@-%@-%lu", title, artist, album, duration];
//        NSLog(@"temp = %@", temp);
        GetMd5HashString(identifier, [temp UTF8String], -1);
        uniqueId = [[NSString stringWithUTF8String:identifier] retain];
//        NSLog(@"uniqueId = %@", uniqueId);
    }
    else {
        uniqueId = [[NSString stringWithFormat:@"%qu", persistentId] retain];
//        NSLog(@"uniqueId = %@", uniqueId);
    }
    return uniqueId;
}

- (id) initWithType:(KuwoMediaType)inType {
    self = [super init];
	if (self)
        self.type = inType;
    return self;
}

- (id) copyWithZone:(NSZone *)zone {
    MediaItemInfo* copy = [[self class] allocWithZone:zone];
    copy.type = self.type;
    copy.persistentId = self.persistentId;
    copy.file = self.file;
    //copy.url = self.url;
    copy.source = self.source;
    copy.title = self.title;
    copy.album = self.album;
    copy.artist = self.artist;
    copy.bitRate = self.bitRate;
    copy.duration = self.duration;
    return copy;
}

- (BOOL) isEqual:(MediaItemInfo*)item {
	if (MediaTypeMPMediaItem == self.type 
		&& MediaTypeMPMediaItem == item.type) {
		return self.persistentId == item.persistentId;
	} else if (MediaTypeMPMediaItem != self.type 
			   && MediaTypeMPMediaItem != item.type) {
		//return [self.url isEqual:item.url];
        return self.persistentId == item.persistentId;
    } else {
		return FALSE;
	}
}

- (BOOL) isIPodMediaItem {
    return type == MediaTypeMPMediaItem;
}

- (NSString*) sourceUrlOfMp3 {
    if ([self isIPodMediaItem])
        return @"iPod";
    
    if (!source || ![source length])
        return nil;
    
    NSRange start = [source rangeOfString:@"http://"];
    if (start.location == NSNotFound)
        return nil;
    
    NSRange range;
    range.location = start.location;
    
    NSRange tmp;
    tmp.location = start.location + start.length;
    tmp.length = [source length] - tmp.location;
    NSRange end;// = [source rangeOfString:@" " options:nil range:tmp];
    if (end.location == NSNotFound) {
        range.length = [source length] - range.location;
    } else {
        range.length = end.location - range.location;
    }
	if (range.length <= 0)
		return nil;

    NSMutableString* sourceUrl = [NSMutableString stringWithCapacity:range.length];
    [sourceUrl appendString:[source substringWithRange:range]];
    NSRange wmaRange = [sourceUrl rangeOfString:@".wma" options:NSBackwardsSearch];
    if (wmaRange.location != NSNotFound) {
        [sourceUrl replaceCharactersInRange:wmaRange withString:@".mp3"];
    }
    return sourceUrl;
}

+ (MediaItemInfo*) mediaItemInfoWithType:(KuwoMediaType)type {
    MediaItemInfo* itemInfo = [[[MediaItemInfo alloc] initWithType:type] autorelease];
    return itemInfo;
}

+ (MediaItemInfo*) mediaItemInfoWithMPMediaItem:(MPMediaItem*)item {
    MediaItemInfo* itemInfo = [MediaItemInfo mediaItemInfoWithType:MediaTypeMPMediaItem];
    itemInfo.title = [item valueForProperty:MPMediaItemPropertyTitle];
    itemInfo.album = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    itemInfo.artist = [item valueForProperty:MPMediaItemPropertyArtist];
    itemInfo.persistentId = [(NSNumber*)[item valueForProperty:MPMediaItemPropertyPersistentID] longLongValue];
    itemInfo.bitRate = 0;
    itemInfo.duration = [((NSNumber*)[item valueForProperty:MPMediaItemPropertyPlaybackDuration]) doubleValue];
    return itemInfo;
}

@end
