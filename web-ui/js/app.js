
prismWebUi = function(){

    var form = $('#frm-search');
    var tbody = $('.table tbody');
    var loading = $('#loading');
    var ol = $('.meta ol');
    var curr_page_li = $('#curr_page');
    var tmpl_action_row = $('#action-row').html();

    $('#submit').click(function(){
        curr_page_li.val( 1 );
    });

    $('#set-per-page').change(function(){
        $('#per_page').val( $(this).val() );
        form.submit();
    })

    ol.on('click', 'li a', function(e){
        e.preventDefault();
        curr_page_li.val( $(this).data('page') );
        form.submit();
        return false;
    });

    $('.modal .btn').click(function(){
        $('#frm-login').submit();
        return false;
    });

    // Util methods
    ajaxStart = function(){
        loading.show();
    }
    ajaxStop = function(){
        loading.hide();
    }
    clearTable = function(){
        tbody.html('');
    }


    // Event handlers
    handleSubmit = function(){

        ajaxStart();
        clearTable();

        var jqXHR = $.post('query.php', $(this).serialize(), function(resp){
            if(resp.results.length > 0){
                
                ajaxStop();

                // Build data, append view
                tbody.html( _.template(tmpl_action_row,{actions:resp.results}) );

                // Set meta
                $('.meta span:first-child').text(resp.total_results);
                $('.meta span:nth-child(2)').text(resp.curr_page);
                $('.meta span:nth-child(3)').text(resp.pages);

                // Pagination
                ol.empty();

                if(resp.pages > 1 && resp.curr_page > 1){
                    ol.append( '<li><a href="#" data-page="'+(resp.curr_page - 1)+'">&laquo;</a></li>' );
                }

                // Add first page
                ol.append( '<li'+(resp.curr_page == 1 ? ' class="at"' : '')+'><a href="#" data-page="1">1</a></li>' );

                if(resp.pages < 8){
                    for(p = 2; p <= resp.pages; p++){
                        ol.append( '<li'+(resp.curr_page == p ? ' class="at"' : '')+'><a href="#" data-page="'+p+'">'+p+'</a></li>' );
                    }
                } else {

                    // No skips, we're at the beginning
                    if(resp.curr_page <= 5){
                        for(p = 2; p <= 6; p++){
                            ol.append( '<li'+(resp.curr_page == p ? ' class="at"' : '')+'><a href="#" data-page="'+p+'">'+p+'</a></li>' );
                        }
                        ol.append( '<li><span>&hellip;</span></li>' );
                    } else {

                        ol.append( '<li><span>&hellip;</span></li>' );

                        if(resp.curr_page <= (resp.pages - 4)){

                            // Only build near
                            for(p = (resp.curr_page - 3); p <= (resp.curr_page + 3); p++){
                                ol.append( '<li'+(resp.curr_page == p ? ' class="at"' : '')+'><a href="#" data-page="'+p+'">'+p+'</a></li>' );
                            }
                            ol.append( '<li><span>&hellip;</span></li>' );
                        } else {

                            // No skips, we're at the end
                            for(p = (resp.pages - 6); p < resp.pages; p++){
                                ol.append( '<li'+(resp.curr_page == p ? ' class="at"' : '')+'><a href="#" data-page="'+p+'">'+p+'</a></li>' );
                            }
                        }
                    }

                    // Add last
                    ol.append( '<li'+(resp.curr_page == resp.pages ? ' class="at"' : '')+'><a href="#" data-page="'+resp.pages+'">'+resp.pages+'</a></li>' );

                }

                if(resp.pages > 1 && resp.curr_page < resp.pages){
                    ol.append( '<li><a href="#" data-page="'+(resp.curr_page + 1)+'">&raquo;</a></li>' );
                }

            } else {
                ajaxStop();
                tbody.append('<tr><td colspan="7">No results found. Try again.</td></tr>')
            }
        }, 'json');

        jqXHR.fail(function(){

            var msg = "<p><strong>Error returning results:</strong></p>";
            msg += "<p>The Ajax request failed.</p>";
            msg += "<p>Make sure WEB_UI_DEBUG is turned off in the config.php file. Otherwise, if you're unsure how to resolve this error please contact Prism support.</p>";
            msg += "<p><strong>HTTP Status:</strong> "+jqXHR.status+" "+jqXHR.statusText+"</p>";
            msg += "<p><strong>Response Text:</strong> "+jqXHR.responseText+"</p>";

            ajaxStop();
            tbody.append('<tr><td colspan="7">'+msg+'</td></tr>')

        });

        return false;

    }


    // Event Listeners
    form.submit(handleSubmit);


    // Return
    return {

        // @todo future api methods

    }
}


$(function(){
    var prism = prismWebUi();
});



/* Multi-select type-ahead */
function extractor(query) {
    var result = /([^,]+)$/.exec(query);
    if(result && result[1])
        return result[1].trim();
    return '';
}
function updater(item){
    return this.$element.val().replace(/[^,]*$/,'')+item+',';
}
function matcher(item) {
    var tquery = extractor(this.query);
    if(!tquery) return false;
    return ~item.toLowerCase().indexOf(tquery)
}
function highlighter(item) {
    var query = extractor(this.query).replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
    return item.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
        return '<strong>' + match + '</strong>'
    })
}