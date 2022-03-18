
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
