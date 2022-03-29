
WorldEditorScreen.prototype.createSettlementBuildingSlot = function (_index, _parentDiv)
{
    var self = this;
    var slot = $('<div class="is-building-slot"/>');
    slot.css('left', (0.5 + _index * 15.0) + 'rem'); // (1.5 + _index * 17.0) + 'rem'
    _parentDiv.append(slot);
    this.mSettlement.Buildings[_index] = slot.createImage(Path.GFX + 'ui/buttons/free_building_slot_icon.png', function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');
    this.mSettlement.Buildings[_index].data('ID', null);
    this.mSettlement.Buildings[_index].data('index', _index);

    // set up event listeners
    this.mSettlement.Buildings[_index].click(this, function(_event) {
        var element = $(this);
        var id = element.data('ID');
        var index = element.data('index');

        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            self.notifyBackendRemoveBuilding(index, id);
        else
            self.createBuildingPopupDialog(index);
    });
    this.mSettlement.Buildings[_index].mouseover(function()
    {
        this.classList.add('is-highlighted');
    });
    this.mSettlement.Buildings[_index].mouseout(function()
    {
        this.classList.remove('is-highlighted');
    });
    this.mSettlement.Buildings[_index].bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
};

WorldEditorScreen.prototype.addSettlementFilter = function (_data)
{
    var self = this;
    this.mSettlement.ExpandableListScroll.empty();

    // add the place holder
    var placeholderName = this.mSettlement.ExpandLabel.find('.label:first');

    // add the filter-all option
    this.mSettlement.DefaultFilter = this.addExpandableEntry({NoFilter: true}, 'All', this.mSettlement);
    this.mSettlement.DefaultFilter.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mSettlement.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterSettlementsByType();
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    // add the filter town option
    var specialEntry = this.addExpandableEntry({NoFilter: true}, 'Towns', this.mSettlement);
    specialEntry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mSettlement.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterSettlementsByType('IsMilitary', false, 'IsSouthern', false);
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    // add the filter stronghold option
    var specialEntry = this.addExpandableEntry({NoFilter: true}, 'Strongholds', this.mSettlement);
    specialEntry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mSettlement.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterSettlementsByType('IsMilitary', true, 'IsSouthern', false);
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    // add the filter city state option
    var specialEntry = this.addExpandableEntry({NoFilter: true}, 'City States', this.mSettlement);
    specialEntry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mSettlement.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterSettlementsByType('IsSouthern', true);
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    for (var i = 0; i < _data.length; i++) {
        var entryData = _data[i];
        var entry = this.addExpandableEntry(entryData, this.mFaction.Data[entryData.Index].Name, this.mSettlement);
        entry.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') !== true) {
                var data = div.data('key');
                self.mSettlement.ExpandableList.deselectListEntries();
                div.addClass('is-selected');
                self.filterSettlementsByFaction(data);
                var label = div.data('label');
                placeholderName.html(label);
            }
        });
    }

    this.mSettlement.IsExpanded = false;
    this.expandExpandableList(false, this.mSettlement);
};

WorldEditorScreen.prototype.filterSettlementsByType = function (_filter1, _value1, _filter2, _value2)
{
    var _data = this.mSettlement.Data;
    var noFilter = _filter1 === undefined || _filter1 === null;
    var extraFilter = _filter2 === undefined || _filter2 === null;
    this.mSettlement.ListScrollContainer.empty();

    for(var i = 0; i < _data.length; ++i) {
        if (noFilter || _data[i][_filter1] === _value1 && (extraFilter || _data[i][_filter2] === _value2)) 
            this.addSettlementListEntry(_data[i], i);
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
    this.expandExpandableList(false, this.mSettlement);
};

WorldEditorScreen.prototype.filterSettlementsByFaction = function (_filter)
{
    var _data = this.mSettlement.Data;
    var NoFilter = _filter === undefined || _filter === null;
    this.mSettlement.ListScrollContainer.empty();

    for(var i = 0; i < _data.length; ++i) {
        if (NoFilter || _filter.Index == _data[i].Owner || _filter.Index == _data[i].Faction)
            this.addSettlementListEntry(_data[i], i);
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
    this.expandExpandableList(false, this.mSettlement);
};

WorldEditorScreen.prototype.addSettlementsData = function (_data)
{
    var self = this;
    this.mSettlement.ListScrollContainer.empty();
    this.mSettlement.ExpandableList.deselectListEntries();
    this.mSettlement.DefaultFilter.addClass('is-selected');
    this.mSettlement.Data = _data;
    this.filterSettlementsByType();

    // load back and scroll to the position where you have left to see a settlement
    if (this.mShowEntityOnMap !== null && this.mShowEntityOnMap.Type === 'settlement')
    {
        var find = null;
        this.mSettlement.ListScrollContainer.find('.list-entry-fat').each(function(index, element) {
            var entry = $(element);
            if (entry.data('entry').ID === self.mShowEntityOnMap.ID) {
                find = entry;
            }
        });

        if (find !== null && find.length > 0) {
            this.selectSettlementListEntry(find, true);
        }

        this.mShowEntityOnMap = null;
    }
};

WorldEditorScreen.prototype.addSettlementListEntry = function(_data, _index)
{
    var self = this;
    var result = $('<div class="l-settlement-row"/>');
    this.mSettlement.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-fat"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.data('index', _index);
    entry.click(this, function(_event) {
        _event.data.selectSettlementListEntry($(this));
    });

    // settlement image
    var imageContainer = $('<div class="l-settlement-image-container"/>');
    entry.append(imageContainer);

    imageContainer.createImage(Path.GFX + _data['ImagePath'], function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // banner image
    var imageContainer = $('<div class="l-settlement-banner-container"/>');
    entry.append(imageContainer);

    var find = (_data.Owner !== undefined && _data.Owner !== null) ? _data.Owner : _data.Faction;
    imageContainer.createImage(Path.GFX + this.mFaction.Data[find].ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    var name = $('<div class="name title-font-normal font-bold font-color-white">' + _data['Name'] + '</div>');
    entry.append(name);

    var buttonLayout = $('<div class="distance-button"/>');
    entry.append(buttonLayout);
    var button = buttonLayout.createTextButton('' + _data.Distance + '', function() {
        self.notifyBackendShowWorldEntityOnMap(_data.ID, 'settlement');
    }, 'display-block', 6);
    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.distance' });
};

WorldEditorScreen.prototype.selectSettlementListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mSettlement.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
            this.mSettlement.ListContainer.scrollListToElement(_element);

        _element.addClass('is-selected');
        this.mSettlement.Selected = _element;
        this.updateSettlementDetailsPanel(this.mSettlement.Selected);
        this.mSettlement.DetailsPanel.addClass('display-block').removeClass('display-none');
    }
    else
    {
        this.mSettlement.Selected = null;
        this.updateSettlementDetailsPanel(this.mSettlement.Selected);
        this.mSettlement.DetailsPanel.addClass('display-none').removeClass('display-block');
    }
};

WorldEditorScreen.prototype.updateSettlementResources = function(_value)
{
    var element = this.mSettlement.Selected;
    var index = element.data('index');
    var data = this.mSettlement.Data[index];
    data.Resources = _value;
    element.data('entry', data);
    this.mSettlement.Resources.val('' + _value + '');
}

WorldEditorScreen.prototype.updateSettlementWealth = function(_value)
{
    var element = this.mSettlement.Selected;
    var index = element.data('index');
    var data = this.mSettlement.Data[index];
    data.Wealth = _value;
    element.data('entry', data);
    this.mSettlement.Wealth.val('' + _value + '%');
}

WorldEditorScreen.prototype.updateSettlementName = function(_name)
{
    var element = this.mSettlement.Selected;
    var index = element.data('index');
    var name = element.find('.name:first');
    if (name.length > 0) {
        name.html(_name);
    }
    var data = this.mSettlement.Data[index];
    data.Name = _name;
    element.data('entry', data);
    return data.ID;
}

WorldEditorScreen.prototype.updateSettlementBuildingSlot = function(_data)
{
    if (_data === undefined || _data === null || typeof _data !== 'object') return;

    var element = this.mSettlement.Selected;
    var index = element.data('index');
    var data = this.mSettlement.Data[index];
    data.Buildings[_data.Slot] = _data.Data;
    this.updateSettlementBuildingSlotImage(_data.Data, _data.Slot);
    element.data('entry', data);
};

WorldEditorScreen.prototype.updateSettlementBuildingSlotImage = function(_data, _slot)
{
    var image = this.mSettlement.Buildings[_slot];

    if (_data === undefined || _data === null) {
        if (image.attr('src') == Path.GFX + 'ui/buttons/free_building_slot_icon.png')
            return;

        image.data('ID', null);
        image.attr('src', Path.GFX + 'ui/buttons/free_building_slot_icon.png');
        image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
    }
    else {
        if (image.attr('src') == Path.GFX + _data.ImagePath)
            return;

        image.data('ID', _data.ID);
        image.attr('src', Path.GFX + _data.ImagePath);
        image.bindTooltip({ contentType: 'ui-element', elementId: _data.TooltipId , elementOwner: 'woditor.buildings'});
    }
}

WorldEditorScreen.prototype.updateAttachmentList = function (_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var element = this.mSettlement.Selected;
        var index = element.data('index');
        var data = this.mSettlement.Data[index];
        data.Attachments = _data.Data;
        element.data('entry', data);
        _data = data.Attachments;
    }

    this.mSettlement.Attachments.empty();
    // update attached location list
    for (var i = 0; i < _data.length; i++) {
        this.addAttachmentEntry(_data[i], i);
    }
}

WorldEditorScreen.prototype.updateSituationList = function (_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var element = this.mSettlement.Selected;
        var index = element.data('index');
        var data = this.mSettlement.Data[index];
        data.Situations = _data.Data;
        element.data('entry', data);
        _data = data.Situations;
    }

    this.mSettlement.Situations.empty();
    // update situation list
    var row = $('<div class="situation-row"/>');
    this.mSettlement.Situations.append(row);
    var containerLayout = $('<div class="l-situations-group-container"/>');
    var container = $('<div class="l-situation-groups-container"/>');
    containerLayout.append(container);
    for (var i = 0; i < _data.length; i++) {
        this.addSituationEntry(_data[i], container);
    }
    row.append(containerLayout);
};

WorldEditorScreen.prototype.updateSettlementDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');

        this.mSettlement.Name.setInputText(data.Name);
        this.mSettlement.Resources.val('' + data.Resources + '');
        this.mSettlement.Wealth.val('' + data.Wealth + '%');
        this.mSettlement.Image.attr('src', Path.GFX + data.ImagePath);
        this.mSettlement.ActiveButton.changeButtonText(data.IsActive ? 'Shut Down' : 'Restart');
        this.mSettlement.SendCaravanButton.enableButton(!data.IsIsolated);
        this.updateSituationList(data.Situations);
        this.updateAttachmentList(data.Attachments);
        
        for (var i = 0; i < data.Buildings.length; i++) {
            var entry = data.Buildings[i];
            this.updateSettlementBuildingSlotImage(entry, i);
        }

        this.mSettlement.FactionBanner.attr('src', Path.GFX + this.mFaction.Data[data.Faction].ImagePath);

        if (data.Owner === undefined || data.Owner === null)
            this.mSettlement.OwnerBanner.attr('src', Path.GFX + 'ui/banners/add_banner.png');
        else 
            this.mSettlement.OwnerBanner.attr('src', Path.GFX + this.mFaction.Data[data.Owner].ImagePath);
    }
};

WorldEditorScreen.prototype.addSituationEntry = function (_data, _parentDiv)
{
    var self = this;
    var image = $('<img/>');
    image.attr('src', Path.GFX + _data.ImagePath);
    image.data('ID', _data.ID);
    _parentDiv.append(image);

    // set up event listeners
    image.click(this, function(_event) {
        var element = $(this);
        var id = element.data('ID');

        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            self.notifyBackendRemoveSituation(id);
    });
    image.mouseover(function() {
        this.classList.add('is-highlighted');
    });
    image.mouseout(function() {
        this.classList.remove('is-highlighted');
    });

    image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID , elementOwner: 'woditor.situations'});
};

WorldEditorScreen.prototype.addAttachmentEntry = function (_data)
{
    var self = this;
    var entry = $('<div class="attach-row"/>');
    this.mSettlement.Attachments.append(entry);
    var image = entry.createImage(Path.GFX + _data.ImagePath, function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');
    image.data('ID', _data.ID);

    // set up event listeners
    image.click(this, function(_event) {
        var element = $(this);
        var id = element.data('ID');

        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            self.notifyBackendRemoveAttachedLocation(id);
    });
    image.mouseover(function() {
        this.classList.add('is-highlighted');
    });
    image.mouseout(function() {
        this.classList.remove('is-highlighted');
    });

    image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID, elementOwner: 'woditor.attached_location' });
};