/**
 * Created by sunfei on 15/6/4.
 */
var ASGameOverLayer = cc.Layer.extend({
    _norScore : null, //初始分数
    _curScore : null,  //当前分
    _curScoreLabel : null,  //当前分Label
    _bestScore : null,  //最高分
    _bestScoreLabel : null, //最高分Label
    _chenghao : null,
    ctor : function (score) {
        this._super();

        this._norScore = 0;
        this._curScore = score;
        var size = cc.winSize;

        //背景
        var bg = new cc.Sprite("#bg_blue.jpg");
        bg.setPosition(size.width/2, size.height/2);
        this.addChild(bg);

        //最高分
        var zuiGaoFen = new cc.Sprite("#zuigaofen.png");
        zuiGaoFen.setPosition(size.width/2, size.height/2);
        this.addChild(zuiGaoFen);

        //称号
        if(this._curScore >= 30){
            this._chenghao = new cc.Sprite("#chenghao_gaoji.png");
        }else if(this._curScore >= 80){
            this._chenghao = new cc.Sprite("#chenghao_dashen.png");
        }else{
            this._chenghao = new cc.Sprite("#chenghao_cainiao.png");
        }

        this._chenghao.setPosition(size.width/2, size.height/2);
        this.addChild(this._chenghao);

        //再战 和 挑衅 按钮
        var zaizhan = new cc.MenuItemImage("#item_zaizhan.png","#item_zaizhan.png",this.zaizhanFunc);
        //var tiaoxin = new cc.MenuItemImage("#item_tiaoxin.png","#item_tiaoxin.png",this.tiaoxinFunc);
        var menu = new cc.Menu(zaizhan);
        //menu.alignItemsHorizontallyWithPadding(30);
        menu.setPositionY(size.height/2 - zuiGaoFen.getBoundingBox().height/2 + 30)
        this.addChild(menu);

        //最高分显示
        this._bestScore = cc.sys.localStorage.getItem(BestScore)
        this._bestScoreLabel = new cc.LabelBMFont(this._bestScore,res.score_zuigao_fnt);
        this._bestScoreLabel.setScale(2)
        this._bestScoreLabel.setPosition(size.width/2 + this._bestScoreLabel.getBoundingBox().width/2 + 30, size.height/2 + zuiGaoFen.getBoundingBox().height/2 - 50)
        this.addChild(this._bestScoreLabel);
        //最高分闪烁
        this._bestScoreLabel.runAction(cc.blink(0.8,3))

        this.schedule(this.updateFunc,1/25);
        //当前分数
        this._curScoreLabel = new cc.LabelBMFont("0",res.score_jieshu_fnt);
        //this._curScoreLabel.setString(this._curScore);
        this._curScoreLabel.setScale(3);
        this._curScoreLabel.setPosition(size.width/2, size.height/2 + zuiGaoFen.getBoundingBox().height/2 + this._curScoreLabel.getBoundingBox().height/2)
        this.addChild(this._curScoreLabel);
        
        //添加键盘监听事件
        cc.eventManager.addListener({
        	event : cc.EventListener.KEYBOARD,
        	onKeyReleased: function (key, event) {
        		if(key == cc.KEY.back){
        			//调用退出游戏
        			JavaHelper.callToJavaKeyBoard();
        		}
        	}
        },this)
    },
    //刷新显示分数
    updateFunc : function () {
        if(this._curScore > 0){
            this._norScore++;
            this._curScoreLabel.setString(this._norScore);
            if(this._norScore == this._curScore){
                this.unschedule(this.updateFunc)
                this._curScoreLabel.runAction(cc.sequence(cc.delayTime(0.2),cc.blink(0.8,3)));
            }
        }
    },
    zaizhanFunc : function () {
        // 重新开始
        cc.director.runScene(new ASGameScene())
    },
    tiaoxinFunc : function () {
        //----挑衅--------
    }
})

var ASGameOverScene = cc.Scene.extend({
    score : null,
    ctor : function (score) {
        this._super();
        this.score = score;
    },
    onEnter : function () {
        this._super();
        var layer = new ASGameOverLayer(this.score);
        this.addChild(layer);
    }
})