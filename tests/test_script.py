"""Offline regression checks. Run: python3 -m unittest discover -s tests -v."""
import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE = (ROOT / 'switchScript.sh').read_text().rsplit('main "$@"', 1)[0]


class ScriptTests(unittest.TestCase):
    def run_shell(self, body, *, read_description=False):
        with tempfile.TemporaryDirectory(prefix='switchscript-test-') as tmp:
            directory = pathlib.Path(tmp)
            shutil.copytree(ROOT / 'templates', directory / 'templates')
            script = directory / 'test.sh'
            script.write_text(SOURCE + '\n' + body)
            result = subprocess.run([os.environ.get('TEST_BASH', '/bin/bash'), str(script)],
                                    text=True, capture_output=True, cwd=tmp)
            if read_description:
                report = directory / 'description.txt'
                self.assertTrue(report.is_file(), result.stderr)
                result.stdout += '\n' + report.read_text()
            return result

    def test_cache_survives_subshells_and_preserves_release_snapshot(self):
        result = self.run_shell(r'''
RELEASE_CACHE_DIR=$(mktemp -d)
trap cleanup_release_cache EXIT
github_api_get() {
    echo API_CALL >&2
    printf '%s' '{"tag_name":"v1","assets":[{"browser_download_url":"https://example.test/atmosphere.zip"},{"browser_download_url":"https://example.test/fusee.bin"}]}'
}
IFS='|' read -r url tag < <(get_latest_release_asset test/repo 'atmosphere\.zip')
[ "$tag" = v1 ]
IFS='|' read -r url tag < <(get_latest_release_asset test/repo 'fusee\.bin')
[ "$url" = https://example.test/fusee.bin ]
[ "$tag" = v1 ]
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr.count('API_CALL'), 1)

    def test_invalid_api_response_is_not_cached(self):
        result = self.run_shell(r'''
RELEASE_CACHE_DIR=$(mktemp -d)
trap cleanup_release_cache EXIT
github_api_get() { printf '%s' '{"message":"rate limited"}'; }
if get_release_json test/repo; then exit 20; fi
[ ! -f "$RELEASE_CACHE_DIR/test_repo.json" ]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def failure_case(self, strict):
        return self.run_shell(r'''
check_dependencies() { :; }
get_latest_release_asset() { return 1; }
get_release_json() { return 1; }
download_file() { record_failure "$3"; return 1; }
git() { return 1; }
main --only special STRICT_OPTION
'''.replace('STRICT_OPTION', '--strict' if strict else ''), read_description=True)

    def test_strict_mode_blocks_incomplete_build(self):
        result = self.failure_case(True)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('Strict mode:', result.stderr)
        for component in ('Awoo Installer', 'Sphaira', 'aio-switch-updater',
                          'wiliwili', 'daybreak', 'theme-patches', 'OC_Toolkit_SC_EOS'):
            self.assertIn('- ' + component, result.stdout)

    def test_default_mode_keeps_warning_in_description(self):
        result = self.failure_case(False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('WARNING: Failed components', result.stdout)

    def test_config_only_does_not_download(self):
        result = self.run_shell(r'''
github_api_get() { exit 20; }
download_file() { exit 21; }
main --only configs --strict
cmp "$TEMPLATE_DIR/hekate_ipl.ini" "$SWITCHSD_DIR/bootloader/hekate_ipl.ini"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_corrupt_archive_is_recorded_and_retained(self):
        result = self.run_shell(r'''printf 'not a zip' > broken.zip
if extract_and_cleanup broken.zip Broken; then exit 20; fi
array_name_contains Broken FAILED_ITEMS
[ -f broken.zip ]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_partial_update_merges_versions_without_stale_warnings(self):
        result = self.run_shell(r'''ONLY_MODE=1
printf 'Atmosphere (v1)\nJKSV (v1)\n\nWARNING: Failed components\n- Old failure\n' > "$DESCRIPTION_FILE"
record_item JKSV v2
record_failure Sphaira
write_description_file
cat "$DESCRIPTION_FILE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Atmosphere (v1)', result.stdout)
        self.assertIn('JKSV (v2)', result.stdout)
        self.assertNotIn('JKSV (v1)', result.stdout)
        self.assertNotIn('Old failure', result.stdout)
        self.assertIn('- Sphaira', result.stdout)

    def test_system_asset_lookup_failures_include_emuiibo(self):
        result = self.run_shell(r'''check_dependencies() { :; }
get_latest_release_asset() { return 1; }
main --only system --strict
''', read_description=True)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('- emuiibo', result.stdout)
        self.assertIn('- sys-patch', result.stdout)

    def test_finalization_enables_only_installed_default_modules(self):
        result = self.run_shell(r'''
mkdir -p switch atmosphere/contents
printf payload > payload.bin
for module in 420000000007E51A 420000000000000B 00FF0000636C6BFF; do
    mkdir -p "atmosphere/contents/$module/flags"
    printf module > "atmosphere/contents/$module/exefs.nsp"
    touch "atmosphere/contents/$module/flags/boot2.flag"
done
finalize_setup
[ -f atmosphere/contents/420000000007E51A/flags/boot2.flag ]
[ -f atmosphere/contents/420000000000000B/flags/boot2.flag ]
[ ! -e atmosphere/contents/00FF0000636C6BFF/flags/boot2.flag ]
finalize_setup
[ "$(find atmosphere/contents -name boot2.flag | wc -l | tr -d ' ')" = 2 ]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_startup_markers_are_not_created_for_missing_or_empty_modules(self):
        result = self.run_shell(r'''
mkdir -p atmosphere/contents/420000000000000B
: > atmosphere/contents/420000000000000B/exefs.nsp
enable_default_startup_modules
[ ! -e atmosphere/contents/420000000007E51A ]
[ ! -e atmosphere/contents/420000000000000B/flags/boot2.flag ]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_dry_run_does_not_create_outputs(self):
        result = self.run_shell(r'''
main --strict --dry-run --only core,configs,finalize
[ ! -e "$SWITCHSD_DIR" ]
[ ! -e "$DESCRIPTION_FILE" ]
[ -z "$RELEASE_CACHE_DIR" ]
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
