

OriginCustomizerScreen.prototype.switchBetweenSituationsAttachments = function ()
{
    this.mSettlement.IsViewingAttachment = !this.mSettlement.IsViewingAttachment;

    if(this.mSettlement.Selected !== null && this.mSettlement.Selected.length > 0)
        this.updateSideListScroll(this.mSettlement.Selected.data('entry'));

    if (this.mSettlement.IsViewingAttachment === true)
        this.mSettlement.SideButton.changeButtonText('Attachments');
    else
        this.mSettlement.SideButton.changeButtonText('Situations');
};

OriginCustomizerScreen.prototype.createSettlementBuildingSlot = function (_index, _parentDiv)
{
    var slot = $('<div class="is-building-slot building' + _index + '"/>');
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
    this.mSettlement.Buildings[_index].bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.freebuildingslot' });
};

OriginCustomizerScreen.prototype.addSettlementsData = function (_data)
{
    this.mSettlement.ListScrollContainer.empty();
    this.mSettlement.Data = _data;

    for(var i = 0; i < _data.length; ++i)
    {
        var entry = _data[i];
        this.addSettlementListEntry(entry, i);
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0), true);
};

OriginCustomizerScreen.prototype.addSettlementListEntry = function(_data, _index)
{
    var result = $('<div class="l-settlement-row"/>');

    if (_index === 0)
        result.css('margin-top', '1.0rem');

    this.mSettlement.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry-fat"/>');
    result.append(entry);
    entry.data('entry', _data);
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

OriginCustomizerScreen.prototype.selectSettlementListEntry = function(_element, _scrollToEntry)
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

OriginCustomizerScreen.prototype.updateSettlementDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');

        this.mSettlement.Name.setInputText(data.Name);
        this.mSettlement.Image.attr('src', Path.GFX + data.ImagePath);
        this.updateSideListScroll(data);
        
        for (var i = 0; i < data.Buildings.length; i++) {
            var entry = data.Buildings[i];
            var image = this.mSettlement.Buildings[i];
           
            if (entry === undefined || entry === null) {
                if (image.attr('src') == Path.GFX + 'ui/buttons/free_building_slot_icon.png')
                    continue;

                image.attr('src', Path.GFX + 'ui/buttons/free_building_slot_icon.png');
                image.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.freebuildingslot' });
            }
            else {
                image.attr('src', Path.GFX + entry.ImagePath);
                image.bindTooltip({ contentType: 'ui-element', elementId: entry.TooltipId , elementOwner: 'origincustomizer.buildings'});
            }
        }

        var noOwner = data.Owner === undefined || data.Owner === null;
        var isTheSame = !noOwner && data.Owner === data.Faction;
        var image = this.mSettlement.OwnerBanner.find('img:first');

        this.mSettlement.FactionBanner.attr('src', Path.GFX + this.mFaction.Data[data.Faction].ImagePath);

        if (noOwner || isTheSame) {
            this.mSettlement.OwnerBanner.removeClass('display-block').addClass('display-none');
        }
        else {
            this.mSettlement.OwnerBanner.removeClass('display-none').addClass('display-block');
            image.attr('src', Path.GFX + this.mFaction.Data[data.Owner].ImagePath);
        }
    }
};

OriginCustomizerScreen.prototype.updateSideListScroll = function (_data)
{
    this.mSettlement.Attachments.empty();
    this.mSettlement.Situations.empty();
   
    var data = _data.Attachments;
    // create the add-new-attached-location button
    this.addAttachmentEntry({
        ImagePath: 'ui/buttons/free_building_slot_icon.png',
        ID: 'origincustomizer.freeattachmentslot',
    });

    for (var i = 0; i < data.length; i++) {
        this.addAttachmentEntry(data[i]);
    }
    


    var data = _data.Situations;
    var row = $('<div class="situation-row"/>');
    this.mSettlement.Situations.append(row);

    var containerLayout = $('<div class="l-situations-group-container"/>');
    var container = $('<div class="l-situation-groups-container"/>');
    containerLayout.append(container);

    for (var i = 0; i < data.length; i++) {
        this.addSituationEntry(data[i], container, false);
    }

    // create the add-new-attached-location button
    this.addSituationEntry({
        ImagePath: 'ui/buttons/free_slot_icon.png',
        ID: 'origincustomizer.freesituationslot',
    }, container, true);

    row.append(containerLayout);
};

OriginCustomizerScreen.prototype.addSituationEntry = function (_data, _parentDiv, _isButton)
{
    var image = $('<img/>');
    image.attr('src', Path.GFX + _data.ImagePath);
    _parentDiv.append(image);

    if (_isButton === true)
    {
        image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID });
    }
    else
    {
        image.bindTooltip({ contentType: 'settlement-status-effect', statusEffectId: _data.ID });
    }
};

OriginCustomizerScreen.prototype.addAttachmentEntry = function (_data)
{
    var isButton = _data.ID === 'origincustomizer.freeattachmentslot';
    var entry = $('<div class="attach-row"/>');
    this.mSettlement.Attachments.append(entry);
    var image = entry.createImage(Path.GFX + _data.ImagePath, function(_image)
    {
        _image.centerImageWithinParent(0, 0, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    image.click(function(_event)
    {
        //if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            //self.notifyBackendContractRemoved(_data.ID);
        //else
            //self.notifyBackendContractClicked(_data.ID);
    });
    image.mouseover(function()
    {
        this.classList.add('is-highlighted');
    });
    image.mouseout(function()
    {
        this.classList.remove('is-highlighted');
    });

    if (isButton)
        image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID });
    else
        image.bindTooltip({ contentType: 'ui-element', elementId: _data.ID, elementOwner: 'origincustomizer.attached_location' });
};