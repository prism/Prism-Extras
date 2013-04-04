<?php
/**
 *
 */
class Prism {

    /**
     * @var array|void
     */
    protected $items = array();


    /**
     *
     */
    public function __construct(){
        $this->parseItemList();
    }


    /**
     * @param $timestring
     * @return array
     */
    public function getTimestampFromString( $timestring ){
        preg_match_all('/([0-9]+)(s|h|m|d|w)/', $timestring, $matches);
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
        return $timeAgo;
    }


    /**
     *
     */
    public function getActionTypes(){

        return array(
        'block-break',
        'block-burn',
        'block-fade',
        'block-fall',
        'block-form',
        'block-place',
        'block-shift',
        'block-spread',
        'block-use',
        'bonemeal-use',
        'container-access',
        'creeper-explode',
        'crop-trample',
        'enderman-pickup',
        'enderman-place',
        'entity-break',
        'entity-explode',
        'entity-follow',
        'entity-kill',
        'entity-shear',
        'entity-spawn',
        'fireball',
        'hangingitem-break',
        'hangingitem-place',
        'item-drop',
        'item-insert',
        'item-pickup',
        'item-remove',
        'lava-break',
        'lava-bucket',
        'lava-flow',
        'lava-ignite',
        'leaf-decay',
        'lighter',
        'lightning',
        'mushroom-grow',
        'player-chat',
        'player-command',
        'player-death',
        'player-join',
        'player-quit',
        'sheep-eat',
        'sign-change',
        'spawnegg-use',
        'tnt-explode',
        'tnt-prime',
        'tree-grow',
        'water-break',
        'water-bucket',
        'water-flow',
        'world-edit'
        );
    }


    /**
     * @return array|void
     */
    public function getItemList(){
        return $this->items;
    }


    /**
     *
     */
    protected function parseItemList(){

        $items = array();

        $path = str_replace("libs", "js", dirname(__FILE__));

        if(file_exists($path . DIRECTORY_SEPARATOR . 'items.json')){
            $fcontents = file_get_contents( $path . DIRECTORY_SEPARATOR . 'items.json');
            if($fcontents){
                $items = (array)json_decode($fcontents, true);
                if($items){
                    asort($items);
                    $this->items = $items;
                }
            }
        }
    }


    /**
     * @param $name
     * @return bool|mixed
     */
    public function getBlockIdFromName( $name ){
        $key = array_search($name, $this->items);
        if($key) return $key;
        return false;
    }
}
