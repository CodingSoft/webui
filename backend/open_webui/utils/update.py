"""
Update service for automatic updates via git.
Handles git operations, backup, and rollback functionality.
"""

import os
import subprocess
import shutil
import json
import asyncio
from pathlib import Path
from typing import Dict, Optional, Any
from datetime import datetime
import logging
import sys

log = logging.getLogger(__name__)

# Status tracking for ongoing updates
_update_status = {
    "in_progress": False,
    "stage": None,
    "message": None,
    "error": None,
    "started_at": None,
    "completed_at": None,
    "logs": [],
}


def get_update_status() -> Dict[str, Any]:
    """Get current update status."""
    return _update_status.copy()


def _log(message: str, level: str = "info"):
    """Add log entry to update status."""
    entry = {
        "timestamp": datetime.now().isoformat(),
        "level": level,
        "message": message,
    }
    _update_status["logs"].append(entry)
    if level == "error":
        log.error(message)
    else:
        log.info(message)


def _set_stage(stage: str, message: str):
    """Set current update stage."""
    _update_status["stage"] = stage
    _update_status["message"] = message
    _log(f"[{stage}] {message}")


def _run_git_command(args: list, cwd: Optional[str] = None, timeout: int = 60) -> tuple:
    """
    Run a git command safely.
    Returns (success: bool, output: str, error: str)
    """
    try:
        cmd = ["git"] + args
        _log(f"Executing: {' '.join(cmd)}", "debug")

        result = subprocess.run(
            cmd, cwd=cwd or os.getcwd(), capture_output=True, text=True, timeout=timeout
        )

        if result.stdout:
            _log(f"stdout: {result.stdout[:500]}", "debug")
        if result.stderr:
            _log(f"stderr: {result.stderr[:500]}", "debug")

        success = result.returncode == 0
        return success, result.stdout, result.stderr

    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)


def check_prerequisites() -> tuple:
    """
    Check if update prerequisites are met.
    Returns (can_update: bool, message: str)
    """
    # Check if we're in a git repository
    success, _, _ = _run_git_command(["rev-parse", "--git-dir"])
    if not success:
        return False, "Not a git repository"

    # Check for uncommitted changes
    success, stdout, _ = _run_git_command(["status", "--porcelain"])
    if stdout.strip():
        return (
            False,
            f"Uncommitted changes found: {len(stdout.strip().split(chr(10)))} files",
        )

    # Check if we can connect to origin
    success, _, stderr = _run_git_command(["fetch", "--dry-run", "origin"], timeout=10)
    if not success:
        return False, f"Cannot connect to remote: {stderr}"

    return True, "Prerequisites met"


def create_backup() -> tuple:
    """
    Create a backup tag before updating.
    Returns (success: bool, tag_name: str)
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    tag_name = f"backup-before-update-{timestamp}"

    _set_stage("backup", f"Creating backup tag: {tag_name}")

    # Create a tag at current HEAD
    success, _, stderr = _run_git_command(
        ["tag", "-a", tag_name, "-m", f"Auto-backup before update"]
    )
    if not success:
        _log(f"Failed to create backup tag: {stderr}", "error")
        return False, ""

    _log(f"Backup tag created successfully: {tag_name}")
    return True, tag_name


def perform_update(
    target_branch: str = "main", target_remote: str = "origin"
) -> Dict[str, Any]:
    """
    Perform the actual update via git pull.
    This should be run in a background task.
    """
    global _update_status

    if _update_status["in_progress"]:
        return {"success": False, "error": "Update already in progress"}

    # Reset status
    _update_status = {
        "in_progress": True,
        "stage": "initializing",
        "message": "Starting update process",
        "error": None,
        "started_at": datetime.now().isoformat(),
        "completed_at": None,
        "logs": [],
        "backup_tag": None,
    }

    try:
        # Stage 1: Check prerequisites
        _set_stage("prerequisites", "Checking prerequisites...")
        can_update, message = check_prerequisites()
        if not can_update:
            raise Exception(f"Prerequisites failed: {message}")

        # Stage 2: Fetch latest changes
        _set_stage("fetch", "Fetching latest changes from remote...")
        success, _, stderr = _run_git_command(["fetch", target_remote, target_branch])
        if not success:
            raise Exception(f"Failed to fetch: {stderr}")

        # Check if update is needed
        success, stdout, _ = _run_git_command(
            ["rev-list", "HEAD...{}/{}".format(target_remote, target_branch), "--count"]
        )
        if success:
            commit_count = int(stdout.strip())
            _log(f"Commits behind: {commit_count}")
            if commit_count == 0:
                _set_stage("completed", "Already up to date")
                _update_status["in_progress"] = False
                _update_status["completed_at"] = datetime.now().isoformat()
                return {"success": True, "message": "Already up to date"}

        # Stage 3: Create backup
        backup_success, backup_tag = create_backup()
        if not backup_success:
            raise Exception("Failed to create backup")
        _update_status["backup_tag"] = backup_tag

        # Stage 4: Pull changes
        _set_stage("pull", "Pulling latest changes...")
        success, stdout, stderr = _run_git_command(
            ["pull", target_remote, target_branch]
        )
        if not success:
            raise Exception(f"Failed to pull: {stderr}")

        _log(f"Pulled successfully: {stdout[:200]}")

        # Stage 5: Update dependencies if needed
        _set_stage("dependencies", "Checking for dependency updates...")

        # Check if package.json or requirements.txt changed
        success, stdout, _ = _run_git_command(
            ["diff", backup_tag, "HEAD", "--name-only"]
        )
        if success:
            changed_files = stdout.lower()

            if "package.json" in changed_files:
                _log("package.json changed, npm install needed", "warning")
                _update_status["needs_npm_install"] = True

            if "requirements.txt" in changed_files or "pyproject.toml" in changed_files:
                _log("Python dependencies changed, pip install needed", "warning")
                _update_status["needs_pip_install"] = True

        _set_stage("completed", "Update completed successfully")
        _update_status["in_progress"] = False
        _update_status["completed_at"] = datetime.now().isoformat()
        _update_status["needs_restart"] = True

        return {
            "success": True,
            "message": "Update completed successfully",
            "backup_tag": backup_tag,
            "needs_restart": True,
        }

    except Exception as e:
        error_msg = str(e)
        _log(f"Update failed: {error_msg}", "error")
        _update_status["error"] = error_msg
        _update_status["stage"] = "failed"
        _update_status["in_progress"] = False
        _update_status["completed_at"] = datetime.now().isoformat()

        return {"success": False, "error": error_msg}


def rollback_update(backup_tag: str) -> Dict[str, Any]:
    """
    Rollback to a previous backup tag.
    """
    _log(f"Starting rollback to: {backup_tag}")

    # Check if tag exists
    success, _, _ = _run_git_command(["rev-parse", backup_tag])
    if not success:
        return {"success": False, "error": f"Backup tag not found: {backup_tag}"}

    # Reset to backup
    _log("Resetting to backup...")
    success, _, stderr = _run_git_command(["reset", "--hard", backup_tag])
    if not success:
        return {"success": False, "error": f"Rollback failed: {stderr}"}

    _log("Rollback completed successfully")
    return {"success": True, "message": "Rolled back successfully"}


def get_changelog_since_tag(tag: str = "") -> str:
    """
    Get changelog since a specific tag or last 5 commits.
    """
    if tag:
        cmd = ["log", "{}..HEAD".format(tag), "--oneline", "--no-decorate"]
    else:
        cmd = ["log", "-5", "--oneline", "--no-decorate"]

    success, stdout, _ = _run_git_command(cmd)
    if success:
        return stdout
    return ""


async def async_perform_update(*args, **kwargs) -> Dict[str, Any]:
    """
    Async wrapper for perform_update to run in background.
    """
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, lambda: perform_update(*args, **kwargs))
