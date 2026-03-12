//
//  SearchEngineBridge.m
//  ClipMind
//
//  Created by HappyQi on 2026/3/11.
//

//
//  SearchEngineBridge.mm
//  ClipMind
//

#import "SearchEngineBridge.h"
#import "SearchEngine.hpp"

@implementation SearchEngineBridge {
    SearchEngine *_engine;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _engine = new SearchEngine();
    }
    return self;
}

- (void)dealloc {
    delete _engine;
    _engine = nullptr;
}

- (NSArray<NSDictionary *> *)searchWithQuery:(NSString *)query {
    std::string cppQuery = [query UTF8String];
    std::vector<DisplayItem> cppResults = _engine->search(cppQuery);

    NSMutableArray<NSDictionary *> *results = [NSMutableArray array];
    for (const auto& item : cppResults) {
        NSString *identifier = [NSString stringWithUTF8String:item.id.c_str()];
        NSString *text = [NSString stringWithUTF8String:item.displayText.c_str()];

        [results addObject:@{
            @"id": identifier,
            @"text": text
        }];
    }

    return results;
}

- (NSArray<NSDictionary *> *)allItems {
    std::vector<DisplayItem> cppResults = _engine->allItems();

    NSMutableArray<NSDictionary *> *results = [NSMutableArray array];
    for (const auto& item : cppResults) {
        NSString *identifier = [NSString stringWithUTF8String:item.id.c_str()];
        NSString *text = [NSString stringWithUTF8String:item.displayText.c_str()];

        [results addObject:@{
            @"id": identifier,
            @"text": text
        }];
    }

    return results;
}

- (void)addItemWithId:(NSString *)identifier source:(NSString *)source text:(NSString *)text {
    std::string cppId = [identifier UTF8String];
    std::string cppSource = [source UTF8String];
    std::string cppText = [text UTF8String];
    _engine->addOrUpdateItem(cppId, cppSource, cppText);
}

- (void)deleteItemWithId:(NSString *)identifier {
    std::string cppId = [identifier UTF8String];
    _engine->deleteItem(cppId);
}

- (void)deleteAllItems {
    _engine->deleteAllItems();
}

@end
