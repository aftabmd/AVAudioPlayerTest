//
//  ViewController.m
//  AVAudioPlayerTest
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property float volume;
@property NSInteger numberOfLoops;

@end

@implementation ViewController{
    AVAudioPlayer *player;
    NSArray *musicFiles;
    NSTimer *timer;
}

//프로그래스 업데이트
-(void)updateProgress:(NSTimer *)timer{
    self.progress.progress = player.currentTime / player.duration;
}


-(IBAction)Loop:(id)sender{
    [self.table indexPathsForSelectedRows];
    [player setNumberOfLoops:-1];
}
//파일 재생
-(void)playMusic:(NSURL *)url{
    if(nil!=player){
        if([player isPlaying]){
            [player stop];
        }
        
        //플레이어 초기화
        player = nil;
        
        //타이머 처리
        [timer invalidate];
        timer = nil;
    }
    
    __autoreleasing NSError *error;
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    if([player prepareToPlay]){
        self.status.text = [NSString stringWithFormat:@"재생 중:%@",[[url path]lastPathComponent]];
        [player play];
        
        //타이머 시작
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
}

//AVAudioPlayerDelegate - 재생 완료
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.status.text  = @"재생 완료";
    
    //타이머 중지
    [timer invalidate];
    timer = nil;
}

//AVAudioPlayerDelegate - 재생 중 오류
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    self.status.text = [NSString stringWithFormat:@"재생중 오류 발생 : %@", [error description]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [musicFiles count];
}

#define CELL_ID @"CELL_ID"
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    cell.textLabel.text  = [musicFiles objectAtIndex:indexPath.row];
    return cell;
}

//셀 선택으로 파일 재생
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName = [musicFiles objectAtIndex:indexPath.row];
    NSURL *urlForPlay = [[NSBundle mainBundle]URLForResource:fileName withExtension:nil];
    [self playMusic:urlForPlay];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    musicFiles = [[NSArray alloc]initWithObjects:@"music1.mp3", @"music2.mp3",@"music3.mp3", nil];
    
    //다른 어플리케이션의 음악 재생을 멈추지 않는 정책
    AVAudioSession *session = [AVAudioSession sharedInstance];
    __autoreleasing NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryAmbient error:&error];
}

-(void)viewDidUnload{
    [timer invalidate];
    timer = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
