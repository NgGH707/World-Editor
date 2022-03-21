
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

$.fn.removePercentageToInput = function()
{
    var currentText = this.getInputText();
    var index = currentText.indexOf('%');
    if (index !== null && index > 0) {
        this.val(currentText.slice(0, index));
    }
}