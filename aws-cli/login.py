import subprocess
import json
import os


def login(serial_number=None, mfa_code=None):
    if not mfa_code:
        raise ValueError("Token is mandatory")

    if not serial_number:
        list_mfa_cmd = ["aws", "iam", "list-mfa-devices"]
        output = subprocess.run(list_mfa_cmd, capture_output=True, text=True)
        mfa_devices = json.loads(output.stdout)
        serial_number = mfa_devices["MFADevices"][0]["SerialNumber"]

    session_token_cmd = [
        "aws",
        "sts",
        "get-session-token",
        "--serial-number",
        serial_number,
        "--token-code",
        mfa_code,
    ]
    result = subprocess.run(session_token_cmd, capture_output=True, text=True)
    if result.returncode == 0:
        credentials = json.loads(result.stdout)["Credentials"]

        # These variables need to be set for assume_role to work
        # Session token required for access in trust policy for assumption
        os.environ["AWS_ACCESS_KEY_ID"] = credentials["AccessKeyId"]
        os.environ["AWS_SECRET_ACCESS_KEY"] = credentials["SecretAccessKey"]
        os.environ["AWS_SESSION_TOKEN"] = credentials["SessionToken"]

        return {
            "aws_access_key_id": credentials["AccessKeyId"],
            "aws_secret_access_key": credentials["SecretAccessKey"],
            "aws_session_token": credentials["SessionToken"],
        }
    else:
        raise Exception(result.stderr)
