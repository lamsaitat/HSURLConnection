//
//  TASViewController.m
//  TestURLConnection
//
//  Created by Sai Tat Lam on 15/02/13.
//  Copyright (c) 2013 Sai Tat Lam. All rights reserved.
//

#import "TASViewController.h"

#import "HSURLConnection.h"

@interface TASViewController ()

@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation TASViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://lonelyplanetimages.files.wordpress.com/2011/01/black-dragon.jpg"]];
    
    self.urlLabel.text = [NSString stringWithFormat:@"URL: %@", request.URL.absoluteString];
    [self.spinner stopAnimating];
    [HSURLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response) {
        // Update the image in main thread, where UI modifications are meant to perform in.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        });
    } errorBlock:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Download failed." message:[NSString stringWithFormat:@"%@ failed to download.  error: %@", request.URL.absoluteString, error] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    } uploadPorgressBlock:nil downloadProgressBlock:^(float progress) {
        // Setting progress property will update the display, so also needs to perform in main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.spinner.isAnimating == NO) {
                [self.spinner startAnimating];
            }
            
            self.progressLabel.text = [NSString stringWithFormat:@"Progress: %.0f%%", progress * 100];
            self.progressBar.progress = progress;
        });
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
