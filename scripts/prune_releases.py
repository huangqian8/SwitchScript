"""Retain recent daily releases; preview changes unless --execute is supplied."""
import argparse
import datetime
import json
import re
import subprocess


def daily_tag(tag):
    if not isinstance(tag, str) or not re.fullmatch(r'[0-9]{8}', tag):
        return False
    try:
        datetime.datetime.strptime(tag, '%Y%m%d')
    except ValueError:
        return False
    return True


def deletion_plan(releases, keep=5, protected=()):
    if keep < 1:
        raise ValueError('At least one daily release must be retained')
    daily = [release for release in releases
             if daily_tag(release['tag_name'])
             and not release['draft'] and not release['prerelease']]
    daily.sort(key=lambda release: release['tag_name'], reverse=True)
    retained = {release['tag_name'] for release in daily[:keep]} | set(protected)
    return [release['tag_name'] for release in reversed(daily)
            if release['tag_name'] not in retained]


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--keep', type=int, default=5)
    parser.add_argument('--protect-tag', action='append', default=[])
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args(argv)
    if args.keep < 1:
        parser.error('--keep must be at least 1')
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', args.repo):
        parser.error('--repo must be owner/repository')

    result = subprocess.run(
        ['gh', 'api', f'repos/{args.repo}/releases?per_page=100',
         '--paginate', '--slurp'], check=True, capture_output=True, text=True)
    pages = json.loads(result.stdout)
    if not isinstance(pages, list) or any(not isinstance(page, list) for page in pages):
        raise ValueError('Expected paginated release lists; nothing was deleted')
    plan = deletion_plan([release for page in pages for release in page],
                         args.keep, args.protect_tag)
    if not plan:
        print('No daily releases to remove.')
    for tag in plan:
        print(f'{"Delete" if args.execute else "Would delete"}: {args.repo} {tag}', flush=True)
        if args.execute:
            subprocess.run(['gh', 'release', 'delete', tag, '--repo', args.repo,
                            '--cleanup-tag', '--yes'], check=True)


if __name__ == '__main__':
    main()
