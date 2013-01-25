

$(function(){
    $('#frm-search').submit(function(){
        $.post('query.php', $(this).serialize(), function(resp){
            if(resp.results.length > 0){
                $('.table tbody td').remove();
                for(r in resp.results){

                    data = resp.results[r].data;

                    if(typeof resp.results[r].data == "object"){;
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
                    tr += '<td>'+data+'</td>';
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
                    for(p = 1; p <= resp.pages; p++){
                        ol.append( '<li'+(resp.curr_page == p ? ' class="at"' : '')+'><a href="#" data-page="'+p+'">'+p+'</a></li>' );
                    }
                } else {

                    // No skips, we're at the beginning
                    if(resp.curr_page <= 5){
                        for(p = 2; p <= 6; p++){
                            ol.append( '<li'+(resp.curr_page == p ? ' class="at"' : '')+'><a href="#" data-page="'+p+'">'+p+'</a></li>' );
                        }
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
//                $('button').after('<span class="text-error">No results found. Try again.</span>')
            }
        }, 'json');
        return false;
    }).trigger('submit');

    $('.meta ol').delegate('li a', 'click', function(e){
        e.preventDefault();
        $('#curr_page').val( $(this).data('page') );
        $('#frm-search').submit();
        return false;
    });

    $('.modal .btn').click(function(){
        $('#frm-login').submit();
        return false;
    })
});