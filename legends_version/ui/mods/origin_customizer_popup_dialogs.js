

OriginCustomizerScreen.prototype.createScenarioPopupDialog = function() 
{
    var self = this;

    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.character-screen').createPopupDialog('Origins', '', null, 'scenarios-popup');

    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog)
    {
        //self.updateSelectedScenario(_dialog);
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog)
    {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });

    this.mCurrentPopupDialog.addPopupDialogContent(this.createScenarioDialogContent(this.mCurrentPopupDialog));

    this.mCurrentPopupDialog.findPopupDialogFooterContainer().css('border', '2px solid red');
    this.mCurrentPopupDialog.findPopupDialogTitle().css('border', '2px solid green');
    this.mCurrentPopupDialog.findPopupDialogSubTitle().css('border', '2px solid yellow');
};
OriginCustomizerScreen.prototype.createScenarioDialogContent = function(_dialog) 
{
    var self = this;
    var content = $('<div class="scenarios-content-container"/>');

    return content;
};