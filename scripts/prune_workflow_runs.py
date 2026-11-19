"""Keep recent successful builds and unresolved failures; preview by default."""
import argparse
import datetime
import json
import re
import subprocess
from urllib.parse import quote


def run_order(run):
    started = run.get('run_started_at') or run['created_at']
    return (datetime.datetime.fromisoformat(started.replace('Z', '+00:00')), run['id'])


def deletion_plan(runs, keep=5, current_id=None, current_result=None):
    if keep < 1:
        raise ValueError('At least one successful run must be retained')
    snapshots = [dict(run) for run in runs]
    if current_id is not None:
        current = next((run for run in snapshots if run['id'] == current_id), None)
        if current is None:
            raise ValueError('Current run missing from API response; nothing was deleted')
        # The cleanup job is still running, but its build dependency has finished.
        if current_result == 'success':
            current.update(status='completed', conclusion='success')
    ordered = sorted(snapshots, key=run_order, reverse=True)
    successes = [run for run in ordered if run['status'] == 'completed'
                 and run['conclusion'] == 'success']
    if not successes:
        return []
    retained = {run['id'] for run in successes[:keep]} | {current_id}
    latest_success = run_order(successes[0])
    return [run for run in reversed(ordered)
            if run['status'] == 'completed' and run['id'] not in retained
            and (run['conclusion'] == 'success' or run_order(run) < latest_success)]


def api(endpoint, *options):
    result = subprocess.run(['gh', 'api', endpoint, *options], check=True,
                            capture_output=True, text=True)
    return json.loads(result.stdout) if result.stdout.strip() else None


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--workflow', required=True)
    parser.add_argument('--keep', type=int, default=5)
    parser.add_argument('--current-run-id', type=int)
    parser.add_argument('--current-result', choices=['success', 'failure', 'cancelled', 'skipped'])
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args(argv)
    if args.keep < 1:
        parser.error('--keep must be at least 1')
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', args.repo):
        parser.error('--repo must be owner/repository')
    if (args.current_run_id is None) != (args.current_result is None):
        parser.error('--current-run-id and --current-result must be supplied together')
    base = f'repos/{args.repo}/actions'
    pages = api(f'{base}/workflows/{quote(args.workflow, safe="")}/runs?per_page=100',
                '--paginate', '--slurp')
    if not isinstance(pages, list) or any(not isinstance(page, dict)
            or not isinstance(page.get('workflow_runs'), list) for page in pages):
        raise ValueError('Expected paginated workflow runs; nothing was deleted')
    runs = [run for page in pages for run in page['workflow_runs']]
    plan = deletion_plan(runs, args.keep, args.current_run_id, args.current_result)
    print(f'Workflow {args.workflow}: {len(runs)} runs, {len(plan)} eligible for deletion.', flush=True)
    for run in plan:
        run_id = run['id']
        print(f'{"Delete" if args.execute else "Would delete"}: {run_id} '
              f'({run["conclusion"]}, {run["created_at"]})', flush=True)
        if args.execute:
            # A user may have re-run this build since the initial listing.
            latest = api(f'{base}/runs/{run_id}')
            if (latest['status'] != 'completed'
                    or latest.get('run_attempt') != run.get('run_attempt')
                    or latest['conclusion'] != run['conclusion']
                    or run_order(latest) != run_order(run)):
                print(f'Skip changed run: {run_id}', flush=True)
                continue
            api(f'{base}/runs/{run_id}', '--method', 'DELETE')


if __name__ == '__main__':
    main()
