#!/usr/bin/env python3
"""
Flutter/Dart behavioral test generator focused on real user interaction patterns.

Generates high-quality tests with:
- Proper mock annotations (@GenerateMocks)
- Platform channel mocking
- Async state validation
- Edge case coverage
- Real user behavior scenarios
"""
import os
import subprocess
import pathlib
import json
import re
import requests
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass

ROOT = pathlib.Path(__file__).resolve().parents[2]


@dataclass
class SourceAnalysis:
    """Analysis results from source code inspection."""
    class_name: str
    dependencies: List[str]
    platform_channels: List[str]
    async_methods: List[str]
    state_properties: List[str]
    user_interactions: List[str]
    error_handlers: List[str]


def run(cmd: str, check: bool = True) -> str:
    """Execute shell command and return stdout."""
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and res.returncode != 0:
        raise Exception(
            f"Command failed: {cmd}\nstdout:{res.stdout}\nstderr:{res.stderr}"
        )
    return res.stdout.strip()


def get_all_dart_files() -> List[str]:
    """Get all .dart files in lib/ (except test/)."""
    lib_path = ROOT / "lib"
    dart_files = []
    for dart_file in lib_path.rglob("*.dart"):
        rel_path = str(dart_file.relative_to(ROOT))
        dart_files.append(rel_path)
    return dart_files


def read_file(path: str) -> str:
    """Read file content."""
    p = ROOT / path
    return p.read_text(encoding="utf-8")


def analyze_source_code(source: str, file_path: str) -> SourceAnalysis:
    """Analyze source code to extract testable components and user interactions."""
    
    # Extract class name
    class_match = re.search(r'class\s+(\w+)', source)
    class_name = class_match.group(1) if class_match else "UnknownClass"
    
    # Find dependencies (constructor parameters, fields with types)
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
    
    # Find platform channels
    platform_channels = re.findall(r"MethodChannel\(['\"](\w+)['\"]\)", source)
    
    # Find async methods
    async_methods = re.findall(r'Future<\w+>\s+(\w+)\(', source)
    
    # Find state properties
    state_props = []
    state_patterns = [
        r'bool\s+(_?is\w+)',
        r'enum\s+(\w+State)',
        r'(\w+State)\s+\w+',
    ]
    for pattern in state_patterns:
        state_props.extend(re.findall(pattern, source))
    state_props = list(set(state_props))
    
    # Identify user interaction patterns
    user_interactions = []
    interaction_keywords = {
        'speak': 'User initiates speech/audio playback',
        'play': 'User plays audio/video content',
        'pause': 'User pauses playback',
        'stop': 'User stops operation',
        'resume': 'User resumes paused operation',
        'toggle': 'User toggles a setting/state',
        'save': 'User saves data',
        'delete': 'User deletes item',
        'edit': 'User edits content',
        'add': 'User adds new item',
        'update': 'User updates existing data',
        'refresh': 'User refreshes data',
        'load': 'User triggers data loading',
        'download': 'User downloads content',
        'upload': 'User uploads content',
        'share': 'User shares content',
        'favorite': 'User marks as favorite',
        'search': 'User searches content',
        'filter': 'User filters results',
    }
    
    for keyword, description in interaction_keywords.items():
        if re.search(rf'\b{keyword}\w*\s*\(', source, re.IGNORECASE):
            user_interactions.append((keyword, description))
    
    # Find error handling patterns
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


def generate_channel_mocks(channels: List[str]) -> str:
    """Generate platform channel mock setup code."""
    if not channels:
        return "// No platform channels to mock"
    
    mocks = []
    for channel in channels:
        mocks.append(f"""TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        MethodChannel('{channel}'),
        (call) async {{
          // Mock common methods
          if (call.method == 'speak') return 1;
          if (call.method == 'stop') return 1;
          if (call.method == 'setLanguage') return 1;
          return null;
        }}
      );""")
    return "\n    ".join(mocks)


def generate_channel_cleanup(channels: List[str]) -> str:
    """Generate platform channel cleanup code."""
    if not channels:
        return "// No channels to clean up"
    
    cleanups = []
    for channel in channels:
        cleanups.append(f"""TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannel('{channel}'), null);""")
    return "\n    ".join(cleanups)


def build_enhanced_prompt(file_path: str, source: str, analysis: SourceAnalysis) -> str:
    """Build comprehensive prompt with deep source analysis."""
    
    # Build context about the code
    context_parts = []
    
    if analysis.dependencies:
        context_parts.append(f"Dependencies to mock: {', '.join(analysis.dependencies)}")
    
    if analysis.platform_channels:
        context_parts.append(f"Platform channels to mock: {', '.join(analysis.platform_channels)}")
    
    if analysis.async_methods:
        context_parts.append(f"Async methods requiring state validation: {', '.join(analysis.async_methods)}")
    
    if analysis.user_interactions:
        interactions = [f"{kw} ({desc})" for kw, desc in analysis.user_interactions]
        context_parts.append(f"User interactions to test: {', '.join(interactions)}")
    
    context_section = "\n".join(f"- {part}" for part in context_parts) if context_parts else "- Basic unit testing required"
    
    # Build user behavior scenarios
    scenarios = []
    for keyword, description in analysis.user_interactions[:5]:
        scenarios.append(f"""
    test('{description}', () async {{
      // Given: User is ready to {keyword}
      // Setup initial state and mock responses
      
      // When: User performs {keyword} action
      // Trigger the user interaction
      
      // Then: System responds correctly
      // Verify state changes, API calls, UI updates
    }});""")
    
    scenarios_section = "\n".join(scenarios) if scenarios else """
    test('Basic functionality works correctly', () async {
      // Given: Initial state
      // When: User interaction occurs
      // Then: Expected outcome
    });"""
    
    prompt = f"""You are a senior Flutter test engineer specializing in behavioral testing and user interaction patterns.

TARGET FILE: {file_path}
CLASS UNDER TEST: {analysis.class_name}

ANALYZED CONTEXT:
{context_section}

OBJECTIVE: Generate production-quality behavioral tests that validate real user workflows, not just code coverage.

MANDATORY REQUIREMENTS:

1. IMPORTS & ANNOTATIONS:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
// Import the class under test
import 'package:devocional_nuevo/{file_path.replace('lib/', '')}';

@GenerateMocks([{', '.join(analysis.dependencies[:5]) if analysis.dependencies else 'Object'}])
void main() {{
