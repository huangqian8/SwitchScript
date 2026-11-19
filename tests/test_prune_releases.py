import contextlib
import importlib.util
import io
import json
import pathlib
import subprocess
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    'prune_releases', pathlib.Path(__file__).resolve().parents[1] / 'scripts/prune_releases.py')
prune = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prune)


def release(tag, **flags):
    return dict(tag_name=tag, draft=False, prerelease=False, **flags)


class PruneTests(unittest.TestCase):
    def test_keep_recent_daily_releases_and_protect_current(self):
        releases = [release(f'202611{day:02}') for day in range(10, 20)]
        plan = prune.deletion_plan(releases, keep=5, protected=['20261110'])
        self.assertEqual(plan, ['20261111', '20261112', '20261113', '20261114'])

    def test_manual_draft_prerelease_and_invalid_dates_are_untouched(self):
        releases = [release('v1.0'), release('20260230'), release('20261119'),
                    dict(tag_name='20261118', draft=True, prerelease=False),
                    dict(tag_name='20261117', draft=False, prerelease=True)]
        self.assertEqual(prune.deletion_plan(releases, keep=1), [])

    def test_invalid_retention_rejected(self):
        with self.assertRaises(ValueError):
            prune.deletion_plan([], keep=0)

    @patch.object(prune.subprocess, 'run')
    def test_default_preview_reads_all_pages_without_deleting(self, run):
        run.return_value.stdout = json.dumps([[release('20261118')], [release('20261117')]])
        with contextlib.redirect_stdout(io.StringIO()) as output:
            prune.main(['--repo', 'owner/repo', '--keep', '1'])
        self.assertEqual(run.call_count, 1)
        self.assertIn('--paginate', run.call_args.args[0])
        self.assertIn('--slurp', run.call_args.args[0])
        self.assertIn('Would delete: owner/repo 20261117', output.getvalue())

    @patch.object(prune.subprocess, 'run')
    def test_execute_removes_only_planned_daily_release_and_tag(self, run):
        run.return_value.stdout = json.dumps([[release('20261119'), release('v1.0'),
                                              release('20261118')]])
        with contextlib.redirect_stdout(io.StringIO()):
            prune.main(['--repo', 'owner/repo', '--keep', '1', '--execute'])
        self.assertEqual(run.call_count, 2)
        self.assertEqual(run.call_args.args[0], ['gh', 'release', 'delete', '20261118',
                                               '--repo', 'owner/repo', '--cleanup-tag', '--yes'])

    @patch.object(prune.subprocess, 'run')
    def test_api_error_stops_before_delete(self, run):
        run.side_effect = subprocess.CalledProcessError(1, ['gh', 'api'])
        with self.assertRaises(subprocess.CalledProcessError):
            prune.main(['--repo', 'owner/repo', '--execute'])
        self.assertEqual(run.call_count, 1)

    @patch.object(prune.subprocess, 'run')
    def test_malformed_api_data_stops_before_delete(self, run):
        run.return_value.stdout = json.dumps({'message': 'error'})
        with self.assertRaises(ValueError):
            prune.main(['--repo', 'owner/repo', '--execute'])
        self.assertEqual(run.call_count, 1)


if __name__ == '__main__':
    unittest.main()
