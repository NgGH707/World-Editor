

OriginCustomizerScreen.prototype.addFactionsData = function (_data)
{
    this.mFaction.ListScrollContainer.empty();
    this.mFaction.Data = _data;

    for(var i = 0; i < _data.length; ++i)
    {
        var entry = _data[i];
        this.addFactionListEntry(entry);
    }

    this.selectFactionListEntry(this.mFaction.ListContainer.findListEntryByIndex(0), true);
};

OriginCustomizerScreen.prototype.addFactionListEntry = function (_data)
{
    var result = $('<div class="l-row"/>');
    this.mFaction.ListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.click(this, function(_event)
    {
        _event.data.selectFactionListEntry($(this));
    });

    // left column
    var column = $('<div class="faction-column is-left"/>');
    entry.append(column);

    var imageOffsetX = ('ImageOffsetX' in _data ? _data['ImageOffsetX'] : 0);
    var imageOffsetY = ('ImageOffsetY' in _data ? _data['ImageOffsetY'] : 0);
    column.createImage(Path.GFX + _data['ImagePath'], function (_image)
    {
        _image.centerImageWithinParent(imageOffsetX, imageOffsetY, 0.5);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // right column
    column = $('<div class="faction-column is-right"/>');
    entry.append(column);

    // top row
    var row = $('<div class="faction-row is-top"/>');
    column.append(row);

    var name = $('<div class="name title-font-normal font-bold font-color-brother-name">' + _data['Name'] + '</div>');
    row.append(name);

    if('Landlord' in _data && _data.Landlord !== undefined && _data.Landlord !== null)
    {
        var landlordImageContainer = $('<div class="f-landlord-container"/>');
        row.append(landlordImageContainer);
        var landlordImage = landlordImageContainer.createImage(Path.GFX + _data.Landlord, function(_image) {
            _image.fitImageToParent(0, 0);
        }, null,'');
    }

    // bottom row
    row = $('<div class="faction-row is-bottom"/>');
    column.append(row);

    var assetsCenterContainer = $('<div class="l-assets-center-container"/>');
    row.append(assetsCenterContainer);

    // relation
    var assetsContainer = $('<div class="l-assets-container"/>');
    assetsCenterContainer.append(assetsContainer);

    var progressbarContainer = $('<div class="stats-progressbar-container ui-control-stats-progressbar-container-relations"></div>');
    assetsContainer.append(progressbarContainer);

    progressbarContainer.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.RelationsScreen.Relations, entityId: _data.ID });

    var progressbar = $('<div class="stats-progressbar ui-control-stats-progressbar relations"></div>');
    var newWidth = (_data.RelationNum / 100.0) * 100;
    progressbar.css('width', newWidth + '%');
    progressbarContainer.append(progressbar);

    var progressbarLabel = $('<div class="stats-progressbar-label text-font-small font-color-progressbar-label">' + _data['Relation'] + '</div>');
    progressbarContainer.append(progressbarLabel);
};

OriginCustomizerScreen.prototype.selectFactionListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mFaction.ListContainer.deselectListEntries();

        if (_scrollToEntry !== undefined && _scrollToEntry === true)
        {
            this.mFaction.ListContainer.scrollListToElement(_element);
        }

        _element.addClass('is-selected');
        this.mFaction.Selected = _element;
        this.updateFactionDetailsPanel(this.mFaction.Selected);
    }
    else
    {
        this.mFaction.Selected = null;
        this.updateFactionDetailsPanel(this.mFaction.Selected);
    }
};

OriginCustomizerScreen.prototype.updateFactionDetailsPanel = function(_element)
{
    if(_element !== null && _element.length > 0)
    {
        var data = _element.data('entry');
        
        this.mFaction.Banner.attr('src', Path.GFX + data.ImagePath);
        this.mFaction.Name.setInputText(data.Name);
        this.mFaction.PrevButton.enableButton(data.NoChangeName !== true);
        this.mFaction.NextButton.enableButton(data.NoChangeName !== true);
        this.addContractToFactionDetail(data.Contracts);

        /*if ('Landlord' in data && data.Landlord !== undefined && data.Landlord !== null)
        {
            this.mFaction.Landlord.attr('src', Path.GFX + data.Landlord);
            this.mFaction.LandlordContainer.removeClass('display-none').addClass('display-block');
        }
        else
        {
            this.mFaction.LandlordContainer.removeClass('display-block').addClass('display-none');
        }*/
    }
};

OriginCustomizerScreen.prototype.addContractToFactionDetail = function(_data) 
{
    var self = this;
    this.mFaction.Contracts.empty();

    if (_data !== undefined && _data !== null && jQuery.isArray(_data))
    {
        for (var i = 0; i < _data.length; ++i)
        {
            var entry = _data[i];
            var classes = 'display-block is-contract contract' + i;
            var contract = this.mFaction.Contracts.createImage(Path.GFX + entry.Icon + '.png', null, null, classes);
            var scroll = this.mFaction.Contracts.createImage(Path.GFX + 'ui/icons/scroll_0' + (_data.IsNegotiated ? 1 : 2) + '.png', null, null, 'display-block is-scroll contract' + i);
            var difficulty = this.mFaction.Contracts.createImage(Path.GFX + entry.DifficultyIcon + '.png', null, null, 'display-block is-difficulty contract' + i);

            // set up event listeners
            contract.click(function(_event)
            {
                //if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
                    //self.notifyBackendContractRemoved(_data.ID);
                //else
                    //self.notifyBackendContractClicked(_data.ID);
            });
            contract.mouseover(function()
            {
                this.classList.add('is-highlighted');
                scroll.addClass('is-highlighted');
                difficulty.addClass('is-highlighted');
            });
            contract.mouseout(function()
            {
                this.classList.remove('is-highlighted');
                scroll.removeClass('is-highlighted');
                difficulty.removeClass('is-highlighted');
            });
            contract.bindTooltip({ contentType: 'ui-element', elementId: entry.ID, elementOwner: 'origincustomizer.faction_contracts' });

            if (i === 11)
                break;
        }
    }
};