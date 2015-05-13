#include "AppDelegate.h"
#include "MainGame/ASMainScene.h"
#include "MainGame/ASStartGame.h"

USING_NS_CC;

AppDelegate::AppDelegate() {

}

AppDelegate::~AppDelegate() 
{
}

bool AppDelegate::applicationDidFinishLaunching() {
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
        glview = GLViewImpl::create("My Game");
        director->setOpenGLView(glview);
    }
    //设置适配方式
    //宽度适配，以800，480为基础变化
    glview->setDesignResolutionSize(640, 1136, ResolutionPolicy::FIXED_WIDTH);


    // turn on display FPS
    director->setDisplayStats(false);
    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);
    
    
    std::vector<std::string> searchPaths;
    searchPaths.push_back("images");//
    searchPaths.push_back("Buy");//
    searchPaths.push_back("CMGC");
    FileUtils *pFileUtils=FileUtils::getInstance();
    pFileUtils->setSearchPaths(searchPaths);
    
    
    

    // create a scene. it's an autorelease object
    auto startScene=ASStartGame::createScene();

    // run
    director->runWithScene(startScene);

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground() {
    Director::getInstance()->stopAnimation();

    // if you use SimpleAudioEngine, it must be pause
    // SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground() {
    Director::getInstance()->startAnimation();

    // if you use SimpleAudioEngine, it must resume here
    // SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
