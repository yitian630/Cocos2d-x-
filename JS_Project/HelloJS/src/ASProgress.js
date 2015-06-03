/**
 * Created by sunfei on 15/5/27.
 */
var ASProgress = cc.Sprite.extend({
    _progress : null,
    _isUpdate : null,
    ctor : function () {
        this._super();
        //背景
        var proBg = new cc.Sprite(res.bg_progress);
        this.addChild(proBg);
        //进度条
        var proFt = new cc.Sprite(res.progress);
        this._progress = new cc.ProgressTimer(proFt);
        this._progress.setType(cc.ProgressTimer.TYPE_BAR);
        this._progress.setBarChangeRate(cc.p(1,0));
        this._progress.setMidpoint(cc.p(0,1));
        //设置百分比
        this._progress.setPercentage(100);
        this.addChild(this._progress);
        //设置更新状态
        this._isUpdate = true;
    },
    updateUI :function (time) {
        if(this._isUpdate == false){
            return;
        }
        this.showProgress();
        var progressTo = new cc.ProgressTo(time,0);
        var callFunc = new cc.CallFunc(function () {
            if(this.getPercentage() <= 0){
                //游戏结束
                this._isUpdate = false;
                //停止所有动作
                this._progress.stopAllActions();
                //延时隐藏
                this.runAction(cc.sequence(new cc.Blink(0.8,3),new cc.CallFunc(function () {
                    this.hideProgress();
                },this)));
            }
        },this);
        this._progress.runAction(new cc.RepeatForever(cc.sequence(progressTo,callFunc)));
    },
    //显示进度条
    showProgress : function () {
        this.setVisible(true);
    },
    //隐藏进度条
    hideProgress : function () {
        this.setVisible(false);
    },
    //获取进度条当前百分比
    getPercentage : function () {
        return this._progress.getPercentage();
    },
    //重置进度条
    resetProgress : function () {
        this._isUpdate = true;
        this._progress.stopAllActions();
        this._progress.setPercentage(100);
    }
})