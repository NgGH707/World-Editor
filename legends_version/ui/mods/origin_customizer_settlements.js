
OriginCustomizerScreen.prototype.addSettlementsData = function (_data)
{
    this.mSettlement.ListScrollContainer.empty();
    this.mSettlement.Data = _data;

    for(var i = 0; i < _data.length; ++i)
    {
        var entry = _data[i];
        this.addSettlementListEntry(entry);
    }

    this.selectSettlementListEntry(this.mSettlement.ListContainer.findListEntryByIndex(0), true);
};

OriginCustomizerScreen.prototype.addSettlementListEntry = function(_data)
{
    var result = $('<div class="l-settlement-row"/>');
    this.mFaction.ListScrollContainer.append(result);

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

    var imageOffsetX = ('ImageOffsetX' in _data ? _data['ImageOffsetX'] : 0);
    var imageOffsetY = ('ImageOffsetY' in _data ? _data['ImageOffsetY'] : 0);
    imageContainer.createImage(Path.GFX + _data['ImagePath'], function (_image)
    {
        _image.centerImageWithinParent(imageOffsetX, imageOffsetY, 1.0);
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
        //this.updateFactionDetailsPanel(this.mSettlement.Selected);
    }
    else
    {
        this.mSettlement.Selected = null;
        //this.updateFactionDetailsPanel(this.mSettlement.Selected);
    }
};