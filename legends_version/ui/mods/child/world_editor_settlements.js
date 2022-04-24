
WorldEditorScreen.prototype.getSettlement = function (_id)
{
    for (var i = 0; i < this.mSettlement.Data.length; i++) {
        var result = this.mSettlement.Data[i];
        if (result.ID === _id) {
            return result;
        }
    }
    return null;
}

WorldEditorScreen.prototype.updateSettlementData = function(_newData)
{
    var element = this.mSettlement.Selected;
    var index = element.data('index');
    var data = this.mSettlement.Data[index];
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
    this.mSettlement.Buildings[_index].addHighlighter();
    this.mSettlement.Buildings[_index].bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
};

WorldEditorScreen.prototype.addSettlementFilter = function (_data)
{
    var self = this;
    this.mSettlement.ExpandableListScroll.empty();

    // add the show all
    this.mSettlement.DefaultFilter = this.addExpandableEntry({Name: 'All', Filter: null}, 'All', this.mSettlement, self.filterSettlementWithData);
    this.mSettlement.DefaultFilter.addClass('is-selected');

    for (var i = 0; i < _data.length; i++) {
        this.addExpandableEntry(_data[i], _data[i].Name, this.mSettlement, self.filterSettlementWithData);
    }

    this.mSettlement.IsExpanded = false;
    this.expandExpandableList(false, this.mSettlement);
    this.mSettlement.ExpandLabel.find('.label:first').html('All');
};

WorldEditorScreen.prototype.filterSettlementWithData = function (_filterData)
{
    if (_filterData.Filter === null) {
        this.addSettlementsData(null, true);
        return;
    }

    this.mSettlement.ListScrollContainer.empty();
    var key = _filterData.Search;
    var filterKey = _filterData.Filter[0];
    var filterValue = _filterData.Filter[1];

    for(var i = 0; i < this.mSettlement.Data.length; ++i) {
        var data = this.mSettlement.Data[i];
        if (key !== null) {
            var getData = this.getData(key[0], data[key[1]]);
            if (getData !== null && getData[filterKey] === filterValue)
                this.addSettlementListEntry(data, i);
        }
        else {
            if (filterKey === 'Faction') {
                if (data.Faction === filterValue || data.Owner === filterValue) {
                    this.addSettlementListEntry(data, i);
                }
            }
            else if (data[filterKey] === filterValue) {
                this.addSettlementListEntry(data, i);
            }
        }
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0, '.list-entry-fat'), true);
};

WorldEditorScreen.prototype.addSettlementsData = function (_data, _isLoaded)
{
    var self = this;
    this.mSettlement.ListScrollContainer.empty();
    this.mSettlement.ExpandableList.deselectListEntries();
    this.mSettlement.DefaultFilter.addClass('is-selected');
    this.mSettlement.ExpandLabel.find('.label:first').html('All');

    if (_isLoaded !== true)
        this.mSettlement.Data = _data;
    
    for(var i = 0; i < this.mSettlement.Data.length; ++i) {
        this.addSettlementListEntry(this.mSettlement.Data[i], i);
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0, '.list-entry-fat'), true);
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

    imageContainer.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // banner image
    var imageContainer = $('<div class="l-settlement-banner-container"/>');
    entry.append(imageContainer);

    var factionID = (_data.Owner !== undefined && _data.Owner !== null) ? _data.Owner : _data.Faction;
    var faction = this.getFaction(factionID);
    imageContainer.createImage(Path.GFX + faction.ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    var name = $('<div class="name title-font-normal font-bold font-color-white">' + _data.Name + '</div>');
    entry.append(name);

    var buttonLayout = $('<div class="distance-button"/>');
    entry.append(buttonLayout);
    var button = buttonLayout.createTextButton('' + _data.Distance + '', function() {
        self.notifyBackendShowWorldEntityOnMap({ID: _data.ID, Type: 'settlement'});
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
        this.mSettlement.DetailsPanel.showThisDiv(true);
    }
    else
    {
        this.mSettlement.Selected = null;
        this.updateSettlementDetailsPanel(this.mSettlement.Selected);
        this.mSettlement.DetailsPanel.showThisDiv(false);
    }
};

WorldEditorScreen.prototype.updateSettlementResources = function(_data)
{
    var result = this.updateSettlementData(_data);
    this.mSettlement.Resources.val('' + result.Data.Resources + '');
}

WorldEditorScreen.prototype.updateSettlementWealth = function(_data)
{
    var result = this.updateSettlementData(_data);
    this.mSettlement.Wealth.val('' + result.Data.Wealth + '%');
}

WorldEditorScreen.prototype.updateSettlementName = function(_name)
{
    var result = this.updateSettlementData({Name: _name});
    var name = result.Element.find('.name:first');
    if (name.length > 0) {
        name.html(_name);
    }
    return result.Data.ID;
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

WorldEditorScreen.prototype.updateAttachmentList = function (_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var result = this.updateSettlementData(_data);
        _data = result.Data.Attachments;
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
        var result = this.updateSettlementData(_data);
        _data = result.Data.Situations;
    }

    this.mSettlement.Situations.empty();
    // update situation list
    var row = $('<div class="situation-row"/>');
    this.mSettlement.Situations.append(row);
    for (var i = 0; i < _data.length; i++) {
        this.addSituationEntry(_data[i], row);
    }
};

WorldEditorScreen.prototype.updateDraftList = function (_data)
{
    this.mSettlement.DraftList.empty();
    // update draft list
    var row = $('<div class="draft-row"/>');
    this.mSettlement.DraftList.append(row);
    for (var i = 0; i < _data.length; i++) {
        this.addDraftEntry(_data[i], row);
    }
};

WorldEditorScreen.prototype.updateSettlementNewOwner = function (_data)
{
    var result = this.updateSettlementData(_data);
    var faction = this.getFaction(result.Data.Owner);
    this.mSettlement.OwnerBanner.attr('src', Path.GFX + faction.ImagePath);
    this.mSettlement.OwnerBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });

    var container = element.find('.l-settlement-banner-container:first');
    if (container.length > 0) {
        var banner = container.find('img:first');
        if (banner.length > 0) {
            banner.attr('src', Path.GFX + faction.ImagePath);
        }
    }
};

WorldEditorScreen.prototype.updateSettlementNewFaction = function (_data)
{
    var result = this.updateSettlementData(_data);
    var faction = this.getFaction(result.Data.Faction);
    this.mSettlement.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
    this.mSettlement.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
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

WorldEditorScreen.prototype.updateSettlementDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');

        this.mSettlement.Name.setInputText(data.Name);
        this.mSettlement.Resources.val('' + data.Resources + '');
        this.mSettlement.Wealth.val('' + data.Wealth + '%');
        this.mSettlement.Image.attr('src', Path.GFX + data.ImagePath);
        this.mSettlement.Image.bindTooltip({ contentType: 'ui-element', elementId: data.ID, elementOwner: 'woditor.world_entity' });
        this.mSettlement.HouseImage.attr('src', Path.GFX + data.HouseImage);
        this.mSettlement.House.html('' + data.House + '');
        this.mSettlement.Terrain.css('background-image', 'url("' + Path.GFX + data.Terrain + '")');
        this.mSettlement.ActiveButton.changeButtonText(data.IsActive ? 'Shut Down' : 'Restart');
        this.mSettlement.SendCaravanButton.enableButton(!data.IsIsolated);
        this.updateSituationList(data.Situations);
        this.updateAttachmentList(data.Attachments);
        //this.updateDraftList(data.DraftList);

        var faction = this.getFaction(data.Faction);
        this.mSettlement.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
        this.mSettlement.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });

        var ownerFaction = (data.Owner !== undefined && data.Owner !== null) ? this.getFaction(data.Owner) : faction;
        this.mSettlement.OwnerBanner.attr('src', Path.GFX + ownerFaction.ImagePath);
        this.mSettlement.OwnerBanner.bindTooltip({ contentType: 'ui-element', elementId: ownerFaction.ID, elementOwner: 'woditor.factionbanner' });
        
        for (var i = 0; i < data.Buildings.length; i++) {
            var entry = data.Buildings[i];
            this.updateSettlementBuildingSlotImage(entry, i);
        }
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
    image.addHighlighter();
    image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID , elementOwner: 'woditor.situations'});
};

WorldEditorScreen.prototype.addAttachmentEntry = function (_data)
{
    var self = this;
    var entry = $('<div class="attach-row"/>');
    this.mSettlement.Attachments.append(entry);
    var image = entry.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
    }, null, '');
    image.data('ID', _data.ID);

    // set up event listeners
    image.click(this, function(_event) {
        var element = $(this);
        var id = element.data('ID');

        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            self.notifyBackendRemoveAttachedLocation(id);
    });
    image.addHighlighter();
    image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID, elementOwner: 'woditor.attached_location' });
};

WorldEditorScreen.prototype.addDraftEntry = function (_data, _parentDiv)
{
    var self = this;
    var image = $('<img/>');
    image.attr('src', Path.GFX + _data.ImagePath);
    _parentDiv.append(image);

    image.bindTooltip({ contentType: 'ui-element', elementId: _data.Key , elementOwner: 'woditor.draftlist'});
};
