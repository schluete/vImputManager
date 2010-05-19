
// There is no reason that the property's name need match 
// the instance variable's name exactly:

@interface MyObject: NSObject {
  id _ivar;
}

@property ivar;

@end


@implementation MyObject

@synthesize ivar=_ivar;

@end

