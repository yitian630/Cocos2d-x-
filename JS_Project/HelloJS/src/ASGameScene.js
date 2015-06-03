/**
 * Created by sunfei on 15/5/27.
 */
var Key_BestScore = "Key_BestScore"
var ASGameLayer = cc.Layer.extend({
    _goldMatrix : null, //金子矩阵
    _labelBestScore : null, //最高分
    _levelLabel : null, //关卡
    _gameRun : null,   //游戏是否进行中
    _gameOverLayer : null,   //游戏结束层
    _scheduleID : null,   //调度器ID
    _progress : null,   // 进度条
    _currentLevel : null,  //当前关卡
    ctor: function () {

        this._super();
        var size = cc.winSize;

        //背景
        var bg = new cc.Sprite(res.bg_png);
        bg.attr({
            x: size.width / 2,
            y: size.height / 2
        });
        this.addChild(bg, 0);

        //添加返回菜单
        cc.MenuItemFont.setFontName("Times New Roman");
        cc.MenuItemFont.setFontSize(30);
        var backItem = new cc.MenuItemFont("返回",this.backItemCallback, this);
        var menu = new cc.Menu(backItem);
        menu.setPosition(0+backItem.getBoundingBox().width, size.height-backItem.getBoundingBox().height);
        this.addChild(menu, 0);

        //金子矩阵
        this._goldMatrix = new ASGoldMatrix();
        this._goldMatrix.setPositionX(size.width/2);
        this._goldMatrix.setPositionY(size.height/2);
        this.addChild(this._goldMatrix, 0);

        //添加进度条
        this._progress = new ASProgress();
        this.addChild(this._progress);
        this._progress.setPositionX(size.width/2);
        this._progress.setPositionY(size.height/8);
        this._progress.updateUI(1);

        // 最高成绩
        this._labelBestScore = new cc.LabelTTF("","Arial",25);
        this._labelBestScore.setPositionX(size.width-120);
        this._labelBestScore.setPositionY(size.height-35);
        this._labelBestScore.setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT);
        this._labelBestScore.setColor(new cc.color(222,0,53,255));
        this.addChild(this._labelBestScore);

        //关卡提示
        this._levelLabel = new cc.LabelTTF("","",50);
        this._levelLabel.setPosition(size.width/2,size.height/2+MATRIX_SIZE/2+60);
        this.addChild(this._levelLabel);
        this._levelLabel.setString("第1关");
        this._labelBestScore.setVisible(false);

        //显示最高成绩
        var bestScore = cc.sys.localStorage.getItem(Key_BestScore,0);
        if(bestScore > 0){
            this._labelBestScore.setVisible(true);
            this._labelBestScore.setString("最好成绩"+bestScore+"枚");
        }
        //添加游戏结束层
        this._gameOverLayer = new ASGameOverLayer()
        this.addChild(this._gameOverLayer);
        this._gameOverLayer.setScale(0);
        //添加触摸监听
        cc.eventManager.addListener({
            event : cc.EventListener.TOUCH_ONE_BY_ONE,
            onTouchBegan : function (touch, event) {
                cc.log("click the layer")
                //游戏结束后不再接受点击
                if(this._node._gameRun == false){
                    return true;
                }
                //获取触摸点
                var location = touch.getLocation()
                //计算金子单元矩阵的rect
                var posX = this._node._goldMatrix.getPositionX();
                var posY = this._node._goldMatrix.getPositionY();
                var result = this._node._goldMatrix.getObtainResult(cc.p(location.x-posX, location.y-posY));
                cc.log("result == ",result);
                if(result == "SUCCESS"){
                    this._node._currentLevel = this._node._goldMatrix.getCurrentLevel();
                    var time = 2;
                    if(this._node._currentLevel > 2 && this._node._currentLevel < 6){
                        time = 3/this._node._currentLevel + 2;
                    }else if(this._node._currentLevel >= 6 && this._node._currentLevel < 10){
                        time = 6/this._node._currentLevel + 2;
                    }else if(this._node._currentLevel >= 10 && this._node._currentLevel < 15){
                        time = 10/this._node._currentLevel + 2;
                    }else if(this._node._currentLevel >= 15 && this._node._currentLevel < 21){
                        time = 15/this._node._currentLevel + 2;
                    }else if(this._node._currentLevel >= 21){
                        time = 21/this._node._currentLevel + 2;
                    }
                    //刷新进度条
                    this._node._progress.resetProgress();
                    this._node._progress.updateUI(time);
                    //更新关卡文本
                    var scale0 = new cc.ScaleTo(0.2,0);
                    var callFunc = new cc.CallFunc(function () {
                        this._node._levelLabel.setString("第"+this._node._currentLevel+"关");
                    },this);
                    var scale1 = new cc.ScaleTo(0.1,1);
                    this._node._levelLabel.runAction(cc.sequence(scale0,callFunc,scale1));
                }else if(result == "FAILURE"){
                    //失败
                    this._node.unschedule(this._node.getProgressState);
                    this._node._gameRun = false;
                    //进度条隐藏并重置
                    this._node._progress.hideProgress();
                    this._node._progress.resetProgress();
                    //游戏结束
                    var callFunc = new cc.CallFunc(function () {
                        this._node.gameOver();
                    },this);
                    this._node.runAction(cc.sequence(cc.delayTime(0.8),callFunc));
                }

                return true;
            }
        }, this);
        //开启定时器
        this.schedule(this.getProgressState,0);
    },
    getProgressState : function () {
        if(this._progress._isUpdate == false){
            this._gameRun = false;
            this.unschedule(this.getProgressState);
            var callFunc = new cc.CallFunc(function () {
                this.gameOver();
                cc.log("进入游戏结束页面")
            },this);
            this.runAction(cc.sequence(cc.delayTime(0.8),callFunc));
        }
    },
    startGame : function () {
        this._levelLabel.setString("第1关");
        this._goldMatrix.resetGoldMatrix();
        this._goldMatrix.runAction(new cc.ScaleTo(0.3,1));
        this.schedule(this.getProgressState,0);
        this._progress.resetProgress();
        this._progress.updateUI(1);
        this._gameRun = true;
    },
    gameOver : function () {
        this._goldMatrix.runAction(cc.sequence(new cc.ScaleTo(0.2,0),new cc.CallFunc(function () {
            this._gameOverLayer.runAction(new cc.ScaleTo(0.3,1));
            //当前得分
            var curScore = this._goldMatrix.getCurrentScore();
            //历史最高分
            var bestScore = cc.sys.localStorage.getItem(Key_BestScore,0);
            if(curScore > bestScore){
                //更新最高成绩
                this._labelBestScore.setVisible(true);
                this._labelBestScore.setString("最好成绩"+curScore+"枚");
                //保存最好成绩
                cc.sys.localStorage.setItem(Key_BestScore,curScore);
            }
            this._gameOverLayer.gameOverByScore(curScore,bestScore);
        },this)));
    },
    backItemCallback : function () {
        cc.log("click back Item");
        cc.director.runScene(new ASMainScene())
    }
});

var ASGameScene = cc.Scene.extend({
   onEnter: function () {
       this._super();
       var layer = new ASGameLayer();
       this.addChild(layer);
   }
});