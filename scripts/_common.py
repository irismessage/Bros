from pathlib import Path


def get_workdir() -> Path:
    script_path = Path(__file__).resolve()
    project_dir = script_path.parents[1]
    return project_dir
