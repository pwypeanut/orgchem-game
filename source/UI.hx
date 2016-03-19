package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

using flixel.util.FlxSpriteUtil;

class UI extends SandboxUI
{

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);

		var _boxWidth = 550, _boxHeight = 270, _borderWidth = 12;
		
		_sprMainBox = new FlxSprite((_stageWidth - _boxWidth - _borderWidth) / 2, 50);
		_sprMainBox.makeGraphic(_boxWidth + _borderWidth, _boxHeight + _borderWidth);
		_sprMainBox.drawRoundRect(_borderWidth / 2, _borderWidth / 2, _boxWidth, _boxHeight, 25, 25, 0xfff0f0f0, { thickness: _borderWidth, color: 0xff111111 });
		add(_sprMainBox);
		
		_txtScore = new FlxText(0, _boxHeight / 2 + 50, _stageWidth);
		
		_txtScore.setFormat(40);
		_txtScore.color = 0xff333333;
		_txtScore.text = "01231312321";
		_txtScore.alignment = "center";
		add(_txtScore);
		
		var _btnWidth = 158 / 2;
		
		_btnClear = new FlxButton((_stageWidth - _boxWidth) / 2 - _btnWidth + 20, 50 + _boxHeight - _btnWidth - 20);
		_btnClear.loadGraphic("assets/images/oc_Cancel Button.png", false, 158, 158);
		_btnClear.scale.set(0.5, 0.5);
		_btnClear.updateHitbox();
		_btnClear.onUp.callback = Reg.ps.clearGrid;
		add(_btnClear);
		
		_btnUndo = new FlxButton((_stageWidth - _boxWidth) / 2 - _btnWidth + 20, 50 + _boxHeight - _btnWidth * 2 - 30);
		_btnUndo.loadGraphic("assets/images/oc_Undo Button.png", false, 158, 158);
		_btnUndo.scale.set(0.5, 0.5);
		_btnUndo.updateHitbox();
		_btnUndo.onUp.callback = Reg.ps.undoMove;
		add(_btnUndo);
		
		_btnConfirm = new FlxButton((_stageWidth + _boxWidth) / 2 - 20, 50 + _boxHeight - _btnWidth - 20);
		_btnConfirm.loadGraphic("assets/images/oc_Confirm Button.png", false, 158, 158);
		_btnConfirm.scale.set(0.5, 0.5);
		_btnConfirm.updateHitbox();
		_btnConfirm.onUp.callback = Reg.ps.submitMolecule;
		add(_btnConfirm);
		
		_txtName.kill();
		remove(_btnMainMenu);
		
		_timeLeftBar = new FlxBar(0, 0, FlxBar.FILL_TOP_TO_BOTTOM, 15, _stageHeight);
		_timeLeftBar.createFilledBar(0, 0xaa0071BC);
		add(_timeLeftBar);
		
		_modal = new Modal();
		add(_modal);
		
		_btnToggleModal = new FlxButton(50, _stageHeight - 75 - 50);
		_btnToggleModal.loadGraphic("assets/images/oc_Hide Button.png", false, 400, 150);
		_btnToggleModal.scale.set(0.5, 0.5);
		_btnToggleModal.updateHitbox();
		_btnToggleModal.kill();
		_btnToggleModal.onUp.callback = Reg.ps.toggleModal;
		add(_btnToggleModal);
		
		_countdownOverlay = new FlxSprite(0, 0);
		_countdownOverlay.makeGraphic(_stageWidth, _stageHeight, 0xdd000000);
		add(_countdownOverlay);
		
		_gameOverOverlay = new FlxSprite(0, 0);
		_gameOverOverlay.makeGraphic(_stageWidth, _stageHeight, 0xdd000000);
		_gameOverOverlay.kill();
		add(_gameOverOverlay);
		
		_gameOverText = new FlxText(0, _stageHeight / 2 - 100, _stageWidth);
		_gameOverText.setFormat(200);
		_gameOverText.alignment = "center";
		_gameOverText.text = "0";
		_gameOverText.color = 0xffffffff;
		_gameOverText.kill();
		add(_gameOverText);
		
		_gameOverHeader = new FlxText(0, _stageHeight / 2 - 200, _stageWidth);
		_gameOverHeader.setFormat(50);
		_gameOverHeader.alignment = "center";
		_gameOverHeader.text = "FINAL SCORE";
		_gameOverHeader.color = 0xffffffff;
		_gameOverHeader.kill();
		add(_gameOverHeader);
		
		_countdownText = new FlxText(0, _stageHeight / 2 - 100, _stageWidth);
		_countdownText.setFormat(200);
		_countdownText.alignment = "center";
		_countdownText.text = "3";
		_countdownText.color = 0xffffffff;
		add(_countdownText);
		
		//_btnMainMenu.kill();
		_btnMainMenu.x = (_stageWidth - _btnMainMenu.width) / 2;
		_btnMainMenu.y = (_stageHeight - 200);
		
		add(_btnMainMenu);
		_btnMainMenu.kill();
	}
	
	override public function destroy()
	{
		_sprMainBox = FlxDestroyUtil.destroy(_sprMainBox);
		_btnClear = FlxDestroyUtil.destroy(_btnClear);
		_btnUndo = FlxDestroyUtil.destroy(_btnUndo);
		_txtName = FlxDestroyUtil.destroy(_txtName);
		_timeLeftBar = FlxDestroyUtil.destroy(_timeLeftBar);
		
		super.destroy();
	}
	
}