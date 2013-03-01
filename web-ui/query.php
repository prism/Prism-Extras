<?php

require_once('config.php');
require_once('libs/Bootstrap.php');

$token = $peregrine->session->getUsername('username').$peregrine->server->getRaw('REMOTE_ADDR');
if(!$auth->checkToken($token,$peregrine->session->getRaw('token'))){
    exit;
}

// Build our query
$sql = 'SELECT * FROM prism_actions WHERE 1=1';

    function buildOrQuery( $fieldname, $values ){
        $where = "";
        if(!empty($values)){
            $where .= " AND (";
            $c = 1;
            foreach($values as $val){
                if(empty($val)) continue;
                if($c > 1 && $c <= count($values)){
                    $where .= " OR ";
                }
                $where .= $fieldname . " = '".$val."'";
                $c++;
            }
            $where .= ")";
        }
        return $where;
    }

    function buildOrLikeQuery( $fieldname, $values ){
        $where = "";
        if(!empty($values)){
            $where .= " AND (";
            $c = 1;
            foreach($values as $val){
                if(empty($val)) continue;
                if($c > 1 && $c <= count($values)){
                    $where .= " OR ";
                }
                $where .= $fieldname . " LIKE '%".$val."%'";
                $c++;
            }
            $where .= ")";
        }
        return $where;
    }


    // World
    if(!$peregrine->post->isEmpty('world')){
        $world = explode(",", $peregrine->post->getUsername('world'));
        $sql .= buildOrQuery('prism_actions.world',$world);
    }

    // Coordinates
    if(!$peregrine->post->isEmpty('x') && !$peregrine->post->isEmpty('y') && !$peregrine->post->isEmpty('z')){
        $x = $peregrine->post->getInt('x');
        $y = $peregrine->post->getInt('y');
        $z = $peregrine->post->getInt('z');
        if(!$peregrine->post->isEmpty('radius')){
            $radius = $peregrine->post->getInt('radius');
            $sql .= ' AND ( prism_actions.x BETWEEN '.($x-$radius) . ' AND '.($x+$radius).' )';
            $sql .= ' AND ( prism_actions.y BETWEEN '.($y-$radius) . ' AND '.($y+$radius).' )';
            $sql .= ' AND ( prism_actions.z BETWEEN '.($z-$radius) . ' AND '.($z+$radius).' )';
        } else {
            $sql .= ' AND prism_actions.x = '.$x;
            $sql .= ' AND prism_actions.y = '.$y;
            $sql .= ' AND prism_actions.z = '.$z;
        }
    }

    // Actions
    if(!$peregrine->post->isEmpty('actions')){
        $actions = explode(",", $peregrine->post->getRaw('actions'));
        $sql .= buildOrQuery('prism_actions.action_type',$actions);
    }
    $sql .= ' AND prism_actions.action_type NOT LIKE "%prism%"';

    // Players
    if(!$peregrine->post->isEmpty('players')){
        $users = explode(",", $peregrine->post->getRaw('players'));
        $sql .= buildOrQuery('prism_actions.player',$users);
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
        $sql .= buildOrLikeQuery('prism_actions.data',$matches);
    }
    
    // Data
    if(!$peregrine->post->isEmpty('datas')){
        $data = explode(",", $peregrine->post->getRaw('datas'));
    	$sql .= buildOrLikeQuery('prism_actions.data',$data);
    }

    // Blocks
    if(!$peregrine->post->isEmpty('blocks')){
        $blocks = explode(",", $peregrine->post->getRaw('blocks'));
        $match = array();
        foreach($blocks as $block){
            if(!empty($block)){
                $key = $prism->getBlockIdFromName($block);
                $ids = explode(':', $key);
                $match[] = 'block_id":'.$ids[0].',"block_subid":'.$ids[1];
            }
        }
        $sql .= buildOrLikeQuery('prism_actions.data',$match);
    }

    // Timeframe
    if(!$peregrine->post->isEmpty('time')){
        preg_match_all('/([0-9]+)(s|h|m|d|w)/', $peregrine->post->getAlnum('time'), $matches);
        $timeAgo = array();
        if($matches){
            if(is_array($matches[0])){
                foreach($matches[0] as $key => $match){
                    if($matches[2][$key] == "s"){
                        $timeAgo[] = $matches[1][$key] . " seconds";
                    }
                    if($matches[2][$key] == "m"){
                        $timeAgo[] = $matches[1][$key] . " minutes";
                    }
                    if($matches[2][$key] == "h"){
                        $timeAgo[] = $matches[1][$key] . " hours";
                    }
                    if($matches[2][$key] == "d"){
                        $timeAgo[] = $matches[1][$key] . " days";
                    }
                    if($matches[2][$key] == "w"){
                        $timeAgo[] = $matches[1][$key] . " weeks";
                    }
                }
            }
        }
        if(!empty($timeAgo)){
            $beforeDate = date("Y-m-d H:i:s", strtotime( implode(" ", $timeAgo) . " ago" ));
            $sql .= ' AND prism_actions.action_time >=  "'.$beforeDate.'"';
        }
    }

    // Count total records
    // This is much faster than using SQL_CALC_FOUND_ROWS
    $total_results = 0;
    $count_sql = str_replace("SELECT *", "SELECT COUNT(id)", $sql);
    $statement = $db->query($count_sql);
    while($row = $statement->fetch()) {
        $total_results = $row[0];
    }


// Order by
$sql .= ' ORDER BY id DESC';

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
    'curr_page' => $peregrine->post->getInt('curr_page')
);


// Limit
$offset = ($response['curr_page']-1)*$response['per_page'];
$sql .= ' LIMIT '.$offset.','.$response['per_page'];

$statement = $db->query($sql);
$statement->setFetchMode(PDO::FETCH_ASSOC);
if($statement->rowCount()){
    $results = array();
    $blocks = $prism->getItemList();
    while($row = $statement->fetch()){
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
