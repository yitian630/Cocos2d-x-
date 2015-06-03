/**
 * Created by sunfei on 15/5/27.
 */
var ASGoldCell = cc.Node.extend({
    _cellSize:null,
    _goldHead:null,
    _goldLabel:null,
    ctor : function () {
        this._super();

        this._cellSize = 0;
        this._goldHead = new cc.Sprite(res.bg_gold);
        this.addChild(this._goldHead);

        this._goldLabel = new cc.LabelTTF("","Arial",20);
        this.addChild(this._goldLabel);

        //return true;
    },
    setGoldAndSize : function (gold, size) {
        this._cellSize = size;
        //显示金子堆和文字
        this._goldHead.setScale(this._cellSize/96);
        this._goldLabel.setString(gold ? "金" : "全");
        this._goldLabel.setFontSize(this._cellSize*0.95)
    },
    getCellSize : function () {
        return this._cellSize;
    }

});