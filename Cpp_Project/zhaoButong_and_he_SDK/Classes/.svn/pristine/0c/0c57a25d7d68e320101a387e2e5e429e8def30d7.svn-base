//
//  ASMainScene.h
//  Different
//
//  Created by qiyuezhen on 15-4-21.
//
//

#ifndef __Different__ASMainScene__
#define __Different__ASMainScene__

#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "ui/UILoadingBar.h"
using namespace cocos2d;
using namespace  std;
USING_NS_CC_EXT;
class ASMainScene : public cocos2d::Layer
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene();
    
    virtual bool init();
    
    CREATE_FUNC(ASMainScene);
    //触摸事件
    virtual bool onTouchBegan(Touch *touch, cocos2d::Event *unused_event);
    virtual void onTouchMoved(Touch *touch, Event *unused_event);
    virtual void onTouchEnded(Touch *touch, Event *unused_event);
    
    //成功，下一个界面
    void succeedNext(void);
    
    //触摸事件监听器
    EventListenerTouchOneByOne *listener;
    //缩放系统
    float ratioY;
    
    int _count;
    void loadingbarUpdate(float delta);
    cocos2d::ui::LoadingBar* loadingBar;
    bool isCollsion(int x1, int y1);
    void readData(string myString);
    vector<int> posInfo;//位置信息
    
    Label *scoreLabel;
    Label *totalLabe;
    int  score;
    int totalScore;
    int  countNum;   //记录是否已经完全找到
    
    //返回键调用函数
    void onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent);
    //创建是否退出层
    void showIfExitAlert(Ref* pSender);
};

#endif /* defined(__Different__ASMainScene__) */
