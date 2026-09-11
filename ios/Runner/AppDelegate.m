#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import "SQLClient.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    SQLClient* client = [SQLClient sharedInstance];
    client.timeout = 20; // 將超時設定為 60 秒
    __block BOOL client_is_connect = NO;
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

          FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                                  methodChannelWithName:@"samples.flutter.io/sql"
                                                  binaryMessenger:controller.binaryMessenger];

          [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            // This method is invoked on the UI thread.
            // TODO
              
              NSString *method = call.method;
              NSLog(@">>>>>>>%@",method);

              if ([method isEqualToString:@"下斷線"]) {
                  NSLog(@"下斷線");
                  client_is_connect = NO;
                  [client disconnect];
                  result(@"下斷線");
              }
              else{

              //将字符串写到缓冲区。
                            NSData* jsonData = [method dataUsingEncoding:NSUTF8StringEncoding];

                            NSError *jsonError;
                            NSDictionary *JSON = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                            //NSLog(@"SQL_IP:%@",JSON[@"SQL_IP"]);
                            //NSLog(@"command:%@",JSON[@"command"]);
                            NSLog(@"client isConnected:%d",client_is_connect);



                            if(client_is_connect){
                                NSLog(@"已連線");

                                //檢查是否連線
                                [client execute:@"SELECT * FROM View_LOGIN" completion:^(NSArray* results) {


                                    NSLog(@"檢查是否連線:%lu",(unsigned long)[results count]);
                                    
                                    if([results count]>0){

                                        [client execute:JSON[@"command"] completion:^(NSArray* results) {

                                            //NSArray* results2 = [results objectAtIndex:0];
                                            //NSArray *arr = [[NSArray alloc] init];
                                            NSMutableArray *objectsMutable = [[NSMutableArray alloc] init];
                                            //NSDictionary *matchInfo = @{@"matchName" : @"123",
                                            //                            @"hostName"  : @"456"};
                                            //NSArray *matchInfo = [[NSArray alloc] initWithObjects:
                                            //                          @{@"matchName" : @"123"},
                                            //                          @{@"hostName" : @"123"},
                                            //                          nil];



                                          for (NSArray* table in results) {
                                            for (NSDictionary* row in table) {
                                                NSMutableDictionary *yourMutableDictionary = [[NSMutableDictionary alloc] init];
                                              for (NSString* column in row) {
                                                  NSLog(@"%@=%@", column, row[column]);



                                                  [yourMutableDictionary setValue:[NSString stringWithFormat:@"%@",row[column]] forKey:column];

                                                  //NSLog(@"%@=%@", column, row[column]);



                                                  //[yourMutableDictionary setObject:[NSString stringWithFormat:@"%@",row[column]] forKey:[NSString stringWithFormat:@"%@",column]];

                                              }
                                                [objectsMutable addObject:yourMutableDictionary];

                                            }
                                          }
                                            //arr = objectsMutable;


                                            //NSLog(@"results-1");
                                            //[client disconnect];
                                            //NSLog(@"results-2");
                                            //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
                                            //NSLog(@"results-3");
                                            //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                                            NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:objectsMutable options:0 error:nil] encoding: NSUTF8StringEncoding];

                                          result(json);
                                        }];

                                    }
                                    else{


                                        NSLog(@"重新建立連線");
                                        client_is_connect = NO;
                                        [client disconnectWithCompletion:^{
                                            [client connect:JSON[@"SQL_IP"] username:JSON[@"SQL_LOGIN_ACCOUNT"] password:JSON[@"SQL_LOGIN_PASSWORD"] database:JSON[@"SQL_NAME"] completion:^(BOOL success) {
                                                                                                                                        NSLog(@"success:%d",success);

                                                                                                                                        if (success) {

                                                                                                                                            client_is_connect = YES;
                                                                                                                                            [client execute:JSON[@"command"] completion:^(NSArray* results) {

                                                                                                                                                //NSArray* results2 = [results objectAtIndex:0];
                                                                                                                                                //NSArray *arr = [[NSArray alloc] init];
                                                                                                                                                NSMutableArray *objectsMutable = [[NSMutableArray alloc] init];
                                                                                                                                                //NSDictionary *matchInfo = @{@"matchName" : @"123",
                                                                                                                                                //                            @"hostName"  : @"456"};
                                                                                                                                                //NSArray *matchInfo = [[NSArray alloc] initWithObjects:
                                                                                                                                                //                          @{@"matchName" : @"123"},
                                                                                                                                                //                          @{@"hostName" : @"123"},
                                                                                                                                                //                          nil];



                                                                                                                                              for (NSArray* table in results) {
                                                                                                                                                for (NSDictionary* row in table) {
                                                                                                                                                    NSMutableDictionary *yourMutableDictionary = [[NSMutableDictionary alloc] init];
                                                                                                                                                  for (NSString* column in row) {
                                                                                                                                                      NSLog(@"%@=%@", column, row[column]);



                                                                                                                                                      [yourMutableDictionary setValue:[NSString stringWithFormat:@"%@",row[column]] forKey:column];

                                                                                                                                                      //NSLog(@"%@=%@", column, row[column]);



                                                                                                                                                      //[yourMutableDictionary setObject:[NSString stringWithFormat:@"%@",row[column]] forKey:[NSString stringWithFormat:@"%@",column]];

                                                                                                                                                  }
                                                                                                                                                    [objectsMutable addObject:yourMutableDictionary];

                                                                                                                                                }
                                                                                                                                              }
                                                                                                                                                //arr = objectsMutable;


                                                                                                                                                //NSLog(@"results-1");
                                                                                                                                                //[client disconnect];
                                                                                                                                                //NSLog(@"results-2");
                                                                                                                                                //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
                                                                                                                                                //NSLog(@"results-3");
                                                                                                                                                //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                                                                                                                                                NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:objectsMutable options:0 error:nil] encoding: NSUTF8StringEncoding];

                                                                                                                                              result(json);
                                                                                                                                            }];

                                                                                                                                        }
                                                                                                                                        else{
                                                                                                                                            result([FlutterError errorWithCode:@"UNAVAILABLE"
                                                                                                                                                                             message:@"sql not available."
                                                                                                                                                                             details:nil]);
                                                                                                                                        }
                                                                                                                                    }];
                                        }];



                                    }


                                }];




                            }
                            else{

                                NSLog(@"建立連線");
                                client_is_connect = NO;
                                [client disconnectWithCompletion:^{
                                    [client connect:JSON[@"SQL_IP"] username:JSON[@"SQL_LOGIN_ACCOUNT"] password:JSON[@"SQL_LOGIN_PASSWORD"] database:JSON[@"SQL_NAME"] completion:^(BOOL success) {
                                                                                                                NSLog(@"success:%d",success);

                                                                                                                if (success) {

                                                                                                                    client_is_connect = YES;
                                                                                                                    [client execute:JSON[@"command"] completion:^(NSArray* results) {

                                                                                                                        //NSArray* results2 = [results objectAtIndex:0];
                                                                                                                        //NSArray *arr = [[NSArray alloc] init];
                                                                                                                        NSMutableArray *objectsMutable = [[NSMutableArray alloc] init];
                                                                                                                        //NSDictionary *matchInfo = @{@"matchName" : @"123",
                                                                                                                        //                            @"hostName"  : @"456"};
                                                                                                                        //NSArray *matchInfo = [[NSArray alloc] initWithObjects:
                                                                                                                        //                          @{@"matchName" : @"123"},
                                                                                                                        //                          @{@"hostName" : @"123"},
                                                                                                                        //                          nil];



                                                                                                                      for (NSArray* table in results) {
                                                                                                                        for (NSDictionary* row in table) {
                                                                                                                            NSMutableDictionary *yourMutableDictionary = [[NSMutableDictionary alloc] init];
                                                                                                                          for (NSString* column in row) {
                                                                                                                              NSLog(@"%@=%@", column, row[column]);



                                                                                                                              [yourMutableDictionary setValue:[NSString stringWithFormat:@"%@",row[column]] forKey:column];

                                                                                                                              //NSLog(@"%@=%@", column, row[column]);



                                                                                                                              //[yourMutableDictionary setObject:[NSString stringWithFormat:@"%@",row[column]] forKey:[NSString stringWithFormat:@"%@",column]];

                                                                                                                          }
                                                                                                                            [objectsMutable addObject:yourMutableDictionary];

                                                                                                                        }
                                                                                                                      }
                                                                                                                        //arr = objectsMutable;


                                                                                                                        //NSLog(@"results-1");
                                                                                                                        //[client disconnect];
                                                                                                                        //NSLog(@"results-2");
                                                                                                                        //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
                                                                                                                        //NSLog(@"results-3");
                                                                                                                        //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                                                                                                                        NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:objectsMutable options:0 error:nil] encoding: NSUTF8StringEncoding];

                                                                                                                      result(json);
                                                                                                                    }];

                                                                                                                }
                                                                                                                else{
                                                                                                                    result([FlutterError errorWithCode:@"UNAVAILABLE"
                                                                                                                                                     message:@"sql not available."
                                                                                                                                                     details:nil]);
                                                                                                                }
                                                                                                            }];
                                }];


                            }

              }
              

              

              
              
          }];
    
    
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
