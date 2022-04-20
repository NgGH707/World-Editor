"use strict";

var WorldItemsSpawnerScreen = function(_parent)
{
	this.mSQHandle = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;

    // 
    this.mStash = {
        Data               : null,
        Slot               : null,
        Label              : null,
        ListContainer      : null,
        ListScrollContainer: null,
    };

    this.mSelected = {
        Layout   : null,
        Name     : null,
        Attribute: {

        },
    };

    this.mSearch = {
        Filter             : 0,
        ListContainer      : null,
        ListScrollContainer: null,
    };

    // buttons
    this.mLeaveButton = null;

    // generics
    this.mIsVisible = false;

    // selected entry
    this.mSelectedEntry = null;
};

WorldItemsSpawnerScreen.prototype.createDIV = function(_parentDiv)
{
    var self = this;

	// create: containers (init hidden!)
     this.mContainer = $('<div class="world-items-spawner-screen display-none opacity-none"/>');
     _parentDiv.append(this.mContainer);

    // create: containers (init hidden!)
    var dialogLayout = $('<div class="l-items-spanwer-dialog-container"/>');
    this.mContainer.append(dialogLayout);
    this.mDialogContainer = dialogLayout.createDialog('Item Spawner', null, '', true, 'dialog-1024-768');

    // create tabs
    var tabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabButtonsContainer);

    // create content
    var content = this.mDialogContainer.findDialogContentContainer();
    {
        var leftColumn = $('<div class="column with-dialog-background"/>');
        content.append(leftColumn);
        var stashHeader = $('<div class="stash-header-container with-small-dialog-background"/>');
        leftColumn.append(stashHeader);
        {
            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + 'ui/buttons/delete.png', null, '', 6);

            var buttonLayout = $('<div class="l-flex-button-174-43"/>');
            stashHeader.append(buttonLayout);
            this.mStash.Label = buttonLayout.createTextButton('Stash', null, '', 7);
            this.mStash.Label.findButtonText().css('top', '0.3rem');
            this.mStash.Label.enableButton(false);

            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + Asset.BUTTON_SORT, null, '', 6);

            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + Asset.ICON_REPAIR_ITEM, null, '', 6);

            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + Asset.BUTTON_DELAY_TURN, null, '', 6);
        }

        var stashContent = $('<div class="stash-content-container"/>');
        leftColumn.append(stashContent);
        var listContainerLayout = $('<div class="l-list-container"/>');
        stashContent.append(listContainerLayout);
        this.mStash.ListContainer = listContainerLayout.createList(2);
        this.mStash.ListScrollContainer = this.mStash.ListContainer.findListScrollContainer();

        var rightColumn = $('<div class="column"/>');
        content.append(rightColumn);
        {
            var upperRow = $('<div class="row-upper"/>');
            rightColumn.append(upperRow);
            var itemContainer = $('<div class="column-is-portrait"/>');
            upperRow.append(itemContainer);
            this.mSelected.Layout = $('<div class="item-layout"/>');
            itemContainer.append(this.mSelected.Layout);
            var image = this.mSelected.Layout.createImage(Path.GFX + 'ui/items/slots/inventory_slot_bag.png', null, null, '');
            image.data('ID', null);
            image.data('item', null);

            var nameContainer = $('<div class="column-is-name"/>');
            upperRow.append(nameContainer);
            var row = $('<div class="row"/>');
            nameContainer.append(row);
            var title = $('<div class="title title-font-big font-color-title">Item Name</div>');
            row.append(title);
            var inputLayout = $('<div class="l-input"/>');
            row.append(inputLayout);
            this.mSelected.Name = inputLayout.createInput('', 0, 50, 1, function(_input) {
            });

            var lowerRow = $('<div class="row-lower"/>');
            upperRow.append(lowerRow);
        }
    }

    // create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

    // create: buttons
    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Close", function() {
        self.notifyBackendCloseButtonPressed();
    }, '', 1);

    this.mIsVisible = false;
};

WorldItemsSpawnerScreen.prototype.destroyDIV = function()
{
	this.mSelectedEntry = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};

WorldItemsSpawnerScreen.prototype.bindTooltips = function()
{
};

WorldItemsSpawnerScreen.prototype.unbindTooltips = function()
{
};

WorldItemsSpawnerScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.bindTooltips();
};

WorldItemsSpawnerScreen.prototype.destroy = function()
{
    this.unbindTooltips();
    this.destroyDIV();
};

WorldItemsSpawnerScreen.prototype.isConnected = function()
{
    return this.mSQHandle !== null;
};

WorldItemsSpawnerScreen.prototype.onConnection = function(_handle)
{
    this.mSQHandle = _handle;
    this.register($('.root-screen'));
};

WorldItemsSpawnerScreen.prototype.onDisconnection = function()
{
    this.mSQHandle = null;
    this.unregister();
};

WorldItemsSpawnerScreen.prototype.register = function(_parentDiv)
{
    console.log('WorldItemsSpawnerScreen::REGISTER');

    if (this.mContainer !== null) {
        console.error('ERROR: Failed to register WorldItemsSpawnerScreen. Reason: Already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof(_parentDiv) == 'object') {
        this.create(_parentDiv);
    }
};

WorldItemsSpawnerScreen.prototype.unregister = function()
{
    console.log('WorldItemsSpawnerScreen::UNREGISTER');

    if (this.mContainer === null) {
        console.error('ERROR: Failed to unregister WorldItemsSpawnerScreen. Reason: Not initialized.');
        return;
    }

    this.destroy();
};

WorldItemsSpawnerScreen.prototype.isRegistered = function()
{
    if (this.mContainer !== null) {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};

WorldItemsSpawnerScreen.prototype.isVisible = function()
{
    return this.mIsVisible;
};

WorldItemsSpawnerScreen.prototype.show = function(_data)
{
    this.loadFromData(_data);
	var self = this;
	var offset = -(this.mContainer.parent().width() + this.mContainer.width());
	this.mContainer.css({ 'left': offset });
	this.mContainer.velocity("finish", true).velocity({ opacity: 1, left: '0', right: '0' }, {
		duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function () {
			$(this).removeClass('display-none').addClass('display-block');
			self.notifyBackendOnAnimating();
		},
		complete: function () {
			self.mIsVisible = true;
			self.notifyBackendOnShown();
		}
	});
};

WorldItemsSpawnerScreen.prototype.hide = function(_withSlideAnimation)
{
    var self = this;
    var offset = -(this.mContainer.parent().width() + this.mContainer.width());
    this.mContainer.velocity("finish", true).velocity({ opacity: 0, left: offset },
	{
        duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
        easing: 'swing',
        begin: function ()
        {
            $(this).removeClass('is-center');
            self.notifyBackendOnAnimating();
        },
        complete: function ()
        {
        	self.mIsVisible = false;
            $(this).removeClass('display-block').addClass('display-none');
            self.notifyBackendOnHidden();
        }
    });
};

WorldItemsSpawnerScreen.prototype.loadFromData = function(_data)
{
    if (_data === undefined || _data === null) {
        return;
    }

    this.createItemContainer(_data.Slots);
    this.addStashData(_data.Stash);
    this.mStash.Label.changeButtonText('Stash: ' + _data.Stash.length + '/' + _data.Slots);
};

WorldItemsSpawnerScreen.prototype.createItemContainer = function(_slotNum)
{
    this.mStash.Slot = [];
    this.mStash.ListScrollContainer.empty();
    for (var i = 0; i < _slotNum; i++) {
        var itemContainer = $('<div class="item-container"/>');
        this.mStash.ListScrollContainer.append(itemContainer);
        this.mStash.Slot.push(itemContainer);
    }
};

WorldItemsSpawnerScreen.prototype.addStashData = function(_data)
{
    this.mStash.Data = _data;
    for (var i = 0; i < _data.length; i++) {
        this.createItemEntry(_data[i]);
    }
};

WorldItemsSpawnerScreen.prototype.createItemEntry = function(_data)
{
    var itemContainer = this.mStash.Slot[_data.Index];
    var imageLayout = $('<div class="item-layout"/>');
    itemContainer.append(imageLayout);
    var image = imageLayout.createImage(Path.GFX + _data.ImagePath, null, null, '');
    image.data('ID', _data.ID);
    image.data('item', _data);

    var overlays = _data.ImageOverlayPath;
    if (overlays !== undefined && overlays !== '' && overlays.length > 0)
    {
        overlays.forEach(function (_imagePath) {
            if (_imagePath === '') return;

            var overlayImage = imageLayout.createImage(Path.ITEMS + _imagePath, null, null, '');
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
    /*image.click(this, function(_event) {
        var element = $(this);
        var id = element.data('ID');
        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
            self.notifyBackendRemoveItem(id);
        else
            self.selectItemListEntry(element);
    });*/
    image.bindTooltip({ contentType: 'ui-item', entityId: _data.Owner, itemId: _data.ID, itemOwner: 'woditor.itemspawner'});
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnConnected = function()
{
	SQ.call(this.mSQHandle, 'onScreenConnected');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnDisconnected = function()
{
	SQ.call(this.mSQHandle, 'onScreenDisconnected');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnShown = function()
{
    SQ.call(this.mSQHandle, 'onScreenShown');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnHidden = function()
{
    SQ.call(this.mSQHandle, 'onScreenHidden');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnAnimating = function()
{
    SQ.call(this.mSQHandle, 'onScreenAnimating');
};

WorldItemsSpawnerScreen.prototype.notifyBackendCloseButtonPressed = function()
{
    SQ.call(this.mSQHandle, 'onCloseButtonPressed');
};





registerScreen("WorldItemsSpawnerScreen", new WorldItemsSpawnerScreen());