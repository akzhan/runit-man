(function($)
{
    var REFRESH_SERVICES_TIMEOUT = 5000;

    $.ajaxSetup({
        error: function(e, req, options, error)
        {
            $('#url').text(settings.url);
            $('#error').show();
        }
    });

    var needRefreshServices;
    var refreshServices = function()
    {
        refreshServices.timer = null;
        $.ajax({
            url: '/services',
            cache: false,
            error: function()
            {
                $('#url').text('/services');
                $('#error').show();
            },
            success: function(html)
            {
                $('#error').hide();
                $('#services').html(html);
            },
            complete: function()
            {
                needRefreshServices(false);
            }
        });
    };

    needRefreshServices = function(now)
    {
        if (refreshServices.timer != null)
        {
            clearTimeout(refreshServices.timer);
            refreshServices.timer = null;
        }
        if (now)
        {
            refreshServices();
        }
        else
        {
            refreshServices.timer = setTimeout(refreshServices, REFRESH_SERVICES_TIMEOUT);
        }
    };

    $('form.service-action').live('submit', function()
    {
        $.post($(this).attr('action'), function(data)
        {
            needRefreshServices(true);
        });
        return false;
    });

    $('#service-refresh-interval').text(REFRESH_SERVICES_TIMEOUT / 1000);

    needRefreshServices(true);
})(jQuery);
