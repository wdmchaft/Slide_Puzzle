//
//  ImageSliderViewController.m
//  ImageSlider
//
//  Created by Marc Chamly on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageSliderViewController.h"
#import "Puzzle.h"
#import "PuzzlePiece.h"
#import "FullImage.h"
@interface ImageSliderViewController (){
    
    NSMutableArray *tabView;
}

@property (nonatomic, retain) Puzzle *puzzle;
@property (nonatomic,retain) NSMutableArray *tabView;//=[[[NSMutableArray alloc] init] autorelease];
//@property (nonatomic,retain) NSObject *source;
@property (nonatomic,assign) Boolean displayed;
@property (nonatomic,assign) SystemSoundID audioEffect;
@property (nonatomic,assign) int colMax;
@property (nonatomic,assign) int rowMax;
@property (nonatomic,retain) UIImage *photo;

@end


@implementation ImageSliderViewController

@synthesize puzzle,displayed,audioEffect;
@synthesize tabView,colMax,rowMax,photo;

//@synthesize source;

- (id)initWithSize:(int) colMax1:(int) rowMax1:(UIImage *) img
{
    self = [super initWithNibName:@"ImageSliderViewController" bundle:nil];
    if (self) {
        photo = img;
        colMax = colMax1;
        rowMax = rowMax1;
        puzzle = [[Puzzle alloc] initWithSize:colMax :rowMax];
        tabView =[[NSMutableArray alloc] init];
        NSLog(@"aaaaaaa");
        
    }
    return self;
}

- (void)dealloc {
    [puzzle release];
    [tabView release];
    [photo release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    int ox = 0;
    int oy =0;
    int width = 320/colMax;
    int height = 416/rowMax;
    int position = 0;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Show image" style:UIBarButtonItemStylePlain target:self action:@selector(showFullImage)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    
    /*
     *   Decoupage d'une photo en plein de petites views
     *
     *
     */
    for(int j=0; j<rowMax; j=j+1){
        for (int i=0; i<colMax; i=i+1) {
            position +=1;       //position de l'image (1,2,3,...,rowMax+colMax)
           
            if(j!=rowMax-1 || i!=colMax-1){  
                CGImageRef cgImg = CGImageCreateWithImageInRect(photo.CGImage, CGRectMake(ox, oy, width, height));
                UIImage* part = [UIImage imageWithCGImage:cgImg];
                UIImageView* iv = [[UIImageView alloc] initWithImage:part];
                
                UIView* view1 = [[UIView alloc] initWithFrame:CGRectMake(ox, oy, width, height)];
                [view1 addSubview:iv];
                [iv release];
                
                UILabel *myLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0, 25, 25)] autorelease];
                [myLabel setText:[NSString stringWithFormat:@"%d",position]];
                
                //Creation du TapGestureRecognizer
                UITapGestureRecognizer *singleFingerTap = 
                [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                        action:@selector(handleSingleTap:)];
                [view1 addGestureRecognizer:singleFingerTap];
                [view1 addSubview:myLabel];
                [singleFingerTap release];

                
                PuzzlePiece *p = [[[PuzzlePiece alloc] initWithPos:(int)ox :(int)oy :position:i:j] autorelease]; //on créer l'objet qui contiendra les infos
                
                //un petit println
                NSLog(@"%d",position);
                
                
                [self.view addSubview:view1]; //on rajjoute l'image à notre viewPrincipale
                [tabView addObject:view1];    //on rajjoute l'image à notre tableau d'image
                [puzzle addViews: p];         //on rajjoute l'objet contenant les infos a notre tableau d'info
                ox+=width;                    //on deplace l'origine sur l'abscisse
                [view1 release];
                CGImageRelease(cgImg);
            }
            else if ((j==rowMax-1 && i==colMax-1)){ // cet objet correspont à l'objet "vide" reconnaissable grâce a ça position d'origine = 12
                NSLog(@"je contrsuote l'objet black crotte");
                PuzzlePiece *p = [[[PuzzlePiece alloc] initWithPos:(int)ox :(int)oy :position:i:j] autorelease]; //on créer l'objet qui contiendra les infos
                //[tabView addObject: p];
                [puzzle addViews: p];
            }
            
        }
        
        ox=0;               //on réinitialise l'origine de l'abscisse
        oy+=height;         //on deplace l'origine de l'ordonnée 
    }
    [puzzle shuffle:tabView];
    
    
}

-(void) showFullImage{
    [self.navigationController pushViewController: self.fullImage animated:YES];
}

- (FullImage *) fullImage{
    if(!fullImage){
        fullImage = [[FullImage alloc] initWithImage:photo];
        return fullImage;
    }
    return fullImage;
}





        
-(void)animateView:(int) origine:(int) x:(int) y{
    UIView *view1 =[tabView objectAtIndex:origine];
    for(id obj in tabView){
        if([obj getOrigin] == origine){
            [UIView animateWithDuration:1.0
                             animations:^{view1.center = CGPointMake(view1.center.x, view1.center.y+ view1.frame.size.height);}];
        }
    }
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //NSLog(@"%d",[tabView indexOfObject:recognizer.view]);
    int pos = [tabView indexOfObject:recognizer.view]+1;
    PuzzlePiece *p;
    for(id obj in [puzzle getPuzzler]){
        if([obj getOrigin] == pos){
            p = obj;
            //NSLog(@"%d",[obj getOrigin]);
        }
    }
    [puzzle canBeMoved2:p:tabView];
    Boolean finished =[puzzle puzzleIsFinished];
    if(finished && !displayed){                      // si le puzzle est finit et que l'image n'est pas deja affiche
        
        UIImageView *iView = [[UIImageView alloc] initWithFrame:CGRectMake(0,460,320,460)]  ;
        iView.image = photo;
        [self.view addSubview:iView];
        [iView release];
        [UIView animateWithDuration:2.5
                         animations:^{iView.center = CGPointMake(160,230);}];
        displayed = true;
    }
    else if(finished && displayed){
        NSLog(@"akjgblzjkdnbvkghqvlsdklcbvhlaqsdkjchb qghsjdckvnkh");
        //[self restartGame];
    }
}


-(void) restartGame{
   displayed =false;
    NSLog(@"restarting");
    //[tabView release];
    //[puzzle release];
    
    [self release];
    self.view = nil;
    //[self removeFromSuperview];
    [self init];
    [self viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[puzzle shuffle];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
