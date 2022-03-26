
WorldEditorScreen.prototype.addFactionsData = function (_data)
{
    this.mFaction.ListScrollContainer.empty();
    this.mFaction.Data = _data;

    for(var i = 0; i < _data.length; ++i)
    {
        this.addFactionListEntry(_data[i], i);
    }

    this.selectFactionListEntry(this.mFaction.ListContainer.findListEntryByIndex(0), true);
};

WorldEditorScreen.prototype.addFactionListEntry = function (_data, _index)
{
    var result = $('<div class="l-row"/>');

    if (_index === 0)
        result.css('margin-top', '0.3rem');

    this.mFaction.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.data('index', _index);
    entry.click(this, function(_event)
    {
        _event.data.selectFactionListEntry($(this));
    });

    // left column
    var column = $('<div class="faction-column is-left"/>');
    entry.append(column);

    column.createImage(Path.GFX + _data['ImagePath'], function (_image)
    {
        _image.centerImageWithinParent(0, 0, 0.5);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // right column
    column = $('<div class="faction-column is-right"/>');
    entry.append(column);

    // top row
    var row = $('<div class="faction-row is-top"/>');
    column.append(row);

    var name = $('<div class="name title-font-normal font-bold font-color-brother-name">' + _data['Name'] + '</div>');
    row.append(name);

    if('Landlord' in _data && _data.Landlord !== undefined && _data.Landlord !== null)
    {
        var landlordImageContainer = $('<div class="f-landlord-container"/>');
        row.append(landlordImageContainer);
        var landlordImage = landlordImageContainer.createImage(Path.GFX + _data.Landlord, function(_image) {
            _image.fitImageToParent(0, 0);
        }, null,'');
    }

    // bottom row
    row = $('<div class="faction-row is-bottom"/>');
    column.append(row);

    var assetsCenterContainer = $('<div class="l-assets-center-container"/>');
    row.append(assetsCenterContainer);

    // relation
    var assetsContainer = $('<div class="l-assets-container"/>');
    assetsCenterContainer.append(assetsContainer);

    var progressbarContainer = $('<div class="stats-progressbar-container ui-control-stats-progressbar-container-relations"></div>');
    assetsContainer.append(progressbarContainer);

    progressbarContainer.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.RelationsScreen.Relations, entityId: _data.ID });

    var progressbar = $('<div class="stats-progressbar ui-control-stats-progressbar relations"></div>');
    var newWidth = (_data.RelationNum / 100.0) * 100;
    progressbar.css('width', newWidth + '%');
    progressbarContainer.append(progressbar);

    var progressbarLabel = $('<div class="stats-progressbar-label text-font-small font-color-progressbar-label">' + _data.Relation + '</div>');
    progressbarContainer.append(progressbarLabel);
};

WorldEditorScreen.prototype.selectFactionListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mFaction.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
        {
            this.mFaction.ListContainer.scrollListToElement(_element);
        }

        _element.addClass('is-selected');
        this.mFaction.Selected = _element;
        this.updateFactionDetailsPanel(this.mFaction.Selected);
    }
    else
    {
        this.mFaction.Selected = null;
        this.updateFactionDetailsPanel(this.mFaction.Selected);
    }
};

WorldEditorScreen.prototype.updateFactionName = function(_name)
{
    var element = this.mFaction.Selected;
    var index = element.data('index');
    var name = element.find('.name:first');
    if (name.length > 0) {
        name.html(_name);
    }
    var data = this.mFaction.Data[index];
    data.Name = _name;
    element.data('entry', data);
    return data.ID;
}

WorldEditorScreen.prototype.updateFactionBanner = function(_imagePath)
{
    var element = this.mFaction.Selected;
    var index = element.data('index');
    var data = this.mFaction.Data[index];
    data.ImagePath = _imagePath;

    // update banner in list container
    var column = element.find('.faction-column:first');
    if (column.length > 0) {
        var image = column.find('img:first');
        if (image.length > 0) {
            image.attr('src', Path.GFX + _imagePath);
        }
    }

    // update banner image in detail panel
    this.mFaction.Banner.attr('src', Path.GFX + _imagePath);
    element.data('entry', data);
}

WorldEditorScreen.prototype.updateFactionRelation = function(_data)
{
    var element = this.mFaction.Selected;
    var index = element.data('index');
    var progressbar = element.find('.stats-progressbar:first');
    if (progressbar.length > 0) {
        var newWidth = (_data.RelationNum / 100.0) * 100;
        progressbar.css('width', newWidth + '%');
    }
    var label = element.find('.stats-progressbar-label:first');
    if (label.length > 0) {
        label.html(_data.Relation);
    }
    var data = this.mFaction.Data[index];
    data.RelationNum = _data.RelationNum;
    data.Relation = _data.Relation;
    element.data('entry', data);
}

WorldEditorScreen.prototype.updateFactionRelationDeterioration = function(_isChecked)
{
    var element = this.mFaction.Selected;
    var index = element.data('index');
    var data = this.mFaction.Data[index];
    data.FactionFixedRelation = _isChecked;
    element.data('entry', data);
    return data.ID;
}

WorldEditorScreen.prototype.updateFactionDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        this.mIsUpdating = true;
        this.mFaction.Name.setInputText(data.Name);
        this.mFaction.Banner.attr('src', Path.GFX + data.ImagePath);
        this.mFaction.PrevButton.enableButton(data.NoChangeName !== true);
        this.mFaction.NextButton.enableButton(data.NoChangeName !== true);

        this.mFactionRelation.Control.val(data.RelationNum);
        this.mFactionRelation.Label.text('' + data.RelationNum + this.mFactionRelation.Postfix);

        if (this.mFactionFixedRelation.Checkbox.is(':checked') === true && data.FactionFixedRelation === false)
            this.mFactionFixedRelation.Checkbox.iCheck('uncheck');
        else if (this.mFactionFixedRelation.Checkbox.is(':checked') === false && data.FactionFixedRelation === true)
            this.mFactionFixedRelation.Checkbox.iCheck('check');

        this.addContractToFactionDetail(data.Contracts);
        this.mIsUpdating = false;
    }
};

WorldEditorScreen.prototype.updateFactionContracts = function(_data) 
{
    if (_data === undefined || _data === null || !jQuery.isArray(_data)) return;

    var index = this.mFaction.Selected.data('index');
    this.mFaction.Data[index] = _data;
    this.mFaction.Selected.data('entry', this.mFaction.Data[index]);
    this.addContractToFactionDetail(_data);
}

WorldEditorScreen.prototype.resetContractInFactionDetail = function() 
{
    var element = this.mFaction.Selected;
    var index = element.data('index');
    var data = this.mFaction.Data[index];
    data.Contracts = [];
    this.mFaction.Contracts.empty();
    element.data('entry', data);
    return data.ID;
}

WorldEditorScreen.prototype.addContractToFactionDetail = function(_data) 
{
    var self = this;
    this.mFaction.Contracts.empty();

    if (_data !== undefined && _data !== null && jQuery.isArray(_data))
    {
        for (var i = 0; i < _data.length; ++i)
        {
            var entry = _data[i];
            var a = 2.0 + i * 6.0;
            var contract = this.mFaction.Contracts.createImage(Path.GFX + entry.Icon + '.png', null, null, 'display-block is-contract');
            var scroll = this.mFaction.Contracts.createImage(Path.GFX + 'ui/icons/scroll_0' + (_data.IsNegotiated ? 1 : 2) + '.png', null, null, 'display-block is-scroll');
            var difficulty = this.mFaction.Contracts.createImage(Path.GFX + entry.DifficultyIcon + '.png', null, null, 'display-block is-difficulty');

            contract.css('left', a + 'rem');
            scroll.css('left', a + 'rem');
            difficulty.css('left', a + 'rem');

            // set up event listeners
            contract.click(function(_event) {
                //if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
                    //self.(_data.ID);
                //else
                    //self.(_data.ID);
            });
            contract.mouseover(function() {
                this.classList.add('is-highlighted');
                scroll.addClass('is-highlighted');
                difficulty.addClass('is-highlighted');
            });
            contract.mouseout(function() {
                this.classList.remove('is-highlighted');
                scroll.removeClass('is-highlighted');
                difficulty.removeClass('is-highlighted');
            });

            contract.bindTooltip({ contentType: 'ui-element', elementId: entry.ID, elementOwner: 'woditor.faction_contracts' });

            if (i === 11)
                break;
        }
    }
};