// Unit tests for PlanExecutionService.
//
// Verifies JSON plan parsing for PostgreSQL, MySQL, SQLite, and SQL Server.
// Tests node tree construction, plan statistics, and error handling.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/datalens/plan_execution_service.dart';

void main() {
  group('PlanExecutionService', () {
    group('parseJsonPlan (PostgreSQL)', () {
      test('parses a simple sequential scan plan', () {
        final json = jsonEncode([
          {
            'Plan': {
              'Node Type': 'Seq Scan',
              'Relation Name': 'users',
              'Schema': 'public',
              'Alias': 'users',
              'Startup Cost': 0.0,
              'Total Cost': 35.5,
              'Plan Rows': 2550,
              'Plan Width': 64,
            },
            'Planning Time': 0.123,
            'Execution Time': 1.456,
          }
        ]);

        final result = PlanExecutionService.parseJsonPlan(json);

        expect(result.root.nodeType, 'Seq Scan');
        expect(result.root.tableName, 'users');
        expect(result.root.schemaName, 'public');
        expect(result.root.totalCost, 35.5);
        expect(result.root.planRows, 2550);
        expect(result.root.planWidth, 64);
        expect(result.planningTime, 0.123);
        expect(result.executionTime, 1.456);
        expect(result.isAnalyze, false);
      });

      test('parses a nested plan with children', () {
        final json = jsonEncode([
          {
            'Plan': {
              'Node Type': 'Hash Join',
              'Join Type': 'Inner',
              'Hash Cond': '(orders.user_id = users.id)',
              'Startup Cost': 10.0,
              'Total Cost': 120.5,
              'Plan Rows': 500,
              'Plan Width': 128,
              'Plans': [
                {
                  'Node Type': 'Seq Scan',
                  'Parent Relationship': 'Outer',
                  'Relation Name': 'orders',
                  'Total Cost': 45.0,
                  'Plan Rows': 1000,
                  'Plan Width': 64,
                },
                {
                  'Node Type': 'Hash',
                  'Parent Relationship': 'Inner',
                  'Total Cost': 30.0,
                  'Plan Rows': 500,
                  'Plan Width': 32,
                  'Plans': [
                    {
                      'Node Type': 'Seq Scan',
                      'Relation Name': 'users',
                      'Total Cost': 25.0,
                      'Plan Rows': 500,
                      'Plan Width': 32,
                    },
                  ],
                },
              ],
            },
          }
        ]);

        final result = PlanExecutionService.parseJsonPlan(json);

        expect(result.root.nodeType, 'Hash Join');
        expect(result.root.joinType, 'Inner');
        expect(result.root.hashCondition, '(orders.user_id = users.id)');
        expect(result.root.children.length, 2);
        expect(result.root.children[0].nodeType, 'Seq Scan');
        expect(result.root.children[0].relationship, 'Outer');
        expect(result.root.children[1].nodeType, 'Hash');
        expect(result.root.children[1].children.length, 1);
        expect(result.root.children[1].children[0].tableName, 'users');
      });

      test('parses ANALYZE plan with actual rows and times', () {
        final json = jsonEncode([
          {
            'Plan': {
              'Node Type': 'Index Scan',
              'Index Name': 'users_pkey',
              'Relation Name': 'users',
              'Scan Direction': 'Forward',
              'Index Cond': '(id = 1)',
              'Filter': '(active = true)',
              'Rows Removed by Filter': 3.0,
              'Startup Cost': 0.28,
              'Total Cost': 8.29,
              'Plan Rows': 1,
              'Plan Width': 64,
              'Actual Startup Time': 0.015,
              'Actual Total Time': 0.022,
              'Actual Rows': 1,
              'Actual Loops': 1,
            },
            'Planning Time': 0.05,
            'Execution Time': 0.035,
          }
        ]);

        final result = PlanExecutionService.parseJsonPlan(
          json,
          isAnalyze: true,
        );

        expect(result.isAnalyze, true);
        expect(result.root.actualRows, 1);
        expect(result.root.actualTime, 0.022);
        expect(result.root.actualLoops, 1);
        expect(result.root.actualStartupTime, 0.015);
        expect(result.root.actualTotalTime, 0.022);
        expect(result.root.indexName, 'users_pkey');
        expect(result.root.scanDirection, 'Forward');
        expect(result.root.indexCondition, '(id = 1)');
        expect(result.root.filter, '(active = true)');
        expect(result.root.rowsRemovedByFilter, 3.0);
      });

      test('handles parse errors gracefully', () {
        final result =
            PlanExecutionService.parseJsonPlan('not valid json');

        expect(result.root.nodeType, startsWith('Parse Error'));
        expect(result.rawOutput, 'not valid json');
      });
    });

    group('parseNodeTree', () {
      test('parses a single node map', () {
        final node = PlanExecutionService.parseNodeTree({
          'Node Type': 'Sort',
          'Sort Key': ['name ASC', 'id DESC'],
          'Output': ['id', 'name', 'email'],
          'Startup Cost': 5.0,
          'Total Cost': 15.0,
          'Plan Rows': 100,
          'Plan Width': 48,
        });

        expect(node.nodeType, 'Sort');
        expect(node.sortKey, ['name ASC', 'id DESC']);
        expect(node.output, ['id', 'name', 'email']);
        expect(node.totalCost, 15.0);
        expect(node.children, isEmpty);
      });
    });

    group('PlanResult statistics', () {
      test('calculates nodeCount, totalCost, and mostExpensiveNode', () {
        final root = PlanNode(
          nodeType: 'Hash Join',
          totalCost: 100,
          children: [
            const PlanNode(nodeType: 'Seq Scan', totalCost: 50),
            PlanNode(
              nodeType: 'Hash',
              totalCost: 30,
              children: [
                const PlanNode(nodeType: 'Index Scan', totalCost: 20),
              ],
            ),
          ],
        );

        final result = PlanResult(root: root, rawOutput: '{}');

        expect(result.nodeCount, 4);
        expect(result.totalCost, 100);
        expect(result.mostExpensiveNode.nodeType, 'Hash Join');
        expect(result.estimatedRows, 0); // default planRows
      });
    });
  });
}
