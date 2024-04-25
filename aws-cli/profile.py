import subprocess


def add_profile(
    role, account, aws_access_key_id, aws_secret_access_key, aws_session_token, region
):
    profile_name = f"{account}-{role}"
    subprocess.run(
        f"aws configure set aws_access_key_id {aws_access_key_id} --profile {profile_name}",
        shell=True,
    )
    subprocess.run(
        f"aws configure set aws_secret_access_key {aws_secret_access_key} --profile {profile_name}",
        shell=True,
    )
    subprocess.run(
        f"aws configure set aws_session_token {aws_session_token} --profile {profile_name}",
        shell=True,
    )
    subprocess.run(
        f"aws configure set region {region} --profile {profile_name}", shell=True
    )
