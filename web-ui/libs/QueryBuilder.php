<?php

/**
 * Extremely simple query builder
 *
 * Class QueryBuilder
 */
class QueryBuilder {

    private $_select = '';
    private $_from = '';
    private $_where = array();
    private $_joins = array();
    private $_order = '';
    private $_limit = '';


    /**
     * @param $fields
     */
    public function select( $fields ){
        $this->_select = sprintf('SELECT %s', $fields);
    }


    /**
     * @param $table
     * @param bool $alias
     */
    public function from( $table, $alias = false ){
        if( !$alias ){
            $this->_from = sprintf('FROM %s', $table);
        } else {
            $this->_from = sprintf('FROM %s %s', $table, $alias);
        }
    }


    /**
     * @param $cond
     */
    public function where( $cond ){
        $this->_where[] = $cond;
    }


    /**
     * @param $join
     */
    public function join( $join ){
        $this->_joins[] = $join;
    }


    /**
     * @param $order
     */
    public function order( $order ){
        $this->_order = sprintf('ORDER BY %s',$order);
    }


    /**
     * @param $offset
     * @param $limit
     */
    public function limit( $offset, $limit ){
        $this->_limit = sprintf('LIMIT %d,%d',$offset,$limit);
    }


    /**
     * @return string
     */
    public function getQuery(){

        $lines = array();

        $lines[] = $this->_select;
        $lines[] = $this->_from;
        if( sizeof($this->_joins) > 0 ) $lines = array_merge($lines,$this->_joins);
        if( sizeof($this->_where) > 0 ) $lines[] = "WHERE " . implode(' AND ',$this->_where);
        $lines[] = $this->_order;
        $lines[] = $this->_limit;

        $lines = array_filter($lines);

        return implode(' ',$lines) .';';

    }


    /**
     * @param $fieldname
     * @param $values
     * @return string
     */
    public static function buildOrQuery( $fieldname, $values ){
        $where = "";
        if(!empty($values)){
            $where .= "(";
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


    /**
     * @param $fieldname
     * @param $values
     * @return string
     */
    public static function buildOrLikeQuery( $fieldname, $values ){
        $where = "";
        if(!empty($values)){
            $where .= "(";
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
}