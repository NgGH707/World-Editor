
WorldEditorScreen.prototype.getWorldLocation = function (_id)
{
    var result = this.getSettlement(_id);
    if (result !== null) {
        return result;
    }
    var result = this.getLocation(_id);
    if (result !== null) {
        return result;
    }
    var result = this.getUnit(_id);
    if (result !== null) {
        return result;
    }
    return null;
}

WorldEditorScreen.prototype.getData = function (_key, _id)
{
    switch(_key)
    {
    case 'Settlement':
        return this.getSettlement(_id);

    case 'Location':
        return this.getLocation(_id);

    case 'Faction':
        return this.getFaction(_id);

    default:
        return null;
    }
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

WorldEditorScreen.prototype.addContractFilter = function(_data)
{
    var self = this;
    this.mContract.ExpandableListScroll.empty();

    // add the show all
    this.mContract.DefaultFilter = this.addExpandableEntry({Name: 'All', Filter: null}, 'All', this.mContract, self.filterContractWithData);
    this.mContract.DefaultFilter.addClass('is-selected');

    for (var i = 0; i < _data.length; i++) {
        this.addExpandableEntry(_data[i], _data[i].Name, this.mContract, self.filterContractWithData);
    }

    this.mContract.IsExpanded = false;
    this.expandExpandableList(false, this.mContract);
    this.mContract.ExpandLabel.find('.label:first').html('All');
};

WorldEditorScreen.prototype.filterContractWithData = function (_filterData)
{
    if (_filterData.Filter === null) {
        this.addContractsData(null, true);
        return;
    }

    this.mContract.ListScrollContainer.empty();
    var key = _filterData.Search;
    var filterKey = _filterData.Filter[0];
    var filterValue = _filterData.Filter[1];

    for(var i = 0; i < this.mContract.Data.length; ++i) {
        var data = this.mContract.Data[i];
        if (key !== null) {
            var getData = this.getData(key[0], data[key[1]]);
            if (getData !== null && getData[filterKey] === filterValue)
                this.addContractListEntry(data, i);
        }
        else {
            if (data[filterKey] === filterValue)
                this.addContractListEntry(data, i);
        }
    }

    this.selectContractListEntry(this.mContract.ListContainer.findListEntryByIndex(0), true);
};

WorldEditorScreen.prototype.addContractsData = function (_data, _isLoaded)
{
    this.mContract.ListScrollContainer.empty();

    if (_isLoaded !== true)
        this.mContract.Data = _data;

    for(var i = 0; i < this.mContract.Data.length; ++i) {
        this.addContractListEntry(this.mContract.Data[i], i);
    }

    // load back and scroll to the position where you have left to see a location
    if (this.mShowEntityOnMap !== null && this.mShowEntityOnMap.Type === 'contract') {
        var find = null;
        this.mContract.ListScrollContainer.find('.list-entry').each(function(index, element) {
            var entry = $(element);
            if (entry.data('entry').ID === self.mShowEntityOnMap.Find) {
                find = entry;
            }
        });

        if (find !== null && find.length > 0)
            this.selectLocationListEntry(find, true);
        else
            this.selectContractListEntry(this.mContract.ListContainer.findListEntryByIndex(0), true);

        this.mShowEntityOnMap = null;
    }
    else
    {
        this.updateFactionContracts();
        this.selectContractListEntry(this.mContract.ListContainer.findListEntryByIndex(0), true);
    }
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

    return entry;
};

WorldEditorScreen.prototype.addInvalidContractsData = function (_data)
{
    this.mContract.BannedListScroll.empty();
    this.mIsUpdating = true;

    for (var i = 0; i < _data.length; i++) {
        var data = _data[i];
        var row = $('<div class="row"></div>');
        row.css('padding-left', '0.5rem');
        this.mContract.BannedListScroll.append(row);
        var control = $('<div class="control"/>');
        row.append(control);
        var checkbox = $('<input type="checkbox" id="' + data.Type + '"/>');
        control.append(checkbox);
        var label = $('<label class="text-font-normal font-color-subtitle" for="' + data.Type + '">' + data.Name + '</label>');
        control.append(label);

        checkbox.iCheck({
            checkboxClass: 'icheckbox_flat-orange',
            radioClass: 'iradio_flat-orange',
            increaseArea: '30%'
        });
        checkbox.on('ifChecked', null, this, function(_event) {
            var self = _event.data;
            if (self.mIsUpdating === false)
                self.notifyBackendInvalidContract(data.Type, true);
        });
        checkbox.on('ifUnchecked', null, this, function(_event) {
            var self = _event.data;
            if (self.mIsUpdating === false) 
                self.notifyBackendUpdateCheckBox(data.Type, false);
        });

        if (data.IsValid === false)
            checkbox.iCheck('check');
    }

    this.mIsUpdating = false;
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
        this.mContract.DetailsPanel.showThisDiv(true);
    }
    else
    {
        this.mContract.Selected = null;
        this.updateContractDetailsPanel(this.mContract.Selected);
        this.mContract.DetailsPanel.showThisDiv(false);
    }
};

WorldEditorScreen.prototype.updateContractDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        this.mContract.Name.html(data.Name);
        this.mContract.Employer.attr('src', Path.PROCEDURAL + data.Employer);
        this.mContract.DifficultyMult.val('' + data.DifficultyMult + '%');
        this.mContract.PaymentMult.val('' + data.PaymentMult + '%');
        this.mContract.Expiration.val('' + data.Expire + '');

        var faction = this.getFaction(data.Faction);
        if (faction === null) {
            this.mContract.FactionBanner.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
            this.mContract.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.nofaction' });
        }
        else {
            this.mContract.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
            this.mContract.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
        }

        this.notifyBackendGetWolrdEntityImagePath(data.Origin, this.mContract.Origin);
        this.notifyBackendGetWolrdEntityImagePath(data.Home, this.mContract.Home);
        this.updateContractObjective(data.Objective);
    }
};

WorldEditorScreen.prototype.updateContractObjective = function(_id)
{
    var image = this.mContract.Objective.find('img:first');
    if (_id === null || _id === undefined) {
        this.mContract.Objective.showThisDiv(false);
        //image.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
        return;
    }
    
    this.mContract.Objective.showThisDiv(true);
    SQ.call(this.mSQHandle, 'onGetWolrdEntityImagePath', _id , function(_data) {
        if (_data === undefined || _data === null || typeof _data !== 'string') {
            console.error('ERROR: Failed to Get Wolrd Entity ImagePath. Invalid data result.');
            return;
        }

        if (_data.length === 0) {
            image.addClass('opacity-none');
        }
        else {
            image.removeClass('opacity-none');
            image.attr('src', Path.GFX + _data);
        }
    });
}

WorldEditorScreen.prototype.refreshContractDetailPanel = function(_data)
{
    var result = this.updateContractData(_data);
    this.updateContractDetailsPanel(result.Element);
};

WorldEditorScreen.prototype.updateContractExpiration = function(_nothing)
{
    var time = this.mContract.Selected.find('.time-left:first');
    if (time.length > 0) {
        time.html(this.mContract.Expiration.getInputText());
    }
};

WorldEditorScreen.prototype.updateContractDifficultyIcon = function(_data)
{
    var result = this.updateContractData(_data);
    result.Element.find('img').each(function(index, element) {
        var image = $(element);
        if (image.hasClass('is-contract-difficulty') === true) {
            image.attr('src', Path.GFX + result.Data.DifficultyIcon);
        }
    });
};

WorldEditorScreen.prototype.confirmContractInputChanges = function(_input, _key, _min, _max)
{
    if (_input.data('IsUpdated') === true)
        return;

    var element = this.mContract.Selected;
    var data = element.data('entry');
    var text = _input.getInputText();
    var value = 0;
    var isValid = true;

    if (text.length <= 0) {
        isValid = false;
    }
    else {
        value = this.isValidNumber(text, _min, _max);
        if (value === null)
            isValid = false;
    }

    if (isValid === true) {
        _input.val('' + value + '');
        _input.data('IsUpdated', true);
        this.notifyBackendContractInputChanges(value, _key);
    }
    else {
        _input.val('' + data[_key] + '');
    }
};