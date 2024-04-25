#!/usr/bin/env python
import argparse
import os
from dotenv import load_dotenv
from login import login
from assume import assume
from copy_credentials import copy_credentials
from profile import add_profile

load_dotenv()

ACCOUNTS = ["omni", "web"]
ROLES = ["infra", "preprod", "test", "prod"]


def handle_account(account):
    prefix = account.upper()
    result = {}

    result["ACCOUNT_ID"] = os.getenv(f"{prefix}_ACCOUNT_ID")
    result["MFA_DEVICE_NAME"] = os.getenv(f"{prefix}_MFA_DEVICE_NAME")

    if not result["MFA_DEVICE_NAME"] or result["MFA_DEVICE_NAME"] == "CHANGE_ME":
        raise ValueError(f"No MFA device name for {account}. Check your .env file.")

    if result["ACCOUNT_ID"] is None:
        raise ValueError(f"No value for ACCOUNT_ID. Check your .env file.")

    return result


def generate_arn(account, role, admin):
    prefix = account.upper()
    role_prefix = prefix if not admin else f"{prefix}_ADMIN"
    print(f"{role_prefix}_{role.upper()}_ROLE_ARN")
    arn = os.getenv(f"{role_prefix}_{role.upper()}_ROLE_ARN")

    if arn is None:
        raise ValueError(f"No value for {role}. Check your .env file.")

    return arn


def assume_role(role_arn):
    return assume(role_arn, "dev_work")


def pick_account():
    choice = input(
        f"Which account would you like to log in to? ({', '.join(ACCOUNTS)}): "
    )
    if choice not in ACCOUNTS:
        raise ValueError("Invalid account choice!")

    return choice


def pick_and_assume_role(account, admin):
    roles = ROLES + ["none"]
    choice = input(f"Would you like to assume a role? ({', '.join(roles)}): ")
    credentials = None
    if choice not in roles:
        raise ValueError("Invalid role choice!")

    # If none is picked, user doesn't want to assume a role, return None
    if choice != "none":
        role_arn = generate_arn(account, choice, admin)
        credentials = assume_role(role_arn)
    return choice, credentials


def main(account, role, admin):
    # Let user pick account if not provided
    if not account:
        account = pick_account()

    # Handle selected account variables
    account_variables = handle_account(account)
    mfa_device_name = account_variables["MFA_DEVICE_NAME"]
    mfa_arn = f"arn:aws:iam::{account_variables['ACCOUNT_ID']}:mfa/{mfa_device_name}"

    # Login with MFA device
    print(f"Logging in with MFA device: {mfa_device_name}")
    mfa_code = input("Enter MFA code from your device: ")

    # Set login credentials for use in assume_role
    login_credentials = login(serial_number=mfa_arn, mfa_code=mfa_code)

    # If role is provided, assume role directly
    if role:
        role_arn = generate_arn(account, role, admin)
        print(f"Chosen role: {role}")
        credentials = assume_role(role_arn)

    # If role is not provided, let user pick role
    else:
        role, credentials = pick_and_assume_role(account, admin)

    # If credentials haven't been set in role assumption, use login credentials
    if not credentials:
        credentials = login_credentials

    # Copy credentials to clipboard
    copy_credentials(credentials)

    # Write profile to AWS credentials file
    add_profile(
        role if role != "none" else "default-cli",
        account,
        credentials["aws_access_key_id"],
        credentials["aws_secret_access_key"],
        credentials["aws_session_token"],
        "eu-west-1",
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Script to log in to AWS and assume specific roles.",
        usage="python awslogin.py [OPTIONS]\n"
        "Example without specifying role (will pick role from list): python awslogin.py\n"
        "Example specifying test role: python awslogin.py --role test\n"
        "Example specifying account: python awslogin.py --account web",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "-a",
        "--account",
        type=str,
        help=f"Select an account to assume role for: omni, web",
    )
    parser.add_argument(
        "-r",
        "--role",
        type=str,
        help=f"Select a role directly instead of picking from a list: {', '.join(ROLES)}",
    )
    parser.add_argument(
        "-ad",
        "--admin",
        action="store_true",
        help="Flag for admin rights, default is False",
    )

    args = parser.parse_args()

    main(args.account, args.role, args.admin)
