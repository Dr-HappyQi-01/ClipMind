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

- (NSArray<NSString *> *)searchWithQuery:(NSString *)query {
    std::string cppQuery = [query UTF8String];
    std::vector<std::string> cppResults = _engine->search(cppQuery);

    NSMutableArray<NSString *> *results = [NSMutableArray array];
    for (const auto& item : cppResults) {
        [results addObject:[NSString stringWithUTF8String:item.c_str()]];
    }

    return results;
}

- (NSArray<NSString *> *)allItems {
    std::vector<std::string> cppResults = _engine->allItems();

    NSMutableArray<NSString *> *results = [NSMutableArray array];
    for (const auto& item : cppResults) {
        [results addObject:[NSString stringWithUTF8String:item.c_str()]];
    }

    return results;
}

- (void)addItemWithId:(NSString *)identifier source:(NSString *)source text:(NSString *)text {
    std::string cppId = [identifier UTF8String];
    std::string cppSource = [source UTF8String];
    std::string cppText = [text UTF8String];
    _engine->addOrUpdateItem(cppId, cppSource, cppText);
}

@end
