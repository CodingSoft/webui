# noqa: INP001
import os
import shutil
import subprocess
from sys import stderr

from hatchling.builders.hooks.plugin.interface import BuildHookInterface


class CustomBuildHook(BuildHookInterface):
    def initialize(self, version, build_data):
        super().initialize(version, build_data)
        # Skip frontend build for PyPI releases - frontend is not required for Python package
        stderr.write(
            ">>> Skipping frontend build for PyPI package (frontend not required)\n"
        )
        stderr.write(
            ">>> To build frontend, use Docker or run 'npm run build' manually\n"
        )

        # Create minimal frontend directory structure to satisfy package requirements
        frontend_dir = os.path.join(build_data.get("build_dir", "build"), "frontend")
        os.makedirs(frontend_dir, exist_ok=True)

        # Create README explaining frontend is not included
        readme_path = os.path.join(frontend_dir, "README.txt")
        with open(readme_path, "w") as f:
            f.write("CodingSoft WebUI frontend is not included in PyPI package.\n")
            f.write(
                "Install via Docker or build frontend manually with 'npm run build'.\n"
            )
            f.write(f"Package version: {version}\n")
            f.write("For more information: https://github.com/codingsoft/webui\n")
