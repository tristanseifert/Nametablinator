//
//  SQUHexadecimalFormatter.m
//  Nametablinator
//
//  Created by Tristan Seifert on 09/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUHexadecimalFormatter.h"

@implementation SQUHexadecimalFormatter

- (NSString *)stringFromNumber:(NSNumber *)number {
    NSString *result = [NSString stringWithFormat:@"$%08x", [number unsignedIntValue]];
    
    NSLog(@"Number %i converted to string: %@", [number unsignedIntValue], result);
    
    return result;
}

+ (NSString *)localizedStringFromNumber:(NSNumber *)num numberStyle:(NSNumberFormatterStyle)localizationStyle {
    NSString *result = [NSString stringWithFormat:@"$%08x", [num unsignedIntValue]];
    
    NSLog(@"Number %i converted to string using class method: %@", [num unsignedIntValue], result);
    
    return result;
}

@end
