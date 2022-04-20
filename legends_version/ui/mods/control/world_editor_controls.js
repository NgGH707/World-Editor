$.fn.addHighlighter = function()
{
    this.mouseover(function() {
        this.classList.add('is-highlighted');
    });
    this.mouseout(function() {
        this.classList.remove('is-highlighted');
    });
    return this;
}

$.fn.showThisDiv = function(_value)
{
    if (_value === true)
    {
        this.addClass('display-block').removeClass('display-none');
    }
    else
    {
        this.addClass('display-none').removeClass('display-block');
    }
    return this;
}

$.fn.isValidInputNumber = function(_min, _max)
{
    var convertedText = parseInt(this.getInputText());

    if(isNaN(convertedText)) 
        return null;

    if (convertedText < _min) 
        return _min;

    if (convertedText > _max) 
        return _max;

    return convertedText;
};

// simple function to help bind event listener to a input
$.fn.assignInputEventListener = function(_type, _callback)
{
    if (_type === undefined || _type === null || typeof _type !== 'string')
    {
        return;
    }

    if (_callback !== undefined && _callback !== null && jQuery.isFunction(_callback))
    {
        this.on(_type + '.input', null, this, function (_event)
        {
            _callback($(this), _event);
        });
    }
};
$.fn.addPercentageToInput = function()
{
    var currentText = this.getInputText();
    var length = this.getInputTextLength();
    if (length != 0 && currentText.slice(length - 1, length) !== '%') {
        this.val(currentText + '%');
    }
}
$.fn.removePercentageFromInput = function()
{
    var currentText = this.getInputText();
    var index = currentText.indexOf('%');
    if (index !== null && index > 0) {
        this.val(currentText.slice(0, index));
    }
}



// For List
$.fn.scrollListToElementWithDelay = function(_element, _delay)
{
    var scrollContainer = this.findListScrollContainer();
    var self = this;
    var element = null;
    
    if (_element !== undefined)
        element = _element;
    else
        element = scrollContainer.children(':last');

    if (_delay === undefined || _delay === null)
        _delay = 100;

    if (element !== null && element.length > 0) {
        var timerHandle = this.data('scroll-timer');
        if (timerHandle !== null) {
            clearTimeout(timerHandle);
        }

        timerHandle = setTimeout(function() {
            self.trigger('scroll', { element: element, center: true, duration: 1, animate: 'linear', scrollTo: 'bottom' });
            self.trigger('update', true);
        }, 200);

        this.data('scroll-timer', timerHandle);
    }

    return this;
};
$.fn.findFirstIndexOfSelectedListEntry = function()
{
    var result = -1;
    this.find('.is-selected').each(function (index, element)
    {
        return index;
    });
    return result;
};
$.fn.findListEntryByIndex = function(_index, _class)
{
    if (_class === undefined || _class === null)
        _class = 'list-entry';

    var container = this.find('.scroll-container:first');
    if (container.length > 0)
    {
        var entries = container.find('.' + _class);
        if (entries.length > 0 && _index >= 0 && _index < entries.length)
        {
            return $(entries[_index]);
        }
    }
    return null;
};

$.fn.removeListEntryByIndex = function(_index, _class)
{
    if (_class === undefined || _class === null)
        _class = 'list-entry';

    var container = this.find('.scroll-container:first');
    if (container.length > 0)
    {
        var entries = container.find('.' + _class);
        if (entries.length > 0 && _index >= 0 && _index < entries.length)
        {
            var entry = $(entries[_index]);
            entry.remove();
            return entry;
        }
    }
    return null;
};

$.fn.getListEntryCount = function( _class )
{
    if (_class === undefined || _class === null)
        _class = 'list-entry';
    
    var container = this.find('.scroll-container:first');
    if (container.length > 0)
    {
        var entries = container.find('.' + _class);
        return entries.length;
    }
    return 0;
};