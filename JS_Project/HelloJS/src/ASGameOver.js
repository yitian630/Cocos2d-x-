/**
 * Created by sunfei on 15/5/27.
 */
var ASGameOverLayer = cc.Layer.extend({
    _labelTitle : null,    // 成绩结果显示
    _labelScoreInfo : null,  // 分数信息
    _restartItem : null,   // 重新开始按钮
    ctor : function () {
        this._super();
        var size = cc.winSize;
        //背景
        var bg = new cc.Sprite(res.bg_gold);
        bg.setScale(4,3);
        bg.setPosition(size.width/2,size.height/2);
        this.addChild(bg)
        //成绩展示
        this._labelTitle = new cc.LabelTTF("游戏结束了","Arial",45);
        this._labelTitle.setPosition(size.width/2,size.height/2+100);
        this.addChild(this._labelTitle);
        this._labelScoreInfo = new cc.LabelTTF("","",36);
        this._labelScoreInfo.setPosition(size.width/2,size.height/2+20);
        this.addChild(this._labelScoreInfo);
        //重新开始
        var labelRestart = new cc.LabelTTF("再来一次","Arial",50);
        this._restartItem = new cc.MenuItemLabel(labelRestart,this.callback,this);
        //不断缩放
        this._restartItem.runAction(new cc.RepeatForever(cc.sequence(new cc.ScaleTo(1.0,0.9),new cc.ScaleTo(1.0,1.1))));
        var menu = new cc.Menu(this._restartItem);
        menu.setPosition(size.width/2,size.height/2-70);
        this.addChild(menu);
    },
    //回调函数
    callback : function () {
        this.runAction(new cc.ScaleTo(0.3,0));
        this.getParent().startGame();
    },
    gameOverByScore : function (curScore, bestScore) {
        //不断缩放
        this._restartItem.runAction(new cc.RepeatForever(cc.sequence(new cc.ScaleTo(1.0,0.9),new cc.ScaleTo(1.0,1.1))));
        if(bestScore > 0){
            if(curScore > bestScore){
                this._labelTitle.setString("恭喜您破纪录了");
                this._labelTitle.runAction(cc.blink(1,8));
            }else{
                this._labelTitle.setString("您未破记录");
                this._labelTitle.runAction(cc.blink(1,4));
            }
            this._labelScoreInfo.setString("您的历史记录是"+bestScore+"枚");
        }else{
            if(curScore > 0){
                this._labelTitle.setString("您有新成绩了");
                this._labelTitle.runAction(cc.blink(1,8));
                this._labelScoreInfo.setString("这次捡了"+curScore+"枚金币");
            }else{
                this._labelTitle.setString("您点错了");
                this._labelTitle.runAction(cc.blink(1,8));
                this._labelScoreInfo.setString("这次一枚金币也没捡到");
            }
        }
    }

})
