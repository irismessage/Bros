from pathlib import Path


def get_workdir() -> Path:
    script_path = Path(__file__).resolve()
    project_dir = script_path.parents[1]
    return project_dir


def mine(filename: str, offset: int = 0, echo: bool = True) -> bytes:
    workdir = get_workdir()
    path = workdir / filename
    if echo:
        print(path)
    with open(path, 'rb') as file:
        file.seek(offset)
        contents = file.read()
    return contents
