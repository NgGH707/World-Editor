
WorldEditorScreen.prototype.addLocationFilter = function (_data)
{
    var self = this;
    this.mLocation.ExpandableListScroll.empty();

    // add the place holder
    var placeholderName = this.mLocation.ExpandLabel.find('.label:first');

    // add the filter-all option, not recommend cuz the map has lots of location
    var specialEntry = this.addExpandableEntry({NoFilter: true}, 'All', this.mLocation);
    specialEntry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mLocation.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterLocationsByType();
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    // add the filter for enemy camp option
    this.mLocation.DefaultFilter = this.addExpandableEntry({NoFilter: true}, 'Camps', this.mLocation);
    this.mLocation.DefaultFilter.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mLocation.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterLocationsByType('IsCamp', true);
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    // add the filter stronghold option
    var specialEntry = this.addExpandableEntry({NoFilter: true}, 'Legendary', this.mLocation);
    specialEntry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mLocation.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterLocationsByType('IsLegendary', true);
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    // add the filter passive location option
    var specialEntry = this.addExpandableEntry({NoFilter: true}, 'Misc', this.mLocation);
    specialEntry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') !== true) {
            self.mLocation.ExpandableList.deselectListEntries();
            div.addClass('is-selected');
            self.filterLocationsByType('IsPassive', true);
            var label = div.data('label');
            placeholderName.html(label);
        }
    });

    for (var i = 0; i < _data.length; i++) {
        var entryData = _data[i];
        var entry = this.addExpandableEntry(entryData, this.mFaction.Data[entryData.Index].Name, this.mLocation);
        entry.click(this, function(_event) {
            var div = $(this);
            if (div.hasClass('is-selected') !== true) {
                var data = div.data('key');
                self.mLocation.ExpandableList.deselectListEntries();
                div.addClass('is-selected');
                self.filterLocationsByFaction(data);
                var label = div.data('label');
                placeholderName.html(label);
            }
        });
    }

    this.mLocation.IsExpanded = false;
    this.expandExpandableList(false, this.mLocation);
};

WorldEditorScreen.prototype.filterLocationsByType = function (_filter1, _value1, _filter2, _value2)
{
    var _data = this.mLocation.Data;
    var noFilter = _filter1 === undefined || _filter1 === null;
    var extraFilter = _filter2 === undefined || _filter2 === null;
    this.mLocation.ListScrollContainer.empty();

    for(var i = 0; i < _data.length; ++i) {
        if (noFilter || _data[i][_filter1] === _value1 && (extraFilter || _data[i][_filter2] === _value2)) 
            this.addLocationListEntry(_data[i], i);
    }

    this.selectLocationListEntry(this.mLocation.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
    this.expandExpandableList(false, this.mLocation);
};

WorldEditorScreen.prototype.filterLocationsByFaction = function (_filter)
{
    var _data = this.mLocation.Data;
    var NoFilter = _filter === undefined || _filter === null;
    this.mLocation.ListScrollContainer.empty();

    for(var i = 0; i < _data.length; ++i) {
        if (NoFilter || _filter.ID == _data[i].Faction) 
            this.addLocationListEntry(_data[i], i);
    }

    this.selectLocationListEntry(this.mLocation.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
    this.expandExpandableList(false, this.mLocation);
};

WorldEditorScreen.prototype.addLocationsData = function(_data)
{
    var self = this;
    this.mLocation.ListScrollContainer.empty();
    this.mLocation.ExpandableList.deselectListEntries();
    this.mLocation.DefaultFilter.addClass('is-selected');
    this.mLocation.Data = _data;

    // load back and scroll to the position where you have left to see a location
    if (this.mShowEntityOnMap !== null && this.mShowEntityOnMap.Type === 'location')
    {
        this.filterLocationsByType();

        var find = null;
        this.mLocation.ListScrollContainer.find('.list-entry-fat').each(function(index, element) {
            var entry = $(element);
            if (entry.data('entry').ID === self.mShowEntityOnMap.ID) {
                find = entry;
            }
        });

        if (find !== null && find.length > 0) {
            this.selectLocationListEntry(find, true);
        }

        this.mShowEntityOnMap = null;
    }
    else
    {
        this.filterLocationsByType('IsCamp', true);
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
        self.notifyBackendShowWorldEntityOnMap(_data.ID, 'location');
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
        this.mLocation.DetailsPanel.addClass('display-block').removeClass('display-none');
    }
    else
    {
        this.mLocation.Selected = null;
        this.updateLocationDetailsPanel(this.mLocation.Selected);
        this.mLocation.DetailsPanel.addClass('display-none').removeClass('display-block');
    }
};

WorldEditorScreen.prototype.addTroopListEntry = function (_data, _index, _listScrollContainer)
{
    var result = $('<div class="troop-row"/>');
    var strength = _data.Strength * _data.Num;
    _listScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-noice"/>');
    result.append(entry);
    entry.data('entry', _data);

    var leftColumn = this.addColumn(25);
    result.append(leftColumn);
    var iconLayout = this.addLayout(5.6, 5.6, 'is-center');
    leftColumn.append(iconLayout);
    var icon = iconLayout.createImage(Path.GFX + _data.Icon, function(_image)
    {
        _image.fitImageToParent(0, 0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    var minibossIcon = 'special';
    var color = 'font-color-white';
    if (_data.IsChampion === true)
    {
        var iconLayout = this.addLayout(2.2, 2.2, 'is-horizontal-center');
        iconLayout.css('top', '6.6rem');
        leftColumn.append(iconLayout);
        var icon = iconLayout.createImage(Path.GFX + 'ui/icons/miniboss.png', function(_image)
        {
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
        this.createSmallInputDIV('Num:', {
            Input: null,
            Value: _data.Num,
            Min: 0,
            Max: 3,
            Color: color,
            Font: 'title-font-normal'
        }, column);

        // to display the strength this troop entry contributes
        var column = this.addColumn(30);
        upperRow.append(column);
        var iconLayout = this.addLayout(3.0, 3.0, 'is-vertical-center');
        column.append(iconLayout);
        var image = iconLayout.createImage(Path.GFX + 'ui/icons/fist.png', function(_image)
        {
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
            //self.onPreviousBannerClicked();
        }, '', 6);
        button.bindTooltip({ contentType: 'ui-element', elementId: (_data.IsChampion === true ? 'woditor.dechampionization' : 'woditor.championization') });

        // remove the entire entry
        var column = this.addColumn(15);
        upperRow.append(column);
        var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
        column.append(buttonLayout);
        var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/cancel.png', function() {
            //self.onPreviousBannerClicked();
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

WorldEditorScreen.prototype.updateLocationName = function(_name)
{
    var element = this.mLocation.Selected;
    var index = element.data('index');
    var name = element.find('.name:first');
    if (name.length > 0) {
        name.html(_name);
    }
    var data = this.mLocation.Data[this.mLocation.FilterType][index];
    data.Name = _name;
    element.data('entry', data);
    return data.ID;
}

WorldEditorScreen.prototype.updateLocationDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        var strength = 0;

        this.mLocation.Troops.empty();
        for (var i = 0; i < data.Troops.length; i++) {
            strength += this.addTroopListEntry(data.Troops[i], i, this.mLocation.Troops);
        }

        this.mLocation.Name.setInputText(data.Name);
        this.mLocation.Resources.setInputText('' + data.Resources + '');
        this.mLocation.Strength.html('' + strength + '');
        this.mLocation.Image.attr('src', Path.GFX + data.ImagePath);
    }
};


WorldEditorScreen.prototype.createSmallInputDIV = function(_key, _definition, _parentDiv)
{
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
        //self.ConfirmAttributeChange(_input, _key);
    });
    _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    _definition.Input.css('background-size', '5.2rem 4.1rem');
    _definition.Input.css('text-align', 'center');

    _definition.Input.assignInputEventListener('mouseover', function(_input, _event) {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });

    _definition.Input.assignInputEventListener('mouseout', function(_input, _event) {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });

    /*_definition.Input.assignInputEventListener('focusout', function(_input, _event)
    {
        //self.ConfirmAttributeChange(_input, _key);
    });*/

    /*_definition.Input.assignInputEventListener('click', function(_input, _event) {
    });*/

    if (_definition.Value !== null)
        _definition.Input.val(_definition.Value);
};