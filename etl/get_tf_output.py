import subprocess, json

def get_terraform_output(name: str = "athena_location", tf_dir: str = "infra") -> str:
    result = subprocess.run(
        ["terraform", f"-chdir={tf_dir}", "output", "-json", name],
        capture_output=True, text=True, check=True,
    )
    return json.loads(result.stdout)
