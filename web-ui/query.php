<?php

require_once('config.php');
require_once('libs/Bootstrap.php');
require_once('libs/QueryBuilder.php');

// Authentication token
$token = $peregrine->session->getUsername('username').$peregrine->server->getRaw('REMOTE_ADDR');
if(!$auth->checkToken($token,$peregrine->session->getRaw('token'))){
    exit;
}

if (!defined('MYSQL_PREFIX')) {
    define('MYSQL_PREFIX', 'prism_'); // Old config files may not have the constant defined yet.
}

// Build query
$qb = new QueryBuilder();
$qb->select('id, epoch, action, player, world, x, y, z, block_id, block_subid, old_block_id, old_block_subid, data');
$qb->from(MYSQL_PREFIX . 'data','d');
$qb->join('INNER JOIN ' . MYSQL_PREFIX . 'players p ON p.player_id = d.player_id');
$qb->join('INNER JOIN ' . MYSQL_PREFIX . 'actions a ON a.action_id = d.action_id');
$qb->join('INNER JOIN ' . MYSQL_PREFIX . 'worlds w ON w.world_id = d.world_id');
$qb->join('LEFT JOIN ' . MYSQL_PREFIX . 'data_extra ex ON ex.data_id = d.id');

    // World
    if(!$peregrine->post->isEmpty('world')){
        $world = explode(",", $peregrine->post->getUsername('world'));
        $qb->where( QueryBuilder::buildOrQuery('w.world',$world) );
    }

    // Coordinates
    if(!$peregrine->post->isEmpty('x',false,false) && !$peregrine->post->isInt('y',false,false) && !$peregrine->post->isInt('z',false,false)){
        $x = $peregrine->post->getInt('x');
        $y = $peregrine->post->getInt('y');
        $z = $peregrine->post->getInt('z');
        if(!$peregrine->post->isInt('radius',false,false)){
            $radius = $peregrine->post->getInt('radius');
            $qb->where( '( d.x BETWEEN '.($x-$radius) . ' AND '.($x+$radius).' )' );
            $qb->where( '( d.y BETWEEN '.($y-$radius) . ' AND '.($y+$radius).' )' );
            $qb->where( '( d.z BETWEEN '.($z-$radius) . ' AND '.($z+$radius).' )' );
        } else {
            $qb->where( 'd.x = '.$x );
            $qb->where( 'd.y = '.$y );
            $qb->where( 'd.z = '.$z );
        }
    }

    // Actions
    if(!$peregrine->post->isEmpty('actions')){
        $actions = explode(",", $peregrine->post->getRaw('actions'));
        $qb->where( QueryBuilder::buildOrQuery('a.action',$actions) );
    }
    $qb->where( 'a.action NOT LIKE "%prism%"' );

    // Players
    if(!$peregrine->post->isEmpty('players')){
        $users = explode(",", $peregrine->post->getRaw('players'));
        $qb->where( QueryBuilder::buildOrQuery('p.player',$users) );
    }

    // Entities
    if(!$peregrine->post->isEmpty('entities')){
        $entities = explode(",", $peregrine->post->getRaw('entities'));
        $matches = array();
        if(is_array($entities)){
            foreach($entities as $e){
                $matches[] = 'entity_name":"'.$e;
            }
        }
        $qb->where( QueryBuilder::buildOrLikeQuery('ex.data',$matches) );
    }

    // Data
    if(!$peregrine->post->isEmpty('keyword')){
        $data = explode(",", $peregrine->post->getRaw('keyword'));
        $qb->where( QueryBuilder::buildOrLikeQuery('ex.data',$data) );
    }

    // Blocks
    if(!$peregrine->post->isEmpty('blocks')){
        $blocks = explode(",", $peregrine->post->getRaw('blocks'));
        $match = array();
        foreach($blocks as $block){
            if(!empty($block)){
                if( strpos($block,':') === false && !ctype_digit($block) ){
                    $key = $prism->getBlockIdFromName($block);
                } else {
                    $key = $block;
                    if( strpos($block,':') === false ){
                        $key .= ':0';
                    }
                }
                $ids = explode(':', $key);
                $match[] = '(block_id = '.$ids[0].' AND block_subid = '.$ids[1].')';
            }
        }
        $qb->where( '('.implode(' OR ', $match).')' );
    }

    // After
    if(!$peregrine->post->isEmpty('after')){
        $timeInput = $peregrine->post->getQueryString('after');
        if (strpos($timeInput, '-') !== FALSE) {
            $afterDate = strtotime($peregrine->post->getDate('after','Y-m-d H:i:s'));
        } else {
            $timeAgo = $prism->getTimestampFromString($peregrine->post->getAlnum('after'));
            if(!empty($timeAgo)){
                $afterDate = strtotime( implode(" ", $timeAgo) . " ago");
            }
        }
        if(!empty($afterDate)){
            $qb->where( 'd.epoch >= "'.$afterDate.'"' );
        }
    }

    // Before
    if(!$peregrine->post->isEmpty('before')){
        $timeInput = $peregrine->post->getQueryString('before');
        if (strpos($timeInput, '-') !== FALSE) {
            $beforeDate = strtotime($peregrine->post->getDate('before','Y-m-d H:i:s'));
        } else {
            $timeAgo = $prism->getTimestampFromString($peregrine->post->getAlnum('before'));
            if(!empty($timeAgo)){
                $beforeDate = strtotime( implode(" ", $timeAgo) . " ago" );
            }
        }
        if(!empty($beforeDate)){
            $qb->where( 'd.epoch >= "'.$beforeDate.'"' );
        }
    }

    // set a hash of the conditions, to know if the result count has changed
    $sql_hash = sha1($qb->getQuery());

    // Count total records
    // This is much faster than using SQL_CALC_FOUND_ROWS
    if( $sql_hash != $peregrine->session->getAlnum('sql_conditions_hash') ){
        $total_results = 0;
        if( !defined('WEB_UI_DEBUG') || ( defined('WEB_UI_DEBUG') && !WEB_UI_DEBUG ) ){
            $total_qb = clone $qb;
            $total_qb->select('COUNT(*)');
            $statement = $db->query( $total_qb->getQuery() );
            while($row = $statement->fetch()) {
                $total_results = $row[0];
            }
        }
        $_SESSION['sql_conditions_hash'] = $sql_hash;
        $_SESSION['last_query_total_results'] = $total_results;
        $peregrine->refreshCage('session');
    } else {
        $total_results = $peregrine->session->getInt('last_query_total_results');
    }


// Order by
if( defined('DEFAULT_ORDER_BY') && DEFAULT_ORDER_BY != '' ){
    $qb->order(DEFAULT_ORDER_BY);
}

$per_page = $peregrine->post->getInt('per_page');
// Try to ensure it's somewhat sensible
if($per_page <= 0 || $per_page > 10000){
    $per_page = 25;
}

$response = array(
    'results' => false,
    'total_results' => $total_results,
    'per_page' => $per_page,
    'pages' => ($total_results > 0 ? ceil($total_results / $per_page) : 0),
    'curr_page' => $peregrine->post->getInt('curr_page'),
    'sql_hash' => $sql_hash,
    'session_hash' => $peregrine->session->getAlnum('sql_conditions_hash')
);


// Limit
$offset = ($response['curr_page']-1)*$response['per_page'];
$qb->limit($offset,$response['per_page']);

// Merge sql
$sql = $qb->getQuery();

if( defined('WEB_UI_DEBUG') && WEB_UI_DEBUG ){
    print $sql;
    exit;
}

$date_format = 'Y-m-d H:i:s';
if( defined('DEFAULT_DATE_FORMAT') && DEFAULT_DATE_FORMAT ){
    $date_format = DEFAULT_DATE_FORMAT;
}

$statement = $db->query($sql);
$statement->setFetchMode(PDO::FETCH_ASSOC);
if($statement->rowCount()){
    $results = array();
    $blocks = $prism->getItemList();
    while($row = $statement->fetch()){

        if( $row['block_id'] > 0 || $row['old_block_id'] > 0 ){
            $key = $row['old_block_id'] . ':' . $row['old_block_subid'];
            $newkey = $row['block_id'] . ':' . $row['block_subid'];
            if( array_key_exists($newkey, $blocks) ){
                $row['data'] = $blocks[$newkey];
                if( $row['old_block_id'] > 0 && array_key_exists($key, $blocks) ){
                    $row['data'] .= ' replaced ' . $blocks[$key];
                }
            }
        }

        $row['epoch'] = date($date_format, $row['epoch']);

        if(strpos($row['data'], "{") !== false){

            $row['data'] = (array)json_decode($row['data']);
            $newData = $row['data'];

            // Standard block
            if(isset($row['data']['block_id'])){
                $key = $row['data']['block_id'] . ':' . $row['data']['block_subid'];
                if(isset($blocks[$key])){
                    $newData = ucwords($blocks[$key]);
                }
                // check for some data items having an unusable subid
                else if(isset($blocks[$row['data']['block_id'] . ':0'])){
                    $newData = ucwords($blocks[$row['data']['block_id'] . ':0']);
                }
            }

            // Original block/New block
            if(isset($row['data']['newBlock_id'])){
                $key = $row['data']['newBlock_id'] . ':' . $row['data']['newBlock_subid'];
                if(isset($blocks[$key])){
                    $newData = ucwords($blocks[$key]);
                }
                // check for some data items having an unusable subid
                else if(isset($blocks[$row['data']['newBlock_id'] . ':0'])){
                    $newData = ucwords($blocks[$row['data']['newBlock_id'] . ':0']);
                }
            }
            if(isset($row['data']['originalBlock_id'])){
                $key = $row['data']['originalBlock_id'] . ':' . $row['data']['originalBlock_subid'];
                if(isset($blocks[$key])){
                    $newData .= ' replaced ' . ucwords($blocks[$key]);
                }
                // check for some data items having an unusable subid
                else if(isset($blocks[$row['data']['originalBlock_id'] . ':0'])){
                    $newData .= ' replaced ' . ucwords($blocks[$row['data']['originalBlock_id'] . ':0']);
                }
            }

            $row['data'] = $newData;

        }
        $results[] = $row;
    }
    $response['results'] = $results;
}

header('Content-type: text/javascript');
print json_encode( $response );
