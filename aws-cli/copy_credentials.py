import pyperclip


def copy_credentials(credentials):
    keys = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN"]
    credentials_str = ""

    for key in keys:
        value = credentials.get(key.lower())
        if value:
            credentials_str += f"{key}={value}\n"

    pyperclip.copy(credentials_str)
