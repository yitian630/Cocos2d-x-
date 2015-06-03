/**
 * Created by sunfei on 15/5/27.
 */
var Result = {}
    Result.success = "SUCCESS",
    Result.dontObtain = "DONTOBTAIN",
    Result.failure = "FAILURE",
    Result.invalid = "INVALID"

var MATRIX_SIZE = 400;
var MAX_SIZE = 7;

var ASGoldMatrix = cc.Node.extend({
    _level : null,
    _canObtain : null,
    _gold : null,
    _goldCell : null,
    ctor : function () {
        this._super();

        this._goldCell = [];
        //兔子单元矩阵
        for(var r = 0; r < MAX_SIZE; r++){
            this._goldCell.push([]);
            for(var c = 0; c < MAX_SIZE; c++){
                this._goldCell[r][c] = new ASGoldCell()
                this.addChild(this._goldCell[r][c])
                // 暂时不显示
                this._goldCell[r][c].setVisible(false)
            }
        }
        this._canObtain = true;
        //重置金子单元矩阵
        this.resetGoldMatrix()

    },
    resetGoldMatrix : function () {
        this._level = 1;
        this.showGoldMatrix()
    },
    getMatrixSizeShow : function () {
        var matrixSize_Show = 0;
        var levelSum = 0;
        for(var size = 2; size < MAX_SIZE; size++){
            if(this._level > levelSum && this._level <= levelSum+size){
                matrixSize_Show = size;
                break;
            }
            levelSum += size;
        }
        if(matrixSize_Show < 2){
            matrixSize_Show = MAX_SIZE;
        }
        return matrixSize_Show;
    },
    showGoldMatrix : function () {
        //开始动画不能点
        this._canObtain = false;
        //获取金子单元显示密度
        var matrixSize_Show = this.getMatrixSizeShow()
        //随机生成金子坐标,取值1-matrixSize_Show
        var rGold = Math.floor(cc.random0To1() * matrixSize_Show);
        var cGold = Math.floor(cc.random0To1() * matrixSize_Show);
        cc.log("----",rGold);
        cc.log("----",cGold);
        var goldSize = MATRIX_SIZE/matrixSize_Show;
        var callFunc = new cc.CallFunc(function () {
            this._canObtain = true;
        },this)
        //显示金子单元
        for( var r = 0; r < MAX_SIZE; r++){
            for(var c = 0; c < MAX_SIZE; c++){
                if(r < matrixSize_Show && c < matrixSize_Show){
                    this._goldCell[r][c].setVisible(true);
                    var pos = cc.p(-MATRIX_SIZE/2+r*goldSize+goldSize/2,-MATRIX_SIZE/2+c*goldSize+goldSize/2);
                    this._goldCell[r][c].setPosition(pos);
                    //this._goldCell[r][c].setVisible(true);
                    this._goldCell[r][c].setGoldAndSize(r==rGold && c==cGold, MATRIX_SIZE/matrixSize_Show);
                    //动画显示
                    var scale1 = new cc.ScaleTo(0.1, 1);
                    if(callFunc != null){
                        this._goldCell[r][c].runAction(cc.sequence(scale1, callFunc));
                    }else{
                        this._goldCell[r][c].runAction(scale1);
                    }
                }else{
                    this._goldCell[r][c].setVisible(false);
                }
            }
        }
        this._gold = this._goldCell[rGold][cGold];
        cc.log("_gold",this._gold)
    },
    //隐藏金子矩阵
    hideGoldMatrix : function () {
        cc.log(">>>>>>>>>>隐藏")
        //开始动画不能点
        this._canObtain = false;
        //遍历金子单元，把显示的缩小
        for(var r = 0; r < MAX_SIZE; r++){
            for(var c = 0; c < MAX_SIZE; c++){
                //未显示的不往下遍历了
                if(this._goldCell[r][c].isVisible == false){
                    break;
                }
                //动画隐藏
                var scale0 = new cc.ScaleTo(0.1,0);
                this._goldCell[r][c].runAction(scale0);
            }
        }
    },
    //返回点击结果
    getObtainResult : function (p) {
        if(this._canObtain == false){
            return Result.dontObtain;
        }
        //遍历查看点到哪个金子单元了
        for(var r = 0; r < MAX_SIZE; r++){
            for(var c = 0; c < MAX_SIZE; c++){
                //未显示的不往下遍历了
                if(this._goldCell[r][c].isVisible() == false){
                    break;
                }
                //计算金子单元矩阵
                var _posX = this._goldCell[r][c].getPositionX();
                var _posY = this._goldCell[r][c].getPositionY();
                var _size = this._goldCell[r][c].getCellSize();
                var rect = cc.rect(_posX-_size/2, _posY-_size/2, _size, _size);
                //点到当前金子单元
                if(cc.rectContainsPoint(rect, p)){
                    //当前单元是金子
                    if(this._goldCell[r][c] == this._gold){
                        //进入下一关
                        this._level += 1;
                        //动画隐藏，换关卡后动画显示
                        this.runAction(cc.sequence(new cc.CallFunc(this.hideGoldMatrix,this),
                            cc.delayTime(0.3), new cc.CallFunc(this.showGoldMatrix,this)
                        ));
                        return Result.success;
                    }else{
                        //当前单元不是金子，金子单元闪烁
                        this._gold.runAction(new cc.blink(0.7, 5));
                        return Result.failure;
                    }
                }
            }
        }
        //点击无效
        return Result.invalid;
    },
    //获取当前关卡
    getCurrentLevel : function () {
        return this._level;
    },
    //获取当前成绩
    getCurrentScore : function () {
        return this._level - 1;
    }
})
