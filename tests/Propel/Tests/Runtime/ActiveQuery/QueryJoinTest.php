<?php

/**
 * This file is part of the Propel package.
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * @license MIT License
 */

namespace Propel\Tests\Runtime\ActiveQuery;

use Propel\Tests\Helpers\Bookstore\BookstoreTestBase;

use Propel\Tests\Bookstore\AuthorPeer;
use Propel\Tests\Bookstore\AuthorQuery;
use Propel\Tests\Bookstore\BookPeer;
use Propel\Tests\Bookstore\BookQuery;

use Propel\Runtime\ActiveQuery\Criteria;
use Propel\Runtime\ActiveQuery\QueryJoin;
use Propel\Runtime\Map\TableMap;

/**
 * Test class for QueryJoin.
 *
 * @author Jérémy Romey <jeremy@free-agent.fr>
 */
class QueryJoinTest extends BookstoreTestBase
{
    public function testSetQuery()
    {
        $join = new QueryJoin();
        $this->assertNull($join->getQuery(), 'getQuery() returns null as long as no table map is set');

        $c = new Criteria();
        $c->clearSelectColumns()->addSelectColumn('SUBQUERY_TABLE.ID');

        $join->setQuery($c);

        $this->assertEquals($c, $join->getQuery(), 'getQuery() returns the query previously set by setQuery()');
    }

    public function testQueryJoinCriteria()
    {
        $join = new QueryJoin();

        $c = new Criteria();
        $c->clearSelectColumns()->addSelectColumn('SUBQUERY_TABLE.FIELD');

        $join->setQuery($c);
        $join->addCondition('SUBQUERY_TABLE.FIELD', 'QUERY.FIELD', QueryJoin::EQUAL);

        $expectedSQL = 'INNER JOIN (SELECT SUBQUERY_TABLE.FIELD FROM `SUBQUERY_TABLE`) ON (SUBQUERY_TABLE.FIELD=QUERY.FIELD)';
        $this->assertEquals($expectedSQL, (string) $join, 'The join SQL');
    }

    public function testQueryJoinModelCriteria()
    {
        $c = new BookQuery();
        $c->select('Title');

        $cSub = new AuthorQuery();
        $cSub->select('Id');

        $join = new QueryJoin();
        $join->setQuery($cSub);
        $join->addCondition('SUBQUERY_TABLE.ID', 'QUERY.ID', QueryJoin::EQUAL);

        $c->addJoinObject($join);

        $c->find();

        $expectedSQL = 'SELECT book.TITLE AS "Title" FROM `book` INNER JOIN (SELECT SUBQUERY_TABLE.ID FROM `SUBQUERY_TABLE`) ON (SUBQUERY_TABLE.ID=QUERY.ID)';
        $this->assertEquals($expectedSQL, $this->con->getLastExecutedQuery(), 'The join SQL');

        echo $this->con->getLastExecutedQuery();
    }
}
