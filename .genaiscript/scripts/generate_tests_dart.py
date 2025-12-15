#!/usr/bin/env python3
import os
import subprocess
import pathlib
import json
import re
import requests
from typing import List, Tuple
from dataclasses import dataclass

ROOT = pathlib.Path(__file__).resolve().parents[2]

@dataclass
class SourceAnalysis:
    class_name: str
    dependencies: List[str]
    platform_channels: List[str]
    async_methods: List[str]
    state_properties: List[str]
    user_interactions: List[str]
    error_handlers: List[str]

def log(msg):
    print(f"[LOG] {msg}", flush=True)

def run(cmd: str, check: bool = True) -> str:
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and res.returncode != 0:
        log(f"Command failed: {cmd}\nstdout:{res.stdout}\nstderr:{res.stderr}")
        raise Exception(f"Command failed: {cmd}")
    return res.stdout.strip()

def get_modified_dart_files() -> List[str]:
    try:
        run("git fetch origin main --depth=1", check=False)
    except Exception:
        log("Could not fetch git origin.")
    out = run("git diff --name-only origin/main...HEAD", check=False)
    files = [f.strip() for f in out.splitlines() if f.strip().endswith(".dart")]
    files = [f for f in files if not f.startswith("test/")]
    files = [f for f in files if f.startswith("lib/")]
    log(f"Modified dart files: {files}")
    return files

def get_priority_dart_files(max_files: int = 3) -> List[str]:
    lib_path = ROOT / "lib"
    dart_files = []
    priority_folders = ["services", "blocs", "controllers", "providers", "models"]
    for folder in priority_folders:
        folder_path = lib_path / folder
        if folder_path.exists():
            for dart_file in folder_path.glob("*.dart"):
                rel_path = str(dart_file.relative_to(ROOT))
                dart_files.append(rel_path)
                if len(dart_files) >= max_files:
                    return dart_files
    log(f"Priority dart files: {dart_files}")
    return dart_files

def read_file(path: str) -> str:
    p = ROOT / path
    log(f"Reading file: {p}")
    return p.read_text(encoding="utf-8")

def analyze_source_code(source: str, file_path: str) -> SourceAnalysis:
    class_match = re.search(r'class\s+(\w+)', source)
    class_name = class_match.group(1) if class_match else "UnknownClass"
    dependencies = []
    dep_patterns = [
        r'final\s+(\w+)\s+\w+;',
        r'(\w+)\s+\w+;',
        r'required\s+this\.(\w+)',
    ]
    for pattern in dep_patterns:
        deps = re.findall(pattern, source)
        dependencies.extend([d for d in deps if d[0].isupper()])
    dependencies = list(set(dependencies))
    platform_channels = re.findall(r"MethodChannel\(['\"](\w+)['\"]\)", source)
    async_methods = re.findall(r'Future<\w+>\s+(\w+)\(', source)
    state_props = []
    state_patterns = [r'bool\s+(_?is\w+)', r'enum\s+(\w+State)', r'(\w+State)\s+\w+',]
    for pattern in state_patterns:
        state_props.extend(re.findall(pattern, source))
    state_props = list(set(state_props))
    user_interactions = []
    interaction_keywords = {
        'speak':'User initiates speech/audio playback', 'play':'User plays audio/video content',
        'pause':'User pauses playback', 'stop':'User stops operation', 'resume':'User resumes paused operation',
        'toggle':'User toggles a setting/state', 'save':'User saves data', 'delete':'User deletes item',
        'edit':'User edits content', 'add':'User adds new item', 'update':'User updates existing data',
        'refresh':'User refreshes data', 'load':'User triggers data loading', 'download':'User downloads content',
        'upload':'User uploads content', 'share':'User shares content', 'favorite':'User marks as favorite',
        'search':'User searches content', 'filter':'User filters results',
    }
    for keyword, description in interaction_keywords.items():
        if re.search(rf'\b{keyword}\w*\s*\(', source, re.IGNORECASE):
            user_interactions.append((keyword, description))
    error_handlers = []
    if 'try' in source or 'catch' in source:
        error_handlers.append('try_catch_blocks')
    if re.search(r'throw\s+\w+Exception', source):
        error_handlers.append('throws_exceptions')
    if 'onError' in source or 'handleError' in source:
        error_handlers.append('error_callbacks')
    return SourceAnalysis(
        class_name=class_name,
        dependencies=dependencies,
        platform_channels=platform_channels,
        async_methods=async_methods,
        state_properties=state_props,
        user_interactions=user_interactions,
        error_handlers=error_handlers,
    )

def build_enhanced_prompt(file_path: str, source: str, analysis: SourceAnalysis) -> str:
    return f"""Generate behavioral (end-to-end) tests for my Flutter app, following Clean Architecture and testing best practices. Simulate a real user flow including navigation across multiple screens with dynamic data, form validation, error handling, and system visual feedback.

When the user enters invalid credentials, the test should assert that a proper error message is displayed, the app state updates accordingly, and dependencies (such as authentication services and repositories) are mocked. The tests must include:

- Success and failure scenarios.
- Mocks for external services and repositories.
- Test groups for full flows (input, navigation, validation, error, success).
- Modular test code structure according to Clean Architecture (presentation, domain, data separation).
- Parameterized tests covering different inputs and results.
- Recommendations for integration with CI/CD.

Generate the code using `flutter_test` and `mockito`/`mocktail`, focus on user flow quality and real coverage (not just line coverage), and briefly explain the motivation of each generated test.

Community best practices for your prompt:
- Encourage the use of test groups to simulate complete screen flows.
- Use mocks and fixtures to improve decoupling, robustness, and repeatability.
- Include tests for navigation, input data, negative validation, and error recovery (not only happy path).
- Adapt test architecture to Clean Architecture for improved maintainability and scalability.
- Add tips for pipeline (CI/CD) integration and code coverage metrics.

File to test: {file_path}
Class under test: {analysis.class_name}
Detected dependencies to mock: {', '.join(analysis.dependencies) if analysis.dependencies else 'None'}
Async methods: {', '.join(analysis.async_methods) if analysis.async_methods else 'None'}

SOURCE CODE TO ANALYZE:

{source}
"""

def extract_dart_code(text: str) -> str:
    code_block_pattern = r"```(?:dart)?\s*([\s\S]*?)```"
    matches = re.findall(code_block_pattern, text)
    if matches:
        return matches[0].strip()
    return text.strip()

def call_deepseek_api(prompt: str) -> str:
    """Call DeepSeek API for code generation."""
    api_key = os.getenv("DEEPSEEK_API_KEY")
    if not api_key:
        raise Exception("DEEPSEEK_API_KEY environment variable not set")
    url = "https://api.deepseek.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "deepseek-coder-v2-instruct",
        "messages": [
            {
                "role": "system",
                "content": ("You are a senior Flutter test engineer specializing in behavioral testing and user interaction patterns.")
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        "temperature": 0.0,
        "max_tokens": 8192,
        "top_p": 0.95,
        "n": 1,
        "stream": False
    }
    log(f"Calling DeepSeek API for prompt ({len(prompt)} chars)...")
    resp = requests.post(url, headers=headers, json=payload, timeout=300)
    log(f"DeepSeek API HTTP {resp.status_code}")
    if resp.status_code != 200:
        error_detail = resp.text[:1000]
        log(f"API call failed: {error_detail}")
        raise Exception(f"API request failed: {resp.status_code}")
    data = resp.json()
    log(f"API response: {json.dumps(data)[:200]}")
    return extract_dart_code(data["choices"][0]["message"]["content"])

def validate_generated_test(content: str, analysis: SourceAnalysis) -> Tuple[bool, List[str]]:
    issues = []
    required_imports = [
        (r'import.*flutter_test', "Missing flutter_test import"),
        (r'void main\(\)', "Missing main() function"),
        (r'test\(', "No test cases found"),
        (r'expect\(', "No assertions found"),
    ]
    for pattern, error in required_imports:
        if not re.search(pattern, content):
            issues.append(error)
    if analysis.dependencies and not re.search(r'@GenerateMocks', content):
        issues.append("Missing @GenerateMocks annotation for dependencies")
    if analysis.platform_channels and not re.search(r'setMockMethodCallHandler', content):
        issues.append("Missing platform channel mocks")
    if analysis.async_methods and not re.search(r'await Future\.delayed', content):
        issues.append("Async methods tested without state propagation delay")
    if not re.search(r'setUp\(', content):
        issues.append("Missing setUp() for test initialization")
    if not re.search(r'tearDown\(', content):
        issues.append("Missing tearDown() for cleanup")
    if 'MissingPluginException' in content:
        issues.append("Generated test contains MissingPluginException - platform channels not mocked")
    if re.search(r'expect\([^,]+,\s*true\)', content):
        count = len(re.findall(r'expect\([^,]+,\s*true\)', content))
        if count > 5:
            issues.append(f"Too many trivial boolean assertions ({count}) - needs more meaningful checks")
    return len(issues) == 0, issues

def write_test_file(src_path: str, content: str) -> str:
    rel = src_path.replace("lib/", "").replace("/", "_").replace(".dart", "")
    fname = f"test_behavioral_{rel}.dart"
    out_dir = ROOT / "test" / "behavioral"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / fname
    out_path.write_text(content, encoding="utf-8")
    log(f"Test generated: {out_path}")
    return str(out_path)

def main():
    log("START script")
    modified = get_modified_dart_files()
    if not modified:
        log("No modified files detected, checking priority...")
        modified = get_priority_dart_files(max_files=3)
        if not modified:
            log("No .dart files found to test, exiting.")
            return
    log(f"Files to process: {modified}")
    generated = []
    failed = []
    for idx, file_path in enumerate(modified, 1):
        log(f"[{idx}/{len(modified)}] Processing: {file_path}")
        try:
            source = read_file(file_path)
        except Exception as e:
            log(f"Failed to read file: {e}")
            failed.append((file_path, str(e)))
            continue
        analysis = analyze_source_code(source, file_path)
        prompt = build_enhanced_prompt(file_path, source, analysis)
        try:
            result = call_deepseek_api(prompt)
        except Exception as e:
            log(f"API call failed: {e}")
            failed.append((file_path, str(e)))
            continue
        is_valid, issues = validate_generated_test(result, analysis)
        if not is_valid:
            for issue in issues:
                log(f"Validation warning: {issue}")
        test_path = write_test_file(file_path, result)
        generated.append(test_path)
        log(f"Test created: {test_path}")
    log(f"SUMMARY: Success {len(generated)}, Fail {len(failed)}")
    if failed:
        log(f"Some files failed: {failed}")

if __name__ == "__main__":
    main()
