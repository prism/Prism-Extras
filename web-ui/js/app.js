$(function(){
    $('#frm-search').submit(function(){
        $('.table tbody td').remove();
        $('#loading').show();
        $.post('query.php', $(this).serialize(), function(resp){
            if(resp.results.length > 0){
                $('#loading').hide();
                for(r in resp.results){

                    data = resp.results[r].data;

                    if( typeof resp.results[r].data === "object" && resp.results[r].data != null ){;
                        data = "";
                        $.each(resp.results[r].data, function(k,v){
                            data += k + ": " + v + "<br/>";
                        });
                    }

                    var tr = '<tr>';
                    tr += '<td>'+resp.results[r].world+'</td>';
                    tr += '<td>'+resp.results[r].x+' '+resp.results[r].y+' '+resp.results[r].z+'</td>';
                    tr += '<td>'+resp.results[r].action_type+'</td>';
                    tr += '<td>'+resp.results[r].player+'</td>';
                    tr += '<td>'+(data === null ? '' : data)+'</td>';
                    tr += '<td>'+resp.results[r].action_time+'</td>';
                    tr += '</tr>'

                    $('.table tbody').append(tr);
                }

                // Set meta
                $('.meta span:first-child').text(resp.total_results);
                $('.meta span:nth-child(2)').text(resp.curr_page);
                $('.meta span:nth-child(3)').text(resp.pages);

                // Pagination
                var ol = $('.meta ol');
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
                $('#loading').hide();
                $('table tbody').append('<tr><td colspan="6">No results found. Try again.</td></tr>')
            }
        }, 'json');
        return false;
    });

    $('#submit').click(function(){
        $('#curr_page').val( 1 );
    });

    $('#set-per-page').change(function(){
        $('#per_page').val( $(this).val() );
        $('#frm-search').submit();
    })

    $('.meta ol').delegate('li a', 'click', function(e){
        e.preventDefault();
        $('#curr_page').val( $(this).data('page') );
        $('#frm-search').submit();
        return false;
    });

    $('.modal .btn').click(function(){
        $('#frm-login').submit();
        return false;
    });
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