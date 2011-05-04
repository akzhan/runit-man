/*jslint browser: true, forin: true */
(function($, window)
{
    "use strict";
    var REFRESH_SERVICES_TIMEOUT = 5000;

    $.ajaxSetup({
        error: function(e, req, options, error)
        {
            $('#url').text(options.url);
            $('#error').show();
        }
    });

    var needRefreshServices, refreshServices;
    refreshServices = function()
    {
        refreshServices.timer = null;
        $.ajax({
            url: '/services',
            cache: false
        }).error(function()
        {
            $('#url').text('/services');
            $('#error').show();
        }).success(function(html)
        {
            $('#error').hide();
            $('#services').html(html);
        }).complete(function()
        {
            needRefreshServices(false);
        });
    };
    refreshServices.timer = null;

    needRefreshServices = function(now)
    {
        if (refreshServices.timer !== null)
        {
            window.clearTimeout(refreshServices.timer);
            refreshServices.timer = null;
        }
        if (now)
        {
            refreshServices();
        }
        else
        {
            refreshServices.timer = window.setTimeout(refreshServices, REFRESH_SERVICES_TIMEOUT);
        }
    };

    $('#services').delegate('form.service-action,form.service-signal', 'submit', function(e)
    {
        e.preventDefault();
        $.post($(this).attr('action')).complete(function()
        {
            needRefreshServices(true);
        });
        return false;
    });

    $('#service-refresh-interval').text(REFRESH_SERVICES_TIMEOUT / 1000);

    needRefreshServices(true);
})(jQuery, window);
