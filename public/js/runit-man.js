(function($)
{
    var REFRESH_SERVICES_TIMEOUT = 5000;

    var refreshServices = function()
    {
        if (refreshServices.timer != null)
        {
            clearTimeout(refreshServices.timer);
            refreshServices.timer = null;
        }
        $.ajax({
            url: '/services',
            success: function(html)
            {
                $('#services').html(html);
            },
            complete: function()
            {
                refreshServices.timer = null;
                setTimeout(refreshServices, REFRESH_SERVICES_TIMEOUT);
            }
        });
    };
    refreshServices.timer = null;

    $('form.service-action').live('submit', function()
    {
        $.post($(this).attr('action'), function(data)
        {
            refreshServices();
        });
        return false;
    });

    $('#service-refresh-interval').text(REFRESH_SERVICES_TIMEOUT / 1000);

    refreshServices();
})(jQuery);