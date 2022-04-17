
WorldEditorScreen.prototype.getUnit = function (_id)
{
    for (var i = 0; i < this.mUnit.Data.length; i++) {
        var result = this.mUnit.Data[i];
        if (result.ID === _id) {
            return result;
        }
    }
    return null;
}

WorldEditorScreen.prototype.updateUnitData = function(_newData)
{
    var element = this.mUnit.Selected;
    var index = element.data('index');
    var data = this.mUnit.Data[index];
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

WorldEditorScreen.prototype.addUnitFilter = function(_data)
{
    var self = this;
    this.mUnit.ExpandableListScroll.empty();

    // add the show all
    this.mUnit.DefaultFilter = this.addExpandableEntry({Name: 'All', Filter: null}, 'All', this.mUnit, self.filterUnitWithData);
    this.mUnit.DefaultFilter.addClass('is-selected');

    for (var i = 0; i < _data.length; i++) {
        this.addExpandableEntry(_data[i], _data[i].Name, this.mUnit, self.filterUnitWithData);
    }

    this.mUnit.IsExpanded = false;
    this.expandExpandableList(false, this.mUnit);
    this.mUnit.ExpandLabel.find('.label:first').html('All');
};

WorldEditorScreen.prototype.filterUnitWithData = function (_filterData)
{
    if (_filterData.Filter === null) {
        this.addUnitsData(null, true);
        return;
    }

    this.mUnit.ListScrollContainer.empty();
    var key = _filterData.Search;
    var filterKey = _filterData.Filter[0];
    var filterValue = _filterData.Filter[1];

    for(var i = 0; i < this.mUnit.Data.length; ++i) {
        var data = this.mUnit.Data[i];
        if (key !== null) {
            var getData = this.getData(key[0], data[key[1]]);
            if (getData !== null && getData[filterKey] === filterValue)
                this.addUnitListEntry(data, i);
        }
        else {
            if (data[filterKey] === filterValue)
                this.addUnitListEntry(data, i);
        }
    }

    this.selectUnitListEntry(this.mUnit.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
};

WorldEditorScreen.prototype.addUnitsData = function(_data, _isLoaded)
{
    var self = this;
    this.mUnit.ListScrollContainer.empty();
    this.mUnit.ExpandableList.deselectListEntries();
    this.mUnit.DefaultFilter.addClass('is-selected');
    this.mUnit.ExpandLabel.find('.label:first').html('All');

    if (_isLoaded !== true)
        this.mUnit.Data = _data;

    for(var i = 0; i < this.mUnit.Data.length; ++i) {
        this.addUnitListEntry(this.mUnit.Data[i], i);
    }

    this.selectUnitListEntry(this.mUnit.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
    // load back and scroll to the position where you have left to see a location
    if (this.mShowEntityOnMap !== null && this.mShowEntityOnMap.Type === 'unit') {   
        var find = null;
        this.mUnit.ListScrollContainer.find('.list-entry-fat').each(function(index, element) {
            var entry = $(element);
            if (entry.data('entry').ID === self.mShowEntityOnMap.ID) {
                find = entry;
            }
        });

        if (find !== null && find.length > 0) {
            this.selectUnitListEntry(find, true);
        }
        
        this.mShowEntityOnMap = null;
    }
};

WorldEditorScreen.prototype.addUnitListEntry = function(_data, _index)
{
    var self = this;
    var result = $('<div class="l-settlement-row"/>'); // reuse the list entry from settlement screen :evilgirns:
    this.mUnit.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-fat"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.data('index', _index);
    entry.click(this, function(_event) {
        _event.data.selectUnitListEntry($(this));
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
        self.notifyBackendShowWorldEntityOnMap({ID: _data.ID, Type: 'unit'});
    }, 'display-block', 6);
    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.distance' });
};

WorldEditorScreen.prototype.selectUnitListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mUnit.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
            this.mUnit.ListContainer.scrollListToElement(_element);

        _element.addClass('is-selected');
        this.mUnit.Selected = _element;
        this.updateUnitDetailsPanel(this.mUnit.Selected);
        this.mUnit.DetailsPanel.showThisDiv(true);
    }
    else
    {
        this.mUnit.Selected = null;
        this.updateUnitDetailsPanel(this.mUnit.Selected);
        this.mUnit.DetailsPanel.showThisDiv(false);
    }
};

WorldEditorScreen.prototype.updateUnitName = function(_name)
{
    var result = this.updateUnitData({Name: _name});
    var name = result.Element.find('.name:first');
    if (name.length > 0) {
        name.html(_name);
    }
    return result.Data.ID;
}

WorldEditorScreen.prototype.updateUnitNewFaction = function (_data)
{  
    var result = this.updateUnitData(_data);
    var faction = this.getFaction(result.Data.Faction);
    this.mUnit.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
    this.mUnit.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
};

WorldEditorScreen.prototype.updateUnitTroopsLabel = function(_strength, _num)
{
    this.mUnit.Strength.html('' + _strength + '');
    this.mUnit.TroopsLabel.html('Troops: ' + _num + '/255');
}

WorldEditorScreen.prototype.updateUnitTroops = function(_data)
{
    if (typeof _data === 'object' && 'IsUpdating' in _data) {
        var result = this.updateUnitData(_data);
        _data = result.Data.Troops;
    }

    // recalculate troop strength and num
    var strength = 0;
    var num = 0;
    this.mUnit.Troops.empty();
    for (var i = 0; i < _data.length; i++) {
        strength += this.addTroopListEntry(_data[i], i, this.mUnit.Troops, 'unit');
        num += _data[i].Num;
    }

    this.updateUnitTroopsLabel(strength, num);
}

WorldEditorScreen.prototype.updateUnitBanner = function(_data)
{
    var result = this.updateUnitData(_data);
    var container = result.Element.find('.l-settlement-banner-container:first');
    if (container.length > 0) {
        var image = container.find('img:first');
        if (image.length > 0) {
            image.attr('src', Path.GFX + _data.Banner);
        }
    }
    this.mUnit.Banner.attr('src', Path.GFX + _data.Banner);
    return result.Data;
}

WorldEditorScreen.prototype.updateUnitImage = function(_data)
{
    var result = this.updateUnitData(_data);
    var container = result.Element.find('.l-settlement-image-container:first');
    if (container.length > 0) {
        var image = container.find('img:first');
        if (image.length > 0) {
            image.attr('src', Path.GFX + _data.ImagePath);
        }
    }
    this.mUnit.Image.attr('src', Path.GFX + _data.ImagePath);
    return result.Data;
}

WorldEditorScreen.prototype.updateUnitCheckboxes = function(_data)
{
    var self = this;
    var controls = [
        'IsLooting',
        'IsSlowerAtNight',
        'IsAttackableByAI',
        'IsLeavingFootprints',
        'IsAlwaysAttackingPlayer',
    ];
    controls.forEach(function (_key) {
        if (self.mUnit[_key].Checkbox.is(':checked') === true && _data[_key] === false)
            self.mUnit[_key].Checkbox.iCheck('uncheck');
        else if (self.mUnit[_key].Checkbox.is(':checked') === false && _data[_key] === true)
            self.mUnit[_key].Checkbox.iCheck('check');
    });
}

WorldEditorScreen.prototype.updateUnitSliders = function(_data)
{
    var self = this;
    var controls = [
        'BaseMovementSpeed',
        'VisibilityMult',
        'LootScale',
    ];
    controls.forEach(function (_key) {
        var definition = self.mUnit[_key];
        definition.Control.val(_data[_key]);
        definition.Label.text('' + _data[_key] + definition.Postfix);
    });
}

WorldEditorScreen.prototype.updateUnitDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        var faction = this.getFaction(data.Faction);

        this.mUnit.Name.setInputText(data.Name);
        this.mUnit.Resources.setInputText('' + data.Resources + '');
        this.mUnit.Banner.attr('src', Path.GFX + data.ImagePath);
        this.mUnit.Image.attr('src', Path.GFX + data.ImagePath);
        this.mUnit.Image.bindTooltip({ contentType: 'ui-element', elementId: data.ID, elementOwner: 'woditor.world_entity_clickable' });
        this.mUnit.Terrain.css('background-image', 'url("' + Path.GFX + data.Terrain + '")');
        this.updateUnitTroops(data.Troops);
        this.updateUnitCheckboxes(data);
        this.updateUnitSliders(data);

        if (data.Banner === undefined || data.Banner === null) {
            this.mUnit.Banner.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
        }
        else {
            this.mUnit.Banner.attr('src', Path.GFX + data.Banner);
        }

        if (faction === null) {
            this.mUnit.FactionBanner.attr('src', Path.GFX + 'ui/banners/missing_banner.png');
            this.mUnit.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.nofaction' });
        }
        else {
            this.mUnit.FactionBanner.attr('src', Path.GFX + faction.ImagePath);
            this.mUnit.FactionBanner.bindTooltip({ contentType: 'ui-element', elementId: faction.ID, elementOwner: 'woditor.factionbanner' });
        }
    }
};
