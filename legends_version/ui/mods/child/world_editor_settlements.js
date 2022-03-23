
WorldEditorScreen.prototype.createSettlementBuildingSlot = function (_index, _parentDiv)
{
    var slot = $('<div class="is-building-slot"/>');
    slot.css('left', (1.5 + _index * 17.0) + 'rem');
    _parentDiv.append(slot);
    this.mSettlement.Buildings[_index] = slot.createImage(Path.GFX + 'ui/buttons/free_building_slot_icon.png', function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    this.mSettlement.Buildings[_index].click(function(_event)
    {
        //if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            //self.notifyBackendContractRemoved(_data.ID);
        //else
            //self.notifyBackendContractClicked(_data.ID);
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

WorldEditorScreen.prototype.addSettlementsData = function (_data)
{
    this.mSettlement.ListScrollContainer.empty();
    this.mSettlement.Data = _data;

    for(var i = 0; i < _data.length; ++i)
    {
        var entry = _data[i];
        this.addSettlementListEntry(entry, i);
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0, 'list-entry-fat'), true);
};

WorldEditorScreen.prototype.addSettlementListEntry = function(_data, _index)
{
    var result = $('<div class="l-settlement-row"/>');

    if (_index === 0)
        result.css('margin-top', '1.0rem');

    this.mSettlement.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-fat"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.data('index', _index);
    entry.click(this, function(_event)
    {
        _event.data.selectSettlementListEntry($(this));
    });

    // settlement image
    var imageContainer = $('<div class="l-settlement-image-container"/>');
    entry.append(imageContainer);

    imageContainer.createImage(Path.GFX + _data['ImagePath'], function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // banner image
    var imageContainer = $('<div class="l-settlement-banner-container"/>');
    entry.append(imageContainer);

    var find = (_data.Owner !== undefined && _data.Owner !== null) ? _data.Owner : _data.Faction;
    imageContainer.createImage(Path.GFX + this.mFaction.Data[find].ImagePath, function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    var name = $('<div class="name title-font-normal font-bold font-color-white">' + _data['Name'] + '</div>');
    entry.append(name);
};

WorldEditorScreen.prototype.selectSettlementListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mSettlement.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
        {
            this.mSettlement.ListContainer.scrollListToElement(_element);
        }

        _element.addClass('is-selected');
        this.mSettlement.Selected = _element;
        this.updateSettlementDetailsPanel(this.mSettlement.Selected);
    }
    else
    {
        this.mSettlement.Selected = null;
        this.updateSettlementDetailsPanel(this.mSettlement.Selected);
    }
};

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

WorldEditorScreen.prototype.updateSettlementDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');

        this.mSettlement.Name.setInputText(data.Name);
        this.mSettlement.Resources.val('' + data.Resources + '');
        this.mSettlement.Wealth.val('' + data.Wealth + '%');
        this.mSettlement.Image.attr('src', Path.GFX + data.ImagePath);
        this.updateSideListScroll(data);
        
        for (var i = 0; i < data.Buildings.length; i++) {
            var entry = data.Buildings[i];
            var image = this.mSettlement.Buildings[i];
           
            if (entry === undefined || entry === null) {
                if (image.attr('src') == Path.GFX + 'ui/buttons/free_building_slot_icon.png')
                    continue;

                image.attr('src', Path.GFX + 'ui/buttons/free_building_slot_icon.png');
                image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
            }
            else {
                if (image.attr('src') == Path.GFX + entry.ImagePath)
                    continue;

                image.attr('src', Path.GFX + entry.ImagePath);
                image.bindTooltip({ contentType: 'ui-element', elementId: entry.TooltipId , elementOwner: 'woditor.buildings'});
            }
        }

        this.mSettlement.FactionBanner.attr('src', Path.GFX + this.mFaction.Data[data.Faction].ImagePath);

        if (data.Owner === undefined || data.Owner === null)
            this.mSettlement.OwnerBanner.attr('src', Path.GFX + 'ui/banners/add_banner.png');
        else 
            this.mSettlement.OwnerBanner.attr('src', Path.GFX + this.mFaction.Data[data.Owner].ImagePath);
    }
};

WorldEditorScreen.prototype.updateSideListScroll = function (_data)
{
    this.mSettlement.Attachments.empty();
    this.mSettlement.Situations.empty();
   
    // update attached location list
    var data = _data.Attachments;
    for (var i = 0; i < data.length; i++) {
        this.addAttachmentEntry(data[i]);
    }

    // update situation list
    var data = _data.Situations;
    var row = $('<div class="situation-row"/>');
    this.mSettlement.Situations.append(row);
    var containerLayout = $('<div class="l-situations-group-container"/>');
    var container = $('<div class="l-situation-groups-container"/>');
    containerLayout.append(container);
    for (var i = 0; i < data.length; i++) {
        this.addSituationEntry(data[i], container);
    }
    row.append(containerLayout);
};

WorldEditorScreen.prototype.addSituationEntry = function (_data, _parentDiv)
{
    var image = $('<img/>');
    image.attr('src', Path.GFX + _data.ImagePath);
    _parentDiv.append(image);

    image.click(function(_event) {
    });
    image.mouseover(function() {
        this.classList.add('is-highlighted');
    });
    image.mouseout(function() {
        this.classList.remove('is-highlighted');
    });

    image.bindTooltip({ contentType: 'settlement-status-effect', statusEffectId: _data.ID });
};

WorldEditorScreen.prototype.addAttachmentEntry = function (_data)
{
    var entry = $('<div class="attach-row"/>');
    this.mSettlement.Attachments.append(entry);
    var image = entry.createImage(Path.GFX + _data.ImagePath, function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    image.click(function(_event) {
        //if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            //self.(_data.ID);
        //else
            //self.(_data.ID);
    });
    image.mouseover(function() {
        this.classList.add('is-highlighted');
    });
    image.mouseout(function() {
        this.classList.remove('is-highlighted');
    });

    image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID, elementOwner: 'woditor.attached_location' });
};