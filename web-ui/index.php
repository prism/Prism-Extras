<?php

require_once('config.php');
require_once('libs/Bootstrap.php');

// If login form submitted
if(!$peregrine->post->isEmpty('username')){

    // Verify username/password - then set an auth token
    if($auth->authUser($peregrine->post->getUsername('username'), $peregrine->post->getRaw('password'))){
        $_SESSION['username'] = $peregrine->post->getUsername('username');
        $token = $peregrine->post->getUsername('username').$peregrine->server->getRaw('REMOTE_ADDR');
        $_SESSION['token'] = $auth->hashString( $token );
        header("Location: index.php");
    } else {
        header("Location: index.php?auth_failed=1");
    }
    // No need to refresh cage, we're redirecting so a reload
    // won't cause a new POST
    exit;
} else {

    $token = $peregrine->session->getUsername('username').$peregrine->server->getRaw('REMOTE_ADDR');
    if($auth->checkToken($token,$peregrine->session->getRaw('token'))){
        define('AUTHENTICATED', true);
    } else {
        define('AUTHENTICATED', false);
    }
}

?>
<!DOCTYPE html>
<html>
    <head>
        <title>Prism</title>
        <meta charset="utf-8" />
        <link href="./css/bootstrap.min.css" media="all" rel="stylesheet">
        <link href="./css/app.css" media="all" rel="stylesheet">
    </head>
    <body>
        <article>
            <div class="container">
                <h1>Prism</h1>
                <form id="frm-search" action="#" method="post">
                    <input type="hidden" id="curr_page" name="curr_page" value="1" />
                    <input type="hidden" id="per_page" name="per_page" value="25" />
                    <div class="row">
                        <fieldset class="span6">
                            <div class="well">
                                <div class="row">
                                    <div class="control-group span2">
                                        <label class="control-label" for="world">World</label>
                                        <div class="controls">
                                            <input type="text" class="span2" placeholder="world" id="world" name="world" value="">
                                        </div>
                                    </div>
                                    <div class="control-group span1">
                                        <label class="control-label" for="x">X</label>
                                        <div class="controls">
                                            <input type="text" class="span1" placeholder="" id="x" name="x" value="">
                                        </div>
                                    </div>
                                    <div class="control-group span1">
                                        <label class="control-label" for="y">Y</label>
                                        <div class="controls">
                                            <input type="text" class="span1" placeholder="" id="y" name="y" value="">
                                        </div>
                                    </div>
                                    <div class="control-group span1">
                                        <label class="control-label" for="z">Z</label>
                                        <div class="controls">
                                            <input type="text" class="span1" placeholder="" id="z" name="z" value="">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="control-group span1">
                                        <label class="control-label" for="radius">Radius</label>
                                        <div class="controls">
                                            <input type="text" class="span1" placeholder="20" id="radius" name="radius" value="">
                                        </div>
                                    </div>
                                    <div class="control-group span4">
                                        <label class="control-label" for="players">Players</label>
                                        <div class="controls">
                                            <input type="text" class="span4" placeholder="viveleroi" id="players" name="players" value="">
                                        </div>
                                    </div>
    							<div class="row">
                                <div class="control-group span2">
                                    <label class="control-label" for="entities">Entities</label>
                                    <div class="controls">
                                        <input type="text" class="span2" placeholder="sheep" id="entities" name="entities" value="">
                                    </div>
                                </div>
								<div class="control-group span3">
                                    <label class="control-label" for="datas">Data</label>
                                    <div class="controls">
                                        <input type="text" class="span3" placeholder="/warp, 127.0.0.1" id="datas" name="datas" value="">
                                    </div>
                                </div>
								</div>
                            </div>
                        </fieldset>
                        <fieldset class="span6">
                            <div class="well">
                                <div class="control-group">
                                    <label class="control-label" for="actions">Actions</label>
                                    <div class="controls">
                                        <input type="text" class="typeahead span5" name="actions" id="actions" placeholder="block-break,block-place" />
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label" for="blocks">Blocks/Items</label>
                                    <div class="controls">
                                        <input type="text" class="typeahead span5" name="blocks" id="blocks" placeholder="stone,dirt" />
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label" for="time">Time Since</label>
                                    <div class="controls">
                                        <input type="text" class="span5" placeholder="1h" id="time" name="time" value="">
                                    </div>
                                </div>
                            </div>
                        </fieldset>
                    </div>
                    <button id="submit" type="submit" class="">Search</button>
                </form>
                <div id="results">
                    <div class="meta">
                        <div>Found <span>0</span> records. Page <span>1</span> of <span>1</span></div>
                        <ol>
                           <li>1</li>
                        </ol>
                        <form>
                            <label for="set-per-page">Per Page: </label>
                            <select name="set-per-page" id="set-per-page" class="span1">
                                <option>25</option>
                                <option>50</option>
                                <option>100</option>
                                <option>500</option>
                            </select>
                        </form>
                    </div>
                    <div class="table-wrap">
                        <div id="loading"></div>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>World</th>
                                    <th>Loc</th>
                                    <th>Action</th>
                                    <th>Player</th>
                                    <th>Data</th>
                                    <th>Timestamp</th>
                                </tr>
                            </thead>
                            <tbody>

                            </tbody>
                        </table>
                    </div>
                    <div class="meta">
                        <div>Found <span>0</span> records. Page <span>1</span> of <span>1</span></div>
                        <ol>
                            <li>1</li>
                        </ol>
                    </div>
                </div>
                <footer><p>Prism WebUI <?php print WEB_UI_VERSION ?> &mdash; By Viveleroi. <a href="http://discover-prism.com">Help / Donate</a></p></footer>
            </div>
        </article>
        <div class="modal hide fade">
            <div class="modal-header">
                <h3>Login</h3>
            </div>
            <div class="modal-body">
                <?php if($peregrine->get->getInt('auth_failed')): ?>
                   <p class="text-error">Authentication failed.</p>
                <?php endif; ?>
                <form id="frm-login" action="#" method="post">
                    <div class="control-group">
                        <label class="control-label" for="username">Username</label>
                        <div class="controls">
                            <input type="text" placeholder="" id="username" name="username" value="">
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label" for="password">Password</label>
                        <div class="controls">
                            <input type="password" class="span3" placeholder="" id="password" name="password" value="">
                        </div>
                    </div>
                 </form>
            </div>
            <div class="modal-footer">
                <a href="#" class="btn btn-primary">Login</a>
            </div>
        </div>
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <script src="js/app.js"></script>
        <script>
            $('#actions').typeahead({
                source: <?php print json_encode( $prism->getActionTypes() ) ?>,
                updater: updater,
                matcher: matcher,
                highlighter: highlighter
            });
            $('#blocks').typeahead({
                source: <?php print json_encode( array_values($prism->getItemList()) ) ?>,
                updater: updater,
                matcher: matcher,
                highlighter: highlighter
            });
            <?php if(!AUTHENTICATED): ?>
            $('.modal').modal({
                backdrop: 'static'
            });
            <?php endif; ?>
        </script>
    </body>
</html>
