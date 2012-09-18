<?php

/**
 * This file is part of the Propel package.
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * @license MIT License
 */

namespace Propel\Runtime\ActiveQuery;

use Propel\Runtime\Map\RelationMap;
use Propel\Runtime\Map\TableMap;
use Propel\Runtime\Util\BasePeer;

/**
 * A QueryJoin is a subquery join
 *
 * @author Jérémy Romey <jeremy@free-agent.fr>
 */
class QueryJoin extends Join
{
    protected $query;

    public function setQuery(Criteria $query)
    {
        $this->query = $query;

        return $this;
    }

    public function getQuery()
    {
        return $this->query;
    }

    public function getClause(&$params)
    {
        if (null === $this->joinCondition) {
            $conditions = array();
            for ($i = 0; $i < $this->count; $i++) {
                $conditions []= $this->getLeftColumn($i) . $this->getOperator($i) . $this->getRightColumn($i);
            }
            $joinCondition = sprintf('(%s)', implode($conditions, ' AND '));
        } else {
            $joinCondition = '';
            $this->getJoinCondition()->appendPsTo($joinCondition, $params);
        }

        if ($this->getQuery() instanceof ModelCriteria) {
            echo $this->getQuery()->getModelAliasOrName();
            echo BasePeer::createSelectSql($this->getQuery(), $params);
            $subQuery = 'SELECT A from test';
        } else {
            $subQuery = BasePeer::createSelectSql($this->getQuery(), $params);
        }

        return sprintf('%s (%s) ON %s',
            $this->getJoinType(),
            $subQuery,
            $joinCondition
        );
    }
}
