
WorldEditorScreen.prototype.getLocation = function (_id)
{
    for (var i = 0; i < this.mLocation.Data.length; i++) {
        var result = this.mLocation.Data[i];
        if (result.ID === _id) {
            return result;
        }
    }
    return null;
}

WorldEditorScreen.prototype.updateLocationData = function(_newData)
{
    var element = this.mLocation.Selected;
    var index = element.data('index');
    var data = this.mLocation.Data[index];
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

WorldEditorScreen.prototype.addLocationFilter = function(_data)
{
    var self = this;
    this.mLocation.ExpandableListScroll.empty();

    // add the show all
    this.addExpandableEntry({Name: 'All', Filter: null}, 'All', this.mLocation, self.filterLocationWithData);

    // the default filter is not all but is 'Camps'
    this.mLocation.DefaultFilter = this.addExpandableEntry(_data[0], _data[0].Name, this.mLocation, self.filterLocationWithData);
    this.mLocation.DefaultFilter.addClass('is-selected');

    for (var i = 1; i < _data.length; i++) {
        this.addExpandableEntry(_data[i], _data[i].Name, this.mLocation, self.filterLocationWithData);
    }

    this.mLocation.IsExpanded = false;
    this.expandExpandableList(false, this.mLocation);
    this.mLocation.ExpandLabel.find('.label:first').html(_data[0].Name);
};

WorldEditorScreen.prototype.filterLocationWithData = function (_filterData)
{
    if (_filterData.Filter === null) {
        this.addLocationsData(null, true);
        return;
    }

    this.mLocation.ListScrollContainer.empty();
    var key = _filterData.Search;
    var filterKey = _filterData.Filter[0];
    var filterValue = _filterData.Filter[1];

    for(var i = 0; i < this.mLocation.Data.length; ++i) {
        var data = this.mLocation.Data[i];
        if (key !== null) {
            var getData = this.getData(key[0], data[key[1]]);
            if (getData !== null && getData[filterKey] === filterValue)
                this.addLocationListEntry(data, i);
        }
        else {
            if (data[filterKey] === filterValue)
                this.addLocationListEntry(data, i);
        }
    }

    this.selectLocationListEntry(this.mLocation.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
};

WorldEditorScreen.prototype.addLocationsData = function(_data, _isLoaded)
{
    var self = this;
    this.mLocation.ListScrollContainer.empty();
    this.mLocation.ExpandableList.deselectListEntries();
    this.mLocation.DefaultFilter.addClass('is-selected');

    if (_isLoaded !== true)
        this.mLocation.Data = _data;

    // load back and scroll to the position where you have left to see a location
    if (this.mShowEntityOnMap !== null && this.mShowEntityOnMap.Type === 'location') {   
        for(var i = 0; i < this.mLocation.Data.length; ++i) {
            this.addLocationListEntry(this.mLocation.Data[i], i);
        }

        var find = null;
        this.mLocation.ListScrollContainer.find('.list-entry-fat').each(function(index, element) {
            var entry = $(element);
            if (entry.data('entry').ID === self.mShowEntityOnMap.ID) {
                find = entry;
            }
        });

        if (find !== null && find.length > 0)
            this.selectLocationListEntry(find, true);
        else
            this.selectLocationListEntry(this.mLocation.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);

        this.mShowEntityOnMap = null;
    }
    else {
        for(var i = 0; i < this.mLocation.Data.length; ++i) {
            if (this.mLocation.Data[i].IsCamp === true)
                this.addLocationListEntry(this.mLocation.Data[i], i);
        }

        this.selectLocationListEntry(this.mLocation.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
        this.mLocation.ExpandLabel.find('.label:first').html('Camps');
    }
};

WorldEditorScreen.prototype.addLocationListEntry = function(_data, _index)
{
    var self = this;
    var result = $('<div class="l-settlement-row"/>'); // reuse the list entry from settlement screen :evilgirns:
    this.mLocation.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-fat"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.data('index', _index);
    entry.click(this, function(_event) {
        _event.data.selectLocationListEntry($(this));
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

    var banner = (_data.Banner === undefined || _data.Banner === null) ? null : Path.GFX + _data.Banner;
    imageContainer.createImage(banner, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    var name = $('<div class="name title-font-normal font-bold font-color-white">' + _data['Name'] + '</div>');
    entry.append(name);

    var buttonLayout = $('<div class="distance-button"/>');
    entry.append(buttonLayout);
    var button = buttonLayout.createTextButton('' + _data.Distance + '', function() {
        self.notifyBackendShowWorldEntityOnMap({ID: _data.ID, Type: 'location'});
    }, 'display-block', 6);
    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.distance' });
};

WorldEditorScreen.prototype.selectLocationListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mLocation.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
            this.mLocation.ListContainer.scrollListToElement(_element);

        _element.addClass('is-selected');
        this.mLocation.Selected = _element;
        this.updateLocationDetailsPanel(this.mLocation.Selected);
        this.mLocation.DetailsPanel.showThisDiv(true);
    }
    else
    {
        this.mLocation.Selected = null;
        this.updateLocationDetailsPanel(this.mLocation.Selected);
        this.mLocation.DetailsPanel.showThisDiv(false);
    }
};

WorldEditorScreen.prototype.addTroopListEntry = function (_data, _index, _listScrollContainer, _type)
{
    var self = this;
    var result = $('<div class="troop-row"/>');
    var strength = _data.Strength * _data.Num;
    _listScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-noice"/>');
    result.append(entry);

    var leftColumn = this.addColumn(25);
    result.append(leftColumn);
    var iconLayout = this.addLayout(5.6, 5.6, 'is-center');
    leftColumn.append(iconLayout);
    var icon = iconLayout.createImage(Path.GFX + _data.Icon, function(_image) {
        _image.fitImageToParent(0, 0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    var minibossIcon = 'special';
    var color = 'font-color-white';
    if (_data.IsChampion === true) {
        var iconLayout = this.addLayout(2.2, 2.2, 'is-horizontal-center');
        iconLayout.css('top', '6.6rem');
        leftColumn.append(iconLayout);
        var icon = iconLayout.createImage(Path.GFX + 'ui/icons/miniboss.png', function(_image) {
            _image.fitImageToParent(0, 0);
            _image.removeClass('opacity-none');
        }, null, 'opacity-none');

        minibossIcon = 'miniboss';
        color = 'font-color-brother-name';
    }

    var rightColumn = this.addColumn(75);
    result.append(rightColumn);

    // for more buttons
    var upperRow = this.addRow(50);
    rightColumn.append(upperRow);
    {
        // an input so you can easily increase/decrease the number of troop
        var column = this.addColumn(40);
        upperRow.append(column);
        this.createTroopNumInputDIV('Num:', {
            Input: null,
            Value: _data.Num,
            Min: 0,
            Max: 3,
            Color: color,
            Font: 'title-font-normal'
        }, column, _index, _type);

        // to display the strength this troop entry contributes
        var column = this.addColumn(30);
        upperRow.append(column);
        var iconLayout = this.addLayout(3.0, 3.0, 'is-vertical-center');
        column.append(iconLayout);
        var image = iconLayout.createImage(Path.GFX + 'ui/icons/fist.png', function(_image) {
            _image.fitImageToParent(0, 0);
            _image.removeClass('opacity-none');
        }, null, 'opacity-none');
        image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.partystrength' });
        var name = $('<div class="strength-label is-vertical-center title-font-normal font-bold ' + color + '">' + strength + '</div>');
        column.append(name);

        // a button so you can turn a unit in this entry into a champion or vice versa
        var column = this.addColumn(15);
        upperRow.append(column);
        var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
        column.append(buttonLayout);
        var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/' + minibossIcon + '.png', function() {
            self.notifyBackendConvertTroopToChampion(_data, _type);
        }, '', 6);
        button.bindTooltip({ contentType: 'ui-element', elementId: (_data.IsChampion === true ? 'woditor.dechampionization' : 'woditor.championization') });

        // remove the entire entry
        var column = this.addColumn(15);
        upperRow.append(column);
        var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
        column.append(buttonLayout);
        var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/cancel.png', function() {
            self.notifyBackendRemoveTroop(_data, _type);
        }, '', 6);
        button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.removeentry' });

        // for name
        var lowerRow = this.addRow(50);
        rightColumn.append(lowerRow);
        var name = $('<div class="troop-name is-vertical-center title-font-big font-bold ' + color + ' ">' + _data.Name + '</div>');
        lowerRow.append(name);
    }

    return strength;
};

WorldEditorScreen.prototype.addLootEntry = function(_data, _parentDiv)
{
    var self = this;
    var itemContainer = $('<div class="item-icon-container"/>');
    _parentDiv.append(itemContainer);

    var imageLayout = $('<div class="item-icon-layout"/>');
    itemContainer.append(imageLayout);
    var image = imageLayout.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.fitImageToParent(0, 0);
        _image.removeClass('');
    }, null, '');
    image.data('ID', _data.ID);

    var overlays = _data.ImageOverlayPath;
    if (overlays !== undefined && overlays !== '' && overlays.length > 0)
    {
        overlays.forEach(function (_imagePath) {
            if (_imagePath === '') return;

            var overlayImage = imageLayout.createImage(Path.ITEMS + _imagePath, function(_image) {
                _image.fitImageToParent(0, 0);
                _image.removeClass('');
            }, null, '');
            overlayImage.css('pointer-events', 'none');
        });
    }

    if (_data.ShowAmount === true)
    {
        var amountLabel = $('<div class="label text-font-very-small font-shadow-outline"/>'); //font-size-13
        imageLayout.append(amountLabel);
        amountLabel.html(_data.Amount);
        amountLabel.css('color', _data.AmountColor);
    }

    // set up event listeners
    image.click(this, function(_event) {
        var element = $(this);
        var id = element.data('ID');
        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            self.notifyBackendRemoveLoot(id);
    });
    image.bindTooltip({ contentType: 'ui-item', entityId: _data.Owner, itemId: _data.ID, itemOwner: 'woditor.loot'});
};

WorldEditorScreen.prototype.updateLocationName = function(_name)
{
    var result = this.updateLocationData({Name: _name});
    var name = result.Element.find('.name:first');
    if (name.length > 0) {
        name.html(_name);
    }
    return result.Data.ID;
}

WorldEditorScreen.prototype.updateLocationNewFaction = function (_data)
{  
    var result = this.updateLocationData(_data);
    var faction = this.getFaction(result.Data.Faction);
    this.mLocation.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
    this.mLocation.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
};

WorldEditorScreen.prototype.updateLocationTroopsLabel = function(_strength, _num)
{
    this.mLocation.Strength.html('' + _strength + '');
    this.mLocation.TroopsLabel.html('Defenders: ' + _num + '/255');
}

WorldEditorScreen.prototype.updateLocationTroops = function(_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var result = this.updateLocationData(_data);
        _data = result.Data.Troops;
    }

    // recalculate troop strength and num
    var strength = 0;
    var num = 0;
    this.mLocation.Troops.empty();
    for (var i = 0; i < _data.length; i++) {
        strength += this.addTroopListEntry(_data[i], i, this.mLocation.Troops, 'location');
        num += _data[i].Num;
    }

    this.updateLocationTroopsLabel(strength, num);
}

WorldEditorScreen.prototype.updateLocationLoots = function(_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var result = this.updateLocationData(_data);
        _data = result.Data.Loots;
    }

    this.mLocation.Loots.empty();
    for (var i = 0; i < _data.length; i++) {
        this.addLootEntry(_data[i], this.mLocation.Loots);
    }
}

WorldEditorScreen.prototype.updateLocationNamedItemChance = function(_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var result = this.updateLocationData(_data);
        _data = result.Data.NamedItemChance;
    }

    if (_data === null || _data === undefined)
        _data = 0;

    this.mLocation.NamedItemChance.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.refreshloot', elementOwner: _data });
}

WorldEditorScreen.prototype.updateLocationBanner = function(_data)
{
    var result = this.updateLocationData(_data);
    var container = result.Element.find('.l-settlement-banner-container:first');
    if (container.length > 0) {
        var image = container.find('img:first');
        if (image.length > 0) {
            image.attr('src', Path.GFX + _data.Banner);
        }
    }
    this.mLocation.Banner.attr('src', Path.GFX + _data.Banner);
    return result.Data;
}

WorldEditorScreen.prototype.updateLocationImage = function(_data)
{
    var result = this.updateLocationData(_data);
    var container = result.Element.find('.l-settlement-image-container:first');
    if (container.length > 0) {
        var image = container.find('img:first');
        if (image.length > 0) {
            image.attr('src', Path.GFX + _data.ImagePath);
        }
    }
    this.mLocation.Image.attr('src', Path.GFX + _data.ImagePath);
    return result.Data;
}

WorldEditorScreen.prototype.updateLocationDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        var faction = this.getFaction(data.Faction);

        this.mLocation.Name.setInputText(data.Name);
        this.mLocation.Resources.setInputText('' + data.Resources + '');
        this.mLocation.Image.attr('src', Path.GFX + data.ImagePath);
        this.mLocation.Image.bindTooltip({ contentType: 'ui-element', elementId: data.ID, elementOwner: 'woditor.world_entity_clickable' });
        this.mLocation.Fortification.attr('src', Path.GFX + 'ui/icons/fortification_' + data.Fortification + '.png');
        this.mLocation.Terrain.css('background-image', 'url("' + Path.GFX + data.Terrain + '")');
        this.updateLocationNamedItemChance(data.NamedItemChance);
        this.updateLocationTroops(data.Troops);
        this.updateLocationLoots(data.Loots);

        if (data.Banner === undefined || data.Banner === null) {
            this.mLocation.Banner.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
        }
        else {
            this.mLocation.Banner.attr('src', Path.GFX + data.Banner);
        }
        
        if (faction === null) {
            this.mLocation.FactionBanner.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
            this.mLocation.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.nofaction' });
        }
        else {
            this.mLocation.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
            this.mLocation.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
        }
    }
};

WorldEditorScreen.prototype.fillLocationSearchItemResult = function(_data)
{   
    var self = this;
    this.mLocation.SearchResult.empty();
    if (_data.length == 0) {
        var foundNothingLabel = this.addContainer('100%', 5.0, 'text-font-normal font-bold font-color-ink');
        foundNothingLabel.css('text-align', 'center');
        foundNothingLabel.html('No Item Matches');
        this.mLocation.SearchResult.append(foundNothingLabel);
        return;
    }

    for (var i = 0; i < _data.length; i++) {
        var itemContainer = $('<div class="item-container"/>');
        this.mLocation.SearchResult.append(itemContainer);

        var imageLayout = $('<div class="item-layout"/>');
        itemContainer.append(imageLayout);
        var image = imageLayout.createImage(Path.GFX + _data[i].ImagePath, null, null, '');
        image.data('entry', _data[i]);

        if (_data[i].LayerImagePath.length > 0) {
            var overlayImage = imageLayout.createImage(Path.ITEMS + _data[i].LayerImagePath, null, null, '');
            overlayImage.css('pointer-events', 'none');
        }

        // set up event listeners
        image.click(this, function(_event) {
            var element = $(this);
            var data = element.data('entry');
            self.mLocation.SearchItem.attr('src', Path.GFX + data.ImagePath);
            self.mLocation.SearchItem.data('script', data.Script);
            self.mLocation.SearchItem.bindTooltip({ contentType: 'ui-element', elementId: data.ID, elementOwner: 'woditor.searchresult' });
            
            if (data.LayerImagePath.length > 0) {
                if (self.mLocation.SearchItemOverlay != null) {
                    self.mLocation.SearchItemOverlay.attr('src', Path.ITEMS + data.LayerImagePath);
                }
                else {
                    self.mLocation.SearchItemOverlay = self.mLocation.SearchItemContainer.createImage(Path.ITEMS + data.LayerImagePath, null, null, '');
                    self.mLocation.SearchItemOverlay.css('pointer-events', 'none');
                }
            }
            else if (self.mLocation.SearchItemOverlay != null) {
                self.mLocation.SearchItemOverlay.remove();
            }

            if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true) {
                self.notifyBackendAddItemToLoot(data.Script);
            }
        });

        image.bindTooltip({ contentType: 'ui-element', elementId: _data[i].ID, elementOwner: 'woditor.searchresult' });
    }
}

WorldEditorScreen.prototype.createTroopNumInputDIV = function(_key, _definition, _parentDiv, _index, _type)
{
    var self = this;
    var font = 'Font' in _definition ? _definition.Font  : 'title-font-big';
    var color = 'Color' in _definition ? _definition.Color : 'font-color-title';

    var column30 = this.addColumn(30);
    _parentDiv.append(column30);
    var label = $('<div class="l-input-small-label ' + font + ' font-bold ' + color + '">' + _key + '</div>');
    column30.append(label);

    var column70 = this.addColumn(70);
    _parentDiv.append(column70);
    var inputLayout = $('<div class="l-input-small is-center"/>');
    column70.append(inputLayout);
    _definition.Input = inputLayout.createInput('', _definition.Min, _definition.Max, null, null, 'title-font-medium font-bold font-color-brother-name', function (_input) {
        self.confirmTroopNumChanges(_input, _index, _type);
    });
    _definition.Input.assignInputEventListener('focusout', function(_input, _event) {
        self.confirmTroopNumChanges(_input, _index, _type);
    });
    _definition.Input.assignInputEventListener('click', function(_input, _event) {
        _input.data('IsUpdated', false);
    });
    _definition.Input.assignInputEventListener('mouseover', function(_input, _event) {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });
    _definition.Input.assignInputEventListener('mouseout', function(_input, _event) {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });
    _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    _definition.Input.css('background-size', '5.2rem 4.1rem');
    _definition.Input.css('text-align', 'center');

    if (_definition.Value !== null)
        _definition.Input.val(_definition.Value);
};

WorldEditorScreen.prototype.confirmTroopNumChanges = function(_input, _index, _type)
{
    if (_input.data('IsUpdated') === true)
        return;

    var parent = _type === 'unit' ? this.mUnit : this.mLocation;
    var element = parent.Selected;
    var i = element.data('index');
    var data = parent.Data[i];
    var text = _input.getInputText();
    var value = 0;
    var isValid = true;

    if (text.length <= 0) {
        isValid = false;
    }
    else {
        value = this.isValidNumber(text, 1, 255);
        if (value === null)
            isValid = false;
    }

    if (isValid === true) {
        _input.val('' + value + '');
        _input.data('IsUpdated', true);
        var different = data.Troops[_index].Num - value;
        data.Troops[_index].Num = value;
        element.data('entry', data);
        this.notifyBackendChangeTroopNum(data.Troops, _index, different, _type);
    }
    else {
        _input.val('' + data.Troops[_index].Num + '');
    }
};

WorldEditorScreen.prototype.changeSearchItemFilter = function(_button, _i, _change)
{   
    if (_change !== true) {
        this.mLocation.SearchFilter = _button.data('filter');
        return;
    }

    var index = _i;
    var image;
    switch(index)
    {
    case 1:
        image = 'icons/special';
        break;

    case 2:
        image = 'icons/ammo';
        break;

    case 3:
        image = 'icons/tools';
        break;

    case 4:
        image = 'icons/crafting';
        break;

    case 5:
        image = 'icons/armor_body';
        break;

    case 6:
        image = 'icons/armor_head';
        break;

    case 7:
        image = 'icons/melee_skill';
        break;

    case 8:
        image = 'icons/sturdiness';
        break;

    case 9:
        image = 'icons/accessory';
        break;

    default:
        image = 'buttons/filter_all';
    }

    _button.data('filter', index);
    _button.changeButtonImage(Path.GFX + 'ui/' + image + '.png');
    _button.bindTooltip({ contentType: 'ui-element', elementId: index, elementOwner: 'woditor.searchfilterbutton' });
};