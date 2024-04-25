import json
import subprocess


def assume(role_arn, role_session_name):
    if not role_arn or not role_session_name:
        raise ValueError("Both role_arn and role_session_name are required")

    command = [
        "aws",
        "sts",
        "assume-role",
        "--role-arn",
        role_arn,
        "--role-session-name",
        role_session_name,
    ]
    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode == 0:
        credentials = json.loads(result.stdout)["Credentials"]
        return {
            "aws_access_key_id": credentials["AccessKeyId"],
            "aws_secret_access_key": credentials["SecretAccessKey"],
            "aws_session_token": credentials["SessionToken"],
        }
    else:
        raise Exception(result.stderr)
