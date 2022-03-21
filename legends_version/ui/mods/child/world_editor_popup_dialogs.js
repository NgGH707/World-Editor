

WorldEditorScreen.prototype.createScenarioPopupDialog = function() 
{
    var self = this;

    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.origin-customizer-screen').createPopupDialog('Origins', '', null, 'scenarios-popup');

    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog)
    {
        //self.notifyBackendUpdateScenario(self.mScenario.Selected);
        self.mCurrentPopupDialog = null;
        self.mScenario.Description = null;
        self.mScenario.ListContainer = null;
        self.mScenario.ListScrollContainer = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog)
    {
        self.mCurrentPopupDialog = null;
        self.mScenario.Description = null;
        self.mScenario.ListContainer = null;
        self.mScenario.ListScrollContainer = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });

    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left');
    this.mCurrentPopupDialog.findPopupDialogOkButton().addClass('move-to-right');
    this.mCurrentPopupDialog.addPopupDialogContent(this.createScenarioDialogContent(this.mCurrentPopupDialog));
    this.mScenario.ListContainer.aciScrollBar({delta: 1.77, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    this.mScenario.ListScrollContainer = this.mScenario.ListContainer.findListScrollContainer();
    var descriptionContainer = this.mScenario.Description.createList(10, 'description-font-medium font-color-description');
    this.mScenario.Description = descriptionContainer.findListScrollContainer();
    this.addScenariosToList(this.mScenario.Data);
};
WorldEditorScreen.prototype.createScenarioDialogContent = function(_dialog) 
{
    var self = this;
    var content = $('<div class="scenarios-content-container"/>');

    var scenarioListContainerLayout = $('<div class="l-list-container"></div>');
    content.append(scenarioListContainerLayout);

    this.mScenario.ListContainer = $('<div class="ui-control list has-frame"/>');
    scenarioListContainerLayout.append(this.mScenario.ListContainer);
    var scrollContainer = $('<div class="scroll-container"/>');
    this.mScenario.ListContainer.append(scrollContainer);

    this.mScenario.Description = $('<div class="l-description-container"></div>');
    content.append(this.mScenario.Description);

    return content;
};

WorldEditorScreen.prototype.addScenarioEntryToList = function (_data)
{
    var row = $('<div class="l-row"/>');
    var entry = $('<div class="list-entry list-entry-small-fit"><span class="label text-font-normal font-color-label">' + _data.Name + '</span></div></div>');
    entry.data('scenario', _data);

    entry.click(this, function(_event) {
        var self = _event.data;
        var buttonDiv = $(this);

        if (buttonDiv.hasClass('is-selected') !== true)
        {
            self.mScenario.ListScrollContainer.find('.is-selected:first').each(function (_index, _element)
            {
                $(_element).removeClass('is-selected');
            });

            buttonDiv.addClass('is-selected');
            self.mScenario.Selected = buttonDiv.data('scenario').ID;
        }
    });

    entry.mouseenter(this, function(_event) {
        _event.data.updateScenarioDescription($(this).data('scenario'));
    });

    entry.mouseleave(this, function(_event) {
        var self = _event.data;
    
        var selectedEntry = self.mScenario.ListScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0)
        {
            self.updateScenarioDescription(selectedEntry.data('scenario'));
        }
    });

    row.append(entry);
    this.mScenario.ListScrollContainer.append(row);
};

WorldEditorScreen.prototype.addScenariosToList = function (_scenarios)
{
    if (_scenarios !== null && jQuery.isArray(_scenarios))
    {
        this.mScenario.ListScrollContainer.empty();

        for (var i = 0; i < _scenarios.length; ++i)
        {
            if (!('ID' in _scenarios[i]))
            {
                console.error('ERROR: Failed to find "ID" field while interpreting scenario data.');
                continue;
            }

            if (!('Name' in _scenarios[i]))
            {
                console.error('ERROR: Failed to find "Name" field while interpreting scenario data. ID: ' + _scenarios[i].ID);
                continue;
            }

            this.addScenarioEntryToList(_scenarios[i]);
        }

        this.selectFirstScenario();
    }
};


WorldEditorScreen.prototype.selectFirstScenario = function()
{
    // deselect all entries first
    this.mScenario.ListScrollContainer.find('.is-selected').each(function (index, el)
    {
        $(el).removeClass('is-selected');
    });

    var firstEntry = this.mScenario.ListScrollContainer.find('.l-row:first');
    if (firstEntry.length > 0)
    {
        var entry = firstEntry.find('.list-entry:first');
        entry.addClass('is-selected');
        this.mScenario.Selected = entry.data('scenario').ID;
        this.updateScenarioDescription(entry.data('scenario'));
    }
};

WorldEditorScreen.prototype.updateScenarioDescription = function (_data)
{
    if (_data !== null && 'Description' in _data && typeof(_data.Description) == 'string')
    {
        var parsedText = XBBCODE.process(
        {
            text: _data.Description,
            removeMisalignedTags: false,
            addInLineBreaks: true
        });
                                    
        this.mScenario.Description.html(parsedText.html);
    }
    else
    {
        console.error('ERROR: Failed to find "Description" field while interpreting scenario data. ID: ' + _data.ID);
    }
};