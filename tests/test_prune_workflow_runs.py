import contextlib
import importlib.util
import io
import pathlib
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    'prune_workflow_runs', pathlib.Path(__file__).resolve().parents[1] / 'scripts/prune_workflow_runs.py')
prune = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prune)


def run(number, conclusion='success', status='completed', **kwargs):
    return dict(id=number, conclusion=conclusion, status=status, run_attempt=1,
                created_at=f'2026-11-{number:02}T00:00:00Z', **kwargs)


def ids(plan):
    return [item['id'] for item in plan]


class WorkflowPruneTests(unittest.TestCase):
    def test_keep_five_successes(self):
        self.assertEqual(ids(prune.deletion_plan([run(n) for n in range(1, 9)])), [1, 2, 3])

    def test_keep_failure_streak_after_latest_success(self):
        runs = [run(n) for n in range(1, 7)] + [run(7, 'failure'), run(8, 'timed_out')]
        self.assertEqual(ids(prune.deletion_plan(runs)), [1])

    def test_new_success_removes_earlier_failures(self):
        runs = [run(n) for n in range(1, 7)] + [run(7, 'failure'), run(8, 'failure'), run(9)]
        self.assertEqual(ids(prune.deletion_plan(runs)), [1, 2, 7, 8])

    def test_no_success_preserves_all_failure_logs(self):
        self.assertEqual(prune.deletion_plan([run(1, 'failure'), run(2, 'cancelled')]), [])

    def test_queued_and_running_runs_are_never_deleted(self):
        runs = [run(1, None, 'in_progress'), run(2, None, 'queued'), run(3)]
        self.assertEqual(prune.deletion_plan(runs, keep=1), [])

    def test_current_success_counts_toward_five_before_cleanup_finishes(self):
        runs = [run(n) for n in range(1, 7)] + [run(7, 'failure'), run(8, None, 'in_progress')]
        self.assertEqual(ids(prune.deletion_plan(runs, current_id=8, current_result='success')),
                         [1, 2, 7])
        self.assertEqual(runs[-1]['status'], 'in_progress')

    def test_current_failure_preserves_recent_failures(self):
        runs = [run(1), run(2, 'failure'), run(3, None, 'in_progress')]
        self.assertEqual(prune.deletion_plan(runs, current_id=3, current_result='failure'), [])

    def test_rerun_recency_uses_attempt_start_time(self):
        runs = [run(1, 'failure', run_started_at='2026-11-20T00:00:00Z'), run(2)]
        self.assertEqual(prune.deletion_plan(runs), [])

    def test_missing_current_run_and_invalid_keep_abort(self):
        with self.assertRaises(ValueError):
            prune.deletion_plan([run(1)], current_id=2, current_result='success')
        with self.assertRaises(ValueError):
            prune.deletion_plan([], keep=0)

    @patch.object(prune, 'api')
    def test_preview_paginates_and_does_not_delete(self, api):
        api.return_value = [{'workflow_runs': [run(1)]}, {'workflow_runs': [run(2)]}]
        with contextlib.redirect_stdout(io.StringIO()):
            prune.main(['--repo', 'owner/repo', '--workflow', 'build.yaml', '--keep', '1'])
        self.assertEqual(api.call_count, 1)
        self.assertIn('--paginate', api.call_args.args)

    @patch.object(prune, 'api')
    def test_execute_checks_snapshot_and_deletes_eligible_run(self, api):
        api.side_effect = [[{'workflow_runs': [run(1), run(2)]}], run(1), None]
        with contextlib.redirect_stdout(io.StringIO()):
            prune.main(['--repo', 'owner/repo', '--workflow', 'build.yaml', '--keep', '1', '--execute'])
        self.assertEqual(api.call_args.args,
                         ('repos/owner/repo/actions/runs/1', '--method', 'DELETE'))

    @patch.object(prune, 'api')
    def test_rerun_after_listing_is_protected(self, api):
        latest = run(1, None, 'in_progress')
        latest['run_attempt'] = 2
        api.side_effect = [[{'workflow_runs': [run(1), run(2)]}], latest]
        with contextlib.redirect_stdout(io.StringIO()):
            prune.main(['--repo', 'owner/repo', '--workflow', 'build.yaml', '--keep', '1', '--execute'])
        self.assertEqual(api.call_count, 2)

    @patch.object(prune, 'api')
    def test_invalid_api_response_prevents_deletion(self, api):
        api.return_value = {'message': 'error'}
        with self.assertRaises(ValueError):
            prune.main(['--repo', 'owner/repo', '--workflow', 'build.yaml', '--execute'])
        self.assertEqual(api.call_count, 1)


if __name__ == '__main__':
    unittest.main()
