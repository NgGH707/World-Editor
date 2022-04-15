
WorldEditorScreen.prototype.getWorldLocation = function (_id)
{
    if (_id === null) {
        console.error('ERROR: Failed to search for WorldLocation. id is null.');
        return null;
    }
    var result = this.getSettlement(_id);
    if (result !== null) {
        return result;
    }
    var result = this.getLocation(_id);
    if (result !== null) {
        return result;
    }
    console.error('ERROR: Failed to search for WorldLocation. can not find ' + _id);
    return null;
}

WorldEditorScreen.prototype.updateContractData = function(_newData)
{
    var element = this.mContract.Selected;
    var index = element.data('index');
    var data = this.mContract.Data[index];
    $.each(_newData, function(_key, _definition) {
        if (_key !== 'IsUpdating') {
            data[_key] = _definition;
        }
    });
    element.data('entry', data);

    return {
        Element: element,
        Data: data
    };
}

WorldEditorScreen.prototype.addContractsData = function (_data, _isLoaded)
{
    this.mContract.ListScrollContainer.empty();

    if (_isLoaded !== true)
        this.mContract.Data = _data;

    for(var i = 0; i < this.mContract.Data.length; ++i)
    {
        this.addContractListEntry(this.mContract.Data[i], i);
    }

    this.updateFactionContracts();
    this.selectContractListEntry(this.mContract.ListContainer.findListEntryByIndex(0), true);
};

WorldEditorScreen.prototype.addContractListEntry = function (_data, _index)
{
    var result = $('<div class="contract-row"/>');
    this.mContract.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.data('index', _index);
    entry.click(this, function(_event) {
        _event.data.selectContractListEntry($(this));
    });

    // left column
    var leftColumn = $('<div class="contract-column-left"/>');
    entry.append(leftColumn);

    // banner
    leftColumn.createImage(Path.GFX + _data.Icon, function(_image) {
        _image.centerImageWithinParent(0, 0, 0.5);
    }, null, 'is-center');

    // difficulty
    leftColumn.createImage(Path.GFX + _data.DifficultyIcon, null, null, 'is-contract-difficulty');

    // right column
    rightColumn = $('<div class="contract-column-right"/>');
    entry.append(rightColumn);
    
    var name = $('<div class="name title-font-normal font-bold font-color-brother-name">' + _data.Name + '</div>');
    rightColumn.append(name);

    var expirationContainer = $('<div class="expiration-container"/>');
    rightColumn.append(expirationContainer);
    var image = expirationContainer.createImage(Path.GFX + 'ui/icons/icon_days.png', null, null, '');
    image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.contractexpiration' });
    var time = $('<div class="time-left text-font-normal font-bold font-color-subtitle">' + _data.Expire + '</div>');
    expirationContainer.append(time);
};

WorldEditorScreen.prototype.selectContractListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mContract.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
        {
            this.mContract.ListContainer.scrollListToElement(_element);
        }

        _element.addClass('is-selected');
        this.mContract.Selected = _element;
        this.updateContractDetailsPanel(this.mContract.Selected);
    }
    else
    {
        this.mContract.Selected = null;
        this.updateContractDetailsPanel(this.mContract.Selected);
    }
};

WorldEditorScreen.prototype.updateContractDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        var faction = this.getFaction(data.Faction);
        var origin = this.getWorldLocation(data.Origin);
        var home = this.getWorldLocation(data.Home);
        this.mContract.Name.html(data.Name);
        this.mContract.Employer.attr('src', Path.PROCEDURAL + data.Employer);
        this.mContract.DifficultyMult.setInputText('' + data.DifficultyMult + '');
        this.mContract.PaymentMult.setInputText('' + data.PaymentMult + '');
        this.mContract.Expiration.setInputText('' + data.Expire + '');

        if (faction === null) {
            this.mContract.FactionBanner.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
            this.mContract.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.nofaction' });
        }
        else {
            this.mContract.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
            this.mContract.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
        }
        
        if (origin === null)
            this.mContract.Origin.attr('src', Path.GFX + 'ui/images/undiscovered_opponent.png');
        else
            this.mContract.Origin.attr('src', Path.GFX + origin.ImagePath);
        
        if (home === null)
            this.mContract.Home.attr('src', Path.GFX + 'ui/images/undiscovered_opponent.png');
        else
            this.mContract.Home.attr('src', Path.GFX + home.ImagePath);
    }
};