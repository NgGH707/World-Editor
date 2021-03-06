
/*
    Choose Scenario
*/
WorldEditorScreen.prototype.createScenarioPopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Origins', '', null, 'scenarios-popup');

    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = self.mScenario.ListScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0 && self.mScenario.Selected !== selectedEntry.data('index')) {
            self.notifyBackendUpdateScenario(selectedEntry.data('index'));
        }
        self.mCurrentPopupDialog = null;
        self.mScenario.Description = null;
        self.mScenario.ListContainer = null;
        self.mScenario.ListScrollContainer = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
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
WorldEditorScreen.prototype.addScenarioEntryToList = function (_data, _index)
{
    var row = $('<div class="l-row"/>');
    this.mScenario.ListScrollContainer.append(row);
    var entry = $('<div class="list-entry list-entry-small-fit"><span class="label text-font-normal font-color-label">' + _data.Name + '</span></div></div>');
    row.append(entry);
    entry.data('scenario', _data);
    entry.data('index', _index)

    if (this.mScenario.Selected === _index)
        entry.addClass('is-selected');

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

            this.addScenarioEntryToList(_scenarios[i], i);
        }

        this.updateScenarioDescription(this.mScenario.Data[this.mScenario.Selected]);
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




/*
    Faction Leaders
*/
WorldEditorScreen.prototype.createFactionLeadersPopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    var result = this.createFactionLeadersDialogContent(this.mCurrentPopupDialog)
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Faction Leadership', null, null, 'leader-popup');
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);
    this.notifyBackendGetFactionLeaders(result.Character);

    var button = result.ButtonLayout.createImageButton(Path.GFX + 'ui/icons/cursor_rotate.png', function () {
        self.notifyBackendRefreshFactionLeader(result.Character);
    }, '', 6);
    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.reload_leader' });

    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
};
WorldEditorScreen.prototype.createFactionLeadersDialogContent = function(_dialog) 
{
    var self = this;
    var content = $('<div class="leader-content-container"/>');
    var characterContainer = $('<div class="character-container"/>');
    content.append(characterContainer);
    var buttonLayout = $('<div class="reset-leader-button"/>');
    content.append(buttonLayout);

    return {
        Content: content,
        Character: characterContainer,
        ButtonLayout: buttonLayout
    }
};
WorldEditorScreen.prototype.addFactionLeaderToPopup = function(_data, _container) 
{
    _container.empty();

    for (var i = 0; i < _data.length; i++) {
        var entry = _data[i];
        var character = $('<div class="character"/>');
        character.css('left', (3.0 + 12.0 * i) + 'rem');
        var characterImage = character.createImage(Path.PROCEDURAL + entry.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        characterImage.centerImageWithinParent(0, 0, 1.0);
        characterImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterNameAndTitles, entityId: entry.ID });
        _container.append(character);
    }
};




/*
    Faction Alliance
*/
WorldEditorScreen.prototype.createChooseFactionAlliancePopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Faction Alliance', '', null, 'alliance-popup');

    // create: content
    var result = this.createChooseFactionAllianceDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // create: list
    result.LeftListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var leftListScrollContainer = result.LeftListContainer.findListScrollContainer();

    result.RightListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var rightListScrollContainer = result.RightListContainer.findListScrollContainer();

    var midColumnContent = $('<div class="mid-column-content"/>');
    result.MidColumn.append(midColumnContent);
    var buttonContainer = $('<div class="button-container"/>');
    midColumnContent.append(buttonContainer);
    var layout = $('<div class="l-button is-transfer-right"/>');
    buttonContainer.append(layout);
    var button = layout.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function() {
        leftListScrollContainer.find('.is-troop-slot').each(function (_index, _element)
        {
            var div = $(_element);
            var entry = div.find('.troop-panel:first');
            var data = entry.data('entry');
            if (entry.hasClass('is-selected')) {
                self.createFactionAllianceEntry(data, rightListScrollContainer);
                div.remove();
            }
        });
    }, '', 6);

    var layout = $('<div class="l-button is-transfer-left"/>');
    buttonContainer.append(layout);
    var button = layout.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function() {
        rightListScrollContainer.find('.is-troop-slot').each(function (_index, _element)
        {
            var div = $(_element);
            var entry = div.find('.troop-panel:first');
            var data = entry.data('entry');
            if (entry.hasClass('is-selected')) {
                self.createFactionAllianceEntry(data, leftListScrollContainer);
                div.remove();
            }
        });
    }, '', 6);


    // add the ok button
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var ids = {Allies: [], Hostile: []};
        leftListScrollContainer.find('.troop-panel').each(function (_index, _element)
        {
            var entry = $(_element);
            ids.Allies.push(entry.data('entry').ID);
        });
        rightListScrollContainer.find('.troop-panel').each(function (_index, _element)
        {
            var entry = $(_element);
            ids.Hostile.push(entry.data('entry').ID);
        });
        self.notifyBackendUpdateFactionAlliance(ids);
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogOkButton().addClass('move-to-right');
    
    // add the cancel button
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left');
    
    this.notifyBackendToCollectAllianceData([leftListScrollContainer, rightListScrollContainer]);
};
WorldEditorScreen.prototype.createChooseFactionAllianceDialogContent = function(_dialog) 
{
    var content = $('<div class="alliance-content-container"/>');

    var tab = $('<div class="alliance-tab-container"/>');
    content.append(tab);
    var leftColumn = $('<div class="side-column"/>');
    tab.append(leftColumn);
    var header = $('<div class="is-header title-font-big font-bold font-color-title">Allies</div>');
    leftColumn.append(header);

    var midColumn = $('<div class="mid-column"/>');
    tab.append(midColumn);

    var rightColumn = $('<div class="side-column"/>');
    tab.append(rightColumn);
    var header = $('<div class="is-header title-font-big font-bold font-color-title">Enemies</div>');
    rightColumn.append(header);

    var container = $('<div class="alliance-container"/>');
    content.append(container);

        var leftColumn = $('<div class="side-column"/>');
        leftColumn.css('background-image', 'url("coui://gfx/ui/skin/tooltip_315_bottom.png")');
        leftColumn.css('background-size', '100% 100%');
        leftColumn.css('background-repeat', 'no-repeat');
        container.append(leftColumn);
        {
            var containerForList = $('<div class="l-list-container"></div>');
            leftColumn.append(containerForList);
            var leftListContainer = $('<div class="ui-control list has-frame"/>');
            containerForList.append(leftListContainer);
            var scrollContainer = $('<div class="scroll-container"/>');
            leftListContainer.append(scrollContainer);
        }

        var midColumn = $('<div class="mid-column"/>');
        container.append(midColumn);

        var rightColumn = $('<div class="side-column"/>');
        rightColumn.css('background-image', 'url("coui://gfx/ui/skin/combat_log_bottom.png")'); // i'm too lazy to add a css element for it XD
        rightColumn.css('background-size', '100% 100%');
        rightColumn.css('background-repeat', 'no-repeat');
        container.append(rightColumn);
        {
            var containerForList = $('<div class="l-list-container"></div>');
            rightColumn.append(containerForList);
            var rightListContainer = $('<div class="ui-control list has-frame"/>');
            containerForList.append(rightListContainer);
            var scrollContainer = $('<div class="scroll-container"/>');
            rightListContainer.append(scrollContainer);
        }

    return {
        Content: content,
        LeftListContainer: leftListContainer,
        RightListContainer: rightListContainer,
        MidColumn: midColumn,
    };
};
WorldEditorScreen.prototype.addFactionAllianceToPopupDialog = function(_data, _listScrollContainers) 
{
    var dataBase = this.mFaction.Data;

    _listScrollContainers[0].empty();
    for (var i = 0; i < _data.Allies.length; ++i)
    {
        this.createFactionAllianceEntry(dataBase[_data.Allies[i]], _listScrollContainers[0]);
    }

    _listScrollContainers[1].empty();
    for (var i = 0; i < _data.Hostile.length; ++i)
    {
        this.createFactionAllianceEntry(dataBase[_data.Hostile[i]], _listScrollContainers[1]);
    }
};
WorldEditorScreen.prototype.createFactionAllianceEntry = function(_data, _listScrollContainer) 
{
    var result = $('<div class="ui-control is-troop-slot"/>');
    result.css('width', '33.5rem');
    _listScrollContainer.append(result);

    var entry = $('<div class="ui-control troop-panel"/>');
    result.append(entry);
    entry.data('entry', _data);


    // icon
    var leftColumn = $('<div class="column-is-25"/>');
    entry.append(leftColumn);
    var iconLayout = $('<div class="banner-icon"/>');  
    leftColumn.append(iconLayout);
    var icon = iconLayout.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.fitImageToParent(0, 0);
    }, null, '');

    var rightColumn = $('<div class="column-is-75"/>');
    entry.append(rightColumn);
    
    // for name
    var row = $('<div class="row-half"/>');
    rightColumn.append(row);
    var name = $('<div class="troop-name title-font-normal font-bold font-color-title">' + _data.Name + '</div>');
    row.append(name);

    var checkboxContainer = $('<div class="check-box-container"/>');
    rightColumn.append(checkboxContainer);
    var imageContainer = $('<div class="check-box"/>');
    checkboxContainer.append(imageContainer);
    var image = imageContainer.createImage(Path.GFX + 'ui/skin/hud_button_01_default.png', function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
    }, null, '');

    // set up event listener
    entry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') === true) {
            div.removeClass('is-selected');
            image.attr('src', Path.GFX + 'ui/skin/hud_button_01_default.png');
        }
        else {
            div.addClass('is-selected');
            image.attr('src', Path.GFX + 'ui/skin/hud_button_01_checked.png');
        }
    });
};


/*
    Choose Home/Origin For Contract
*/
WorldEditorScreen.prototype.createChooseLocationForContractPopupDialog = function(_type) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Pick a Place', '', null, 'troops-popup');

    // create: content
    var result = this.createChooseFactionDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // create: list
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();

    // add the ok button
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            self.notifyBackendChangeLocationForContract(_type, selectedEntry.data('ID'));
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add the cancel button
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left');
    this.mCurrentPopupDialog.findPopupDialogOkButton().addClass('move-to-right');

    switch(_type)
    {
    case 'Home':
    case 'Origin':
        this.addSettlementsOfThisFactionToPopupDialog(listScrollContainer, _type);
        break;

    case 'Objective':
        //this.addSettlementsOfThisFactionToPopupDialog(listScrollContainer, button);
        break;
    }
};
WorldEditorScreen.prototype.addSettlementsOfThisFactionToPopupDialog = function(_listScrollContainer, _type) 
{
    var entry = this.mContract.Selected.data('entry');
    var factionID = entry.Faction;
    var enitytID = entry[_type];
    _listScrollContainer.empty();

    for (var i = 0; i < this.mSettlement.Data.length; i++) {
        var data = this.mSettlement.Data[i];
        if (data.Faction === factionID || data.Owner === factionID) {
            this.addSettlementEntriesToPopUpDialog(data, _listScrollContainer, enitytID === data.ID); 
        }
    }
};




/*
    Choose Faction For Contract
*/
WorldEditorScreen.prototype.createChooseFactionForContractPopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Choose Faction', '', null, 'troops-popup');

    // create: content
    var result = this.createChooseFactionDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // create: list
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();

    // add the ok button
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            self.notifyBackendChangeContractFaction(selectedEntry.data('ID'));
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add the cancel button
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left');

    var button = this.mCurrentPopupDialog.findPopupDialogOkButton();
    button.addClass('move-to-right');
    button.enableButton(false);

    this.addSettlementFactionToPopupDialog(listScrollContainer, button);
};
WorldEditorScreen.prototype.addSettlementFactionToPopupDialog = function(_listScrollContainer, _button) 
{
    var selectedID = this.mContract.Selected.data('entry').Faction;
    _listScrollContainer.empty();

    for (var i = 0; i < this.mFaction.Data.length; ++i)
    {
        var data = this.mFaction.Data[i];

        if (data.Type === 2 || data.Type === 3 || data.Type === 13)
        {
            this.createChooseFactionEntry(data, _listScrollContainer, _button, data.ID === selectedID);
        }
    }
};


/*
    Choose Faction
*/
WorldEditorScreen.prototype.createChooseFactionPopupDialog = function(_selectedEntryData, _isChoosingOwner, _isLocation) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Choose Faction', '', null, 'troops-popup');

    // create: content
    var result = this.createChooseFactionDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // create: list
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();

    // add the ok button
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            if (_isChoosingOwner === true)
                self.notifyBackendUpdateNewOwnerFor(_selectedEntryData.ID , selectedEntry.data('ID'));
            else
                self.notifyBackendUpdateNewFactionFor(_selectedEntryData.ID , selectedEntry.data('ID'), _selectedEntryData.Faction);
        }

        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add the cancel button
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left');

    var button = this.mCurrentPopupDialog.findPopupDialogOkButton();
    button.addClass('move-to-right');
    button.enableButton(false);

    if (_isLocation === true)
        this.addFactionToPopupDialog([], listScrollContainer, button, _selectedEntryData.Faction);
    else
        this.notifyBackendGetAllNonHostileFactionsOfThisFaction(listScrollContainer, button, _isChoosingOwner === true ? _selectedEntryData.Owner : _selectedEntryData.Faction);
};
WorldEditorScreen.prototype.createChooseFactionDialogContent = function(_dialog) 
{
    var content = $('<div class="troops-content-container"/>');

    var tab = $('<div class="troops-tab-container"/>');
    content.append(tab);

    var container = $('<div class="l-list-container"></div>');
    content.append(container);

    var listContainer = $('<div class="ui-control list has-frame"/>');
    container.append(listContainer);
    var scrollContainer = $('<div class="scroll-container"/>');
    listContainer.append(scrollContainer);

    return {
        Content: content,
        ListContainer: listContainer
    };
};
WorldEditorScreen.prototype.addFactionToPopupDialog = function(_IDs, _listScrollContainer, _button, _selectedID) 
{
    _listScrollContainer.empty();

    for (var i = 0; i < this.mFaction.Data.length; ++i)
    {
        var data = this.mFaction.Data[i];

        if (_IDs.length > 0 && _IDs.indexOf(data.ID) < 0)
            continue;
        else
            this.createChooseFactionEntry(data, _listScrollContainer, _button, data.ID === _selectedID);
    }
};
WorldEditorScreen.prototype.createChooseFactionEntry = function(_data, _listScrollContainer, _button, _isSelected) 
{
    var result = $('<div class="ui-control is-troop-slot"/>');
    _listScrollContainer.append(result);

    var entry = $('<div class="ui-control troop-panel"/>');
    result.append(entry);
    entry.data('ID', _data.ID);

    if (_isSelected === true)
        entry.addClass('is-selected');

    // icon
    var leftColumn = $('<div class="column-is-25"/>');
    entry.append(leftColumn);
    var iconLayout = $('<div class="banner-icon"/>');  
    leftColumn.append(iconLayout);
    var icon = iconLayout.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.fitImageToParent(0, 0);
    }, null, '');

    var rightColumn = $('<div class="column-is-75"/>');
    entry.append(rightColumn);
    
    // for name
    var row = $('<div class="row-half"/>');
    rightColumn.append(row);
    var name = $('<div class="troop-name title-font-normal font-bold font-color-title">' + _data.Name + '</div>');
    row.append(name);

    // set up event listener
    entry.click(this, function(_event) {
        var entryDiv = $(this);
        if (entryDiv.hasClass('is-selected') === false) {
            _button.enableButton(true);
            _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                $(_element).removeClass('is-selected');
            });
            entryDiv.addClass('is-selected');
        }
    });
};




/*
    Change World Entity Banner
*/
WorldEditorScreen.prototype.createChangeWorldEntityBannerPopupDialog = function(_element) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Change Banner', null, null, 'choose-building-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createBuildingPopupDialogContent(this.mCurrentPopupDialog); 
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            self.notifyBackendChangeWorldEntityBanner(_element, selectedEntry.data('sprite'));
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add building entries so you can pick one
    this.notifyBackendGetBannerSpriteEntries(_element, listScrollContainer);
};
WorldEditorScreen.prototype.addBannerSpriteEntriesToPopupDialog = function(_data, _listScrollContainer) 
{
    for (var i = 0; i < _data.length; i++) {
        var entry = $('<div class="is-banner-slot"/>');
        entry.data('sprite', _data[i].Sprite);
        _listScrollContainer.append(entry);

        if (i == 0)
            entry.addClass('is-selected');

        var image = entry.createImage(Path.GFX + _data[i].ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        // set up event listeners
        entry.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') === false) {
                _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                    $(_element).removeClass('is-selected');
                });
                div.addClass('is-selected');
            }
        });
    }
};




/*
    Change Unit Sprite
*/
WorldEditorScreen.prototype.createChangeUnitSpritePopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Change Sprite', null, null, 'choose-building-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createBuildingPopupDialogContent(this.mCurrentPopupDialog); 
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            self.notifyBackendChangeUnitSprite(selectedEntry.data('sprite'));
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add building entries so you can pick one
    this.notifyBackendGetUnitSpriteEntries(listScrollContainer);
};
WorldEditorScreen.prototype.addUnitSpriteEntriesToPopupDialog = function(_data, _listScrollContainer) 
{
    for (var i = 0; i < _data.length; i++) {
        var entry = $('<div class="is-party-slot"/>');
        entry.data('sprite', _data[i].Sprite);
        _listScrollContainer.append(entry);

        if (i == 0)
            entry.addClass('is-selected');

        var image = entry.createImage(Path.GFX + _data[i].ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        // set up event listeners
        entry.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') === false) {
                _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                    $(_element).removeClass('is-selected');
                });
                div.addClass('is-selected');
            }
        });
    }
};




/*
    Change Location Sprite
*/
WorldEditorScreen.prototype.createChangeLocationSpritePopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Change Sprite', null, null, 'choose-building-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createBuildingPopupDialogContent(this.mCurrentPopupDialog); 
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            self.notifyBackendChangeLocationSprite(selectedEntry.data('sprite'));
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add building entries so you can pick one
    this.notifyBackendGetLocationSpriteEntries(listScrollContainer);
};
WorldEditorScreen.prototype.addLocationSpriteEntriesToPopupDialog = function(_data, _listScrollContainer) 
{
    for (var i = 0; i < _data.length; i++) {
        var entry = $('<div class="is-building-slot"/>');
        entry.data('sprite', _data[i].Sprite);
        _listScrollContainer.append(entry);

        if (i == 0)
            entry.addClass('is-selected');

        var image = entry.createImage(Path.GFX + _data[i].ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        // set up event listeners
        entry.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') === false) {
                _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                    $(_element).removeClass('is-selected');
                });
                div.addClass('is-selected');
            }
        });
    }
};




/*
    Add new contract
*/
WorldEditorScreen.prototype.createAddContractPopupDialog = function() 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Add Contract', null, null, 'choose-building-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createBuildingPopupDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var script;
        listScrollContainer.find('input').each(function(index, element) {
            var checkbox = $(element);
            if (checkbox.is(':checked') === true) {
                script = checkbox.data('script');
            }
        });
        self.notifyBackendAddNewContract(script);
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add contract entries so you can pick one
    this.notifyBackendGetAvailableContracts(listScrollContainer, this.mCurrentPopupDialog.findPopupDialogOkButton());
};
WorldEditorScreen.prototype.addContractEntriesToPopupDialog = function(_data, _listScrollContainer, _button) 
{
    for (var i = 0; i < _data.length; i++) {
        this.createContractEntryToPopupDialog(_data[i], _listScrollContainer, _button);
    }
};
WorldEditorScreen.prototype.createContractEntryToPopupDialog = function(_data, _listScrollContainer, _button) 
{
    var row = $('<div class="row"></div>');
    _listScrollContainer.append(row);
    var control = $('<div class="control"/>');
    row.append(control);
    var checkbox = $('<input type="radio" id="' + _data.Type + '" name="contract" />');
    control.append(checkbox);
    var label = $('<label class="text-font-normal font-color-ink" for="' + _data.Type + '">' + _data.Name + '</label>');
    control.append(label);
    checkbox.iCheck({
        checkboxClass: 'icheckbox_flat-orange',
        radioClass: 'iradio_flat-orange',
        increaseArea: '30%'
    });
    checkbox.on('ifChecked', null, this, function(_event) {
        var self = _event.data;
        _button.enableButton(true);
    });
    checkbox.data('script', _data.Script);
};





/*
    Add Troop Dialog
*/
WorldEditorScreen.prototype.createAddTroopPopupDialog = function(_element) 
{
    var self = this;
    this.mTroop.Selected = [];
    this.mTroop.Filter = 0;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('Add Troop', 'Selected: 0', null, 'troops-popup');

    // create: content
    var subTitle = this.mCurrentPopupDialog.findPopupDialogSubTitle();
    var result = this.createAddTroopDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // create: list
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();

    var buttonLayout = $('<div class="l-tab-button is-deselect-all"/>');
    result.Tab.append(buttonLayout);
    var button = buttonLayout.createTextButton("Deselect All", function() {
        listScrollContainer.find('.is-selected').each(function(_index, _element) {
            var div = $(_element)
            div.removeClass('is-selected');
            var result = div.find('.check-image:first').find('img:first');
            result.attr('src', Path.GFX + 'ui/skin/hud_button_01_default.png');
        });
        self.mTroop.Selected = [];
        subTitle.html('Selected: 0');
    }, null, 4);

    var buttonLayout = $('<div class="l-tab-button is-filter-all"/>');
    result.Tab.append(buttonLayout);
    var button = buttonLayout.createTextButton("All", function() {
        if (self.mTroop.Filter !== 0) {
            self.mTroop.Filter = 0;
            self.notifyBackendGetTroopEntries({
                ListScrollContainer: listScrollContainer,
                SubTitle: subTitle
            });
        }
    }, null, 2);
    var buttonLayout = $('<div class="l-tab-button is-filter-human"/>');
    result.Tab.append(buttonLayout);
    var button = buttonLayout.createTextButton("Human", function() {
        if (self.mTroop.Filter !== 1) {
            self.mTroop.Filter = 1;
            self.notifyBackendGetTroopEntries({
                ListScrollContainer: listScrollContainer,
                SubTitle: subTitle
            });
        }
    }, null, 2);
    var buttonLayout = $('<div class="l-tab-button is-filter-undead"/>');
    result.Tab.append(buttonLayout);
    var button = buttonLayout.createTextButton("Undead", function() {
        if (self.mTroop.Filter !== 2) {
            self.mTroop.Filter = 2;
            self.notifyBackendGetTroopEntries({
                ListScrollContainer: listScrollContainer,
                SubTitle: subTitle
            });
        }
    }, null, 2);
    var buttonLayout = $('<div class="l-tab-button is-filter-greenskin"/>');
    result.Tab.append(buttonLayout);
    var button = buttonLayout.createTextButton("Greenskin", function() {
        if (self.mTroop.Filter !== 3) {
            self.mTroop.Filter = 3;
            self.notifyBackendGetTroopEntries({
                ListScrollContainer: listScrollContainer,
                SubTitle: subTitle
            });
        }
    }, null, 2);
    var buttonLayout = $('<div class="l-tab-button is-filter-misc"/>');
    result.Tab.append(buttonLayout);
    var button = buttonLayout.createTextButton("Others", function() {
        if (self.mTroop.Filter !== 4) {
            self.mTroop.Filter = 4;
            self.notifyBackendGetTroopEntries({
                ListScrollContainer: listScrollContainer,
                SubTitle: subTitle
            });
        }
    }, null, 2);

    // add the ok button
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        self.notifyBackendAddNewTroop(_element);
        self.mTroop.Selected = [];
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogOkButton().addClass('move-to-right');
    
    // add the cancel button
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mTroop.Selected = [];
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left');

    // add data to the list
    this.notifyBackendGetTroopEntries(_element, {
        ListScrollContainer: listScrollContainer,
        SubTitle: subTitle
    });
};
WorldEditorScreen.prototype.createAddTroopDialogContent = function(_dialog) 
{
    var content = $('<div class="troops-content-container"/>');

    var tab = $('<div class="troops-tab-container"/>');
    content.append(tab);

    var container = $('<div class="l-list-container"></div>');
    content.append(container);

    var listContainer = $('<div class="ui-control list has-frame"/>');
    container.append(listContainer);
    var scrollContainer = $('<div class="scroll-container"/>');
    listContainer.append(scrollContainer);

    return {
        Content: content,
        Tab: tab,
        ListContainer: listContainer
    };
};
WorldEditorScreen.prototype.addTroopEntriesToPopupDialog = function(_entries, _listScrollContainer, _subTitle) 
{
    if (_entries !== null && jQuery.isArray(_entries)) {
        _listScrollContainer.empty();
        for (var i = 0; i < _entries.length; ++i) {
            var data = _entries[i];
            this.createTroopEntry(data, _listScrollContainer, _subTitle);
        }
    }
};
WorldEditorScreen.prototype.createTroopEntry = function(_data, _listScrollContainer, _subTitle) 
{
    var result = $('<div class="ui-control is-troop-slot"/>');
    _listScrollContainer.append(result);

    var isSelected = this.mTroop.Selected.indexOf(_data.Key) > 0;
    var entry = $('<div class="ui-control troop-panel"/>');
    result.append(entry);
    entry.data('entry', _data);

    if (isSelected === true)
        entry.addClass('is-selected');

    // icon
    var leftColumn = $('<div class="column-is-25"/>');
    entry.append(leftColumn);
    var iconLayout = $('<div class="troop-icon"/>');  
    leftColumn.append(iconLayout);
    var icon = iconLayout.createImage(Path.GFX + _data.Icon, function(_image) {
        _image.fitImageToParent(0, 0);
    }, null, '');

    var rightColumn = $('<div class="column-is-75"/>');
    entry.append(rightColumn);
    
    var row = $('<div class="row-half"/>');
    rightColumn.append(row);
    
    // to display the cost of this troop entry
    var column = $('<div class="column-is-30"/>');
    row.append(column);
    var iconLayout = $('<div class="strength-icon"/>');
    column.append(iconLayout);
    var image = iconLayout.createImage(Path.GFX + 'ui/icons/money2.png', function(_image) {
        _image.fitImageToParent(0, 0);
    }, null, '');
    //image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.partystrength' });
    var name = $('<div class="strength-label title-font-normal font-bold font-color-white">' + _data.Cost + '</div>');
    column.append(name);

    // to display the strength of this troop entry contributes
    var column = $('<div class="column-is-30"/>');
    row.append(column);
    var iconLayout = $('<div class="strength-icon"/>');
    column.append(iconLayout);
    var image = iconLayout.createImage(Path.GFX + 'ui/icons/fist.png', function(_image) {
        _image.fitImageToParent(0, 0);
    }, null, '');
    image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.partystrength' });
    var name = $('<div class="strength-label title-font-normal font-bold font-color-white">' + _data.Strength + '</div>');
    column.append(name);

    //
    var column = $('<div class="column-is-20"/>');
    row.append(column);

    // 
    var column = $('<div class="column-is-20"/>');
    row.append(column);
    var iconLayout = $('<div class="check-image"/>');
    column.append(iconLayout);
    var check = iconLayout.createImage(Path.GFX + (isSelected === true ? 'ui/skin/hud_button_01_checked.png' : 'ui/skin/hud_button_01_default.png'), function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
    }, null, '');

    // for name
    var row = $('<div class="row-half"/>');
    rightColumn.append(row);
    var name = $('<div class="troop-name title-font-normal font-bold font-color-white">' + _data.Name + '</div>');
    row.append(name);

    // set up event listener
    entry.click(this, function(_event) {
        var self = _event.data;
        var entryDiv = $(this);
        if (entryDiv.hasClass('is-selected') === true) {
            var index = self.mTroop.Selected.indexOf(_data.Key);
            entryDiv.removeClass('is-selected');
            check.attr('src', Path.GFX + 'ui/skin/hud_button_01_default.png');
            if (index > 0)
                self.mTroop.Selected.splice(index, 1);
        }
        else {
            entryDiv.addClass('is-selected');
            check.attr('src', Path.GFX + 'ui/skin/hud_button_01_checked.png');
            self.mTroop.Selected.push(_data.Key);
        }
        _subTitle.html('Selected: ' + self.mTroop.Selected.length);
    });
};



/*
    Choose Attached Location
*/
WorldEditorScreen.prototype.createAttachedLocationPopupDialog = function(_isAttach) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog(_isAttach === true ? 'What To Build' : 'Choose Situation', null, null, 'choose-building-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createBuildingPopupDialogContent(this.mCurrentPopupDialog); 
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        if (_isAttach === true) {
            var selectedEntry = listScrollContainer.find('.is-selected:first');
            self.notifyBackendAttachedLocationToSlot(selectedEntry.data('script'));
        }
        else {
            var scripts = [];
            listScrollContainer.find('.is-selected').each(function (_index, _element) {
                scripts.push($(_element).data('script'));
            });
            self.notifyBackendAddSituationToSlot(scripts);
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add entries so you can pick one
    if (_isAttach === true)
        this.notifyBackendGetAttachedLocationEntries(listScrollContainer);
    else
        this.notifyBackendGetSituationEntries(listScrollContainer);
};
WorldEditorScreen.prototype.createBuildingPopupDialog = function(_slot) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog('What To Build', null, null, 'choose-building-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createBuildingPopupDialogContent(this.mCurrentPopupDialog); 
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        var selectedEntry = listScrollContainer.find('.is-selected:first');
        if (selectedEntry.length > 0) {
            self.notifyBackendAddBuildingToSlot(_slot, selectedEntry.data('script'));
        }
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add building entries so you can pick one
    this.notifyBackendGetBuildingEntries(listScrollContainer);
};
WorldEditorScreen.prototype.createBuildingPopupDialogContent = function(_dialog) 
{
    var content = $('<div class="b-content-container"/>');

    var container = $('<div class="l-list-container"></div>');
    content.append(container);

    var listContainer = $('<div class="ui-control list has-frame"/>');
    container.append(listContainer);
    var scrollContainer = $('<div class="scroll-container"/>');
    listContainer.append(scrollContainer);

    return {
        Content: content,
        ListContainer: listContainer
    };
};
WorldEditorScreen.prototype.addAttachedLocationEntriesToPopupDialog = function(_data, _listScrollContainer) 
{
    for (var i = 0; i < _data.length; i++) {
        var entry = _data[i];
        var slot = $('<div class="is-building-slot"/>');
        slot.data('script', entry.Script);
        _listScrollContainer.append(slot);

        if (i == 0)
            slot.addClass('is-selected');

        var image = slot.createImage(Path.GFX + entry.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        // set up event listeners
        slot.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') === false) {
                _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                    $(_element).removeClass('is-selected');
                });
                div.addClass('is-selected');
            }
        });
        image.bindTooltip({ contentType: 'ui-element', entityId: 0, elementId: entry.ID , elementOwner: 'woditor.attached_location'});
    }
};
WorldEditorScreen.prototype.addSituationEntriesToPopupDialog = function(_data, _listScrollContainer) 
{
    for (var i = 0; i < _data.length; i++) {
        var entry = _data[i];
        var slot = $('<div class="is-situation-slot"/>');
        slot.data('script', entry.Script);
        _listScrollContainer.append(slot);

        var image = slot.createImage(Path.GFX + entry.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        // set up event listeners
        slot.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') === false)
                div.addClass('is-selected');
            else
                div.removeClass('is-selected');
        });
        image.bindTooltip({ contentType: 'ui-element', entityId: 0, elementId: entry.ID , elementOwner: 'woditor.situations'});
    }
};
WorldEditorScreen.prototype.addBuildingEntriesToPopupDialog = function(_data, _listScrollContainer) 
{
    for (var i = 0; i < _data.length; i++) {
        var entry = _data[i];
        var slot = $('<div class="is-building-slot"/>');
        slot.data('script', entry.Script);
        _listScrollContainer.append(slot);

        if (i == 0)
            slot.addClass('is-selected');

        var image = slot.createImage(Path.GFX + entry.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, '');

        // set up event listeners
        slot.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') === false) {
                _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                    $(_element).removeClass('is-selected');
                });
                div.addClass('is-selected');
            }
        });
        image.bindTooltip({ contentType: 'ui-element', elementId: entry.TooltipId});
    }
};




/*
    Send Caravan
*/
WorldEditorScreen.prototype.createSendCaravanPopupDialog = function(_isCaravan) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-editor-screen').createPopupDialog(_isCaravan === true ? 'Send a Caravan To' : 'Send Mercenary To', null, null, 'send-caravan-popup');

    // create: content
    var result = this.createSendCaravanDialogContent(this.mCurrentPopupDialog);
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // create: drop down menu
    result.ExpandableList.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: true});
    result.ExpandableListScroll = result.ExpandableList.findListScrollContainer();

    // create: button to toggle drop down menu
    result.ExpandButton = result.ButtonLayout.createImageButton(Path.GFX + Asset.BUTTON_OPEN_EVENTLOG, function() {
        self.expandExpandableList(!result.IsExpanded, result, 20.0);
    }, '', 6);

    // create: list
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: true});
    result.ListScrollContainer = result.ListContainer.findListScrollContainer();

    // give the default resources for the caravan
    var resources = _isCaravan ? (this.mSettlement.Selected.data('entry').Resources * 0.5) : (150 + Math.floor(Math.random() * (350 - 60 + 1) ) + 60);
    result.Input.val('' + resources + '');

    // add the ok button
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        if (_isCaravan === true)
            self.notifyBackendSendCaravanTo(result);
        else
            self.notifyBackendSendMercenaryTo(result);

        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add the cancel button
    this.mCurrentPopupDialog.addPopupDialogCancelButton(function (_dialog) {
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    this.mCurrentPopupDialog.findPopupDialogCancelButton().addClass('move-to-left-abit');
    this.mCurrentPopupDialog.findPopupDialogOkButton().addClass('move-to-right-abit');

    // add building entries so you can pick one

    if (_isCaravan === true) {
        this.notifyBackendGetValidSettlementsToSendCaravan(result.ListScrollContainer);
        this.notifyBackendGetTroopTemplate(result, 'caravan');
    }
    else {
        this.addValidSettlementsToSendMercenary(result.ListScrollContainer);
        this.notifyBackendGetTroopTemplate(result, 'mercenary');
    }
};
WorldEditorScreen.prototype.createSendCaravanDialogContent = function(_dialog) 
{
    var self = this;
    var content = $('<div class="s-content-container"/>');

    var leftColumn = $('<div class="column-is-left"/>');
    content.append(leftColumn);

    // resouces input
    var row = $('<div class="row"/>');
    leftColumn.append(row);
    var title = $('<div class="title title-font-big font-color-title">Resources</div>');
    row.append(title);
    var inputLayout = $('<div class="l-input-half-big"/>');
    row.append(inputLayout);
    var input = inputLayout.createInput('', 0, 5, 1, null, 'title-font-big font-bold font-color-brother-name');
    input.css('background-size', '100% 4.0rem'); // simple solution to get a smaller input without much work :evilgrins
    input.assignInputEventListener('focusout', function(_input, _event) {
        var text = _input.getInputText();
        var value = 0;
        var isValid = true;
        if (text.length <= 0) {
            isValid = false;
        }
        else {
            value = self.isValidNumber(text, 0, 99999);
            if (value === null)
                isValid = false;
        }
        if (isValid === true)
            _input.val('' + value + '');
        else 
            _input.val('' + 100 + '');
    });

    var row = $('<div class="row"/>');
    leftColumn.append(row);
    var title = $('<div class="title title-font-big font-color-title">Guard Template</div>');
    row.append(title);

    var checkboxColumn = $('<div class="checkbox-column"/>');
    leftColumn.append(checkboxColumn);
    {
        var checkbox1 = this.createCheckBoxDivForPopupDialog({Name: 'Is Attackable By AI', TooltipId: 'woditor.isattackablebyai'}, checkboxColumn, true);
        var checkbox2 = this.createCheckBoxDivForPopupDialog({Name: 'Is Slower At Night', TooltipId: 'woditor.issloweratnight'}, checkboxColumn, true);
        var checkbox3 = this.createCheckBoxDivForPopupDialog({Name: 'Is Dropping More Loot', TooltipId: 'woditor.isdroppingmoreloot'}, checkboxColumn, false);
    }

    var dropDownMenu = $('<div class="drop-down-menu-container"/>');
    leftColumn.append(dropDownMenu);
    {
        var menuLayout = $('<div class="expandable-container"/>');
        dropDownMenu.append(menuLayout);
        var menuListContainer = $('<div class="ui-control list has-frame"/>');
        menuLayout.append(menuListContainer);
        var menuScrollContainer = $('<div class="scroll-container"/>');
        menuListContainer.append(menuScrollContainer);

        var labelContainer = $('<div class="expandable-label-container"/>');
        dropDownMenu.append(labelContainer);
        var label = $('<div class="label text-font-normal font-bold font-color-ink">-Select Filter-</div>');
        labelContainer.append(label);

        var buttonLayout = $('<div class="expand-button"/>');
        dropDownMenu.append(buttonLayout);
    }

    var rightColumn = $('<div class="column-is-right"/>');
    content.append(rightColumn);
    {
        var container = $('<div class="l-list-container"></div>');
        rightColumn.append(container);

        var listContainer = $('<div class="ui-control list has-frame"/>');
        container.append(listContainer);
        var scrollContainer = $('<div class="scroll-container"/>');
        listContainer.append(scrollContainer);
    }

    return {
        IsExpanded: false,
        ExpandLabel: labelContainer,
        ExpandButton: null,
        ExpandableList: menuListContainer,
        ExpandableListScroll: null,
        Content: content,
        Input: input,
        ButtonLayout: buttonLayout,
        ListContainer: listContainer,
        ListScrollContainer: null,
        Checkbox: [checkbox1, checkbox2, checkbox3],
    };
};
WorldEditorScreen.prototype.addValidSettlementsToSendMercenary = function(_listScrollContainer) 
{
    var currentID = this.mSettlement.Selected.data('entry').ID;
    var toLoad = this.mSettlement.Data;
    var chosen = true;
    for (var i = 0; i < toLoad.length; i++) {
        var data = toLoad[i];
        if (data.ID === currentID)
            continue;

        this.addSettlementEntriesToPopUpDialog(data, _listScrollContainer, chosen);
        chosen = false;
    }
};
WorldEditorScreen.prototype.addValidSettlementsToSendCavaran = function(_enemyIDs, _listScrollContainer) 
{
    var currentID = this.mSettlement.Selected.data('entry').ID;
    var toLoad = this.mSettlement.Data;
    var chosen = true;
    for (var i = 0; i < toLoad.length; i++) {
        var data = toLoad[i];
        if (data.IsIsolated === true || data.ID === currentID || (_enemyIDs.length > 0 && _enemyIDs.indexOf(data.ID) >= 0))
            continue;

        this.addSettlementEntriesToPopUpDialog(data, _listScrollContainer, chosen);
        chosen = false;
    }
};
WorldEditorScreen.prototype.addSettlementEntriesToPopUpDialog = function(_data, _listScrollContainer, _isSelected) 
{
    var self = this;
    var result = $('<div class="l-settlement-row"/>');
    _listScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-fat"/>');
    result.append(entry);
    entry.data('ID', _data.ID);
    entry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') === false) {
            _listScrollContainer.find('.is-selected').each(function (_index, _element) {
                $(_element).removeClass('is-selected');
            });
            div.addClass('is-selected');
        }
    });

    if (_isSelected === true) {
        entry.addClass('is-selected');
    }

    // settlement image
    var imageContainer = $('<div class="l-settlement-image-container"/>');
    entry.append(imageContainer);

    imageContainer.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
    }, null, '');

    // banner image
    var imageContainer = $('<div class="l-settlement-banner-container"/>');
    entry.append(imageContainer);

    var factionID = (_data.Owner !== undefined && _data.Owner !== null) ? _data.Owner : _data.Faction;
    var faction = this.getFaction(factionID);
    imageContainer.createImage(Path.GFX + faction.ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
    }, null, '');

    var name = $('<div class="name title-font-normal font-bold font-color-white">' + _data.Name + '</div>');
    entry.append(name);

    var buttonLayout = $('<div class="distance-button"/>');
    entry.append(buttonLayout);
    var button = buttonLayout.createTextButton('' + _data.Distance + '', null, 'display-block', 6);
    button.enableButton(false);
    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.distance' });
};

WorldEditorScreen.prototype.createCheckBoxDivForPopupDialog = function(_definition, _parentDiv, _isChecked) 
{
    var row = $('<div class="row"></div>');
    _parentDiv.append(row);
    var control = $('<div class="control"/>');
    row.append(control);
    var checkBox = $('<input type="checkbox" id="' + _definition.TooltipId + '"/>');
    control.append(checkBox);
    var checkBoxLabel = $('<label class="text-font-normal font-color-subtitle" for="' + _definition.TooltipId + '">' + _definition.Name + '</label>');
    control.append(checkBoxLabel);
    checkBox.iCheck({
        checkboxClass: 'icheckbox_flat-orange',
        radioClass: 'iradio_flat-orange',
        increaseArea: '30%'
    });

    if (_isChecked === true)
        checkBox.iCheck('check');

    checkBoxLabel.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
    return checkBox;
};
