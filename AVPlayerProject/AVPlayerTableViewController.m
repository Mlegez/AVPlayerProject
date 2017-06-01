//
//  AVPlayerTableViewController.m
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/6/1.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import "AVPlayerTableViewController.h"
#import "AudioPlayer.h"

@interface AVPlayerTableViewController ()

@property (nonatomic, strong) NSArray           *arr;


@end

@implementation AVPlayerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arr = @[
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489297980.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298049.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298107.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298166.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298230.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298030.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298095.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298150.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298217.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298011.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298082.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298135.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298196.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1490241311.mp3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489297996.MP3",
                 
                 @"http://ommy9id7o.bkt.clouddn.com/temple/temple_1489298067.MP3"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO,
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem,
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    cell.textLabel.text = @"cell";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *urlstring = self.arr[indexPath.row];
    [[AudioPlayer shareInstance] playAudioWithFileURL:[NSURL URLWithString:urlstring]];
    [[AudioPlayer shareInstance] play];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES,
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade],
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES,
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
