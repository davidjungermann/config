# Python script for AWS role assumption with MFA

## Prerequisites

- Run AWS configure for the account you want to assume the role for, i.e Omni or Web. This will create a profile in `~/.aws/credentials` file. **This is required for the script to work.** You have to create an **Access Key** in the AWS account you intend to assume a role with. 
- Create a copy of `.env.example` and rename it to `.env`. Fill in the values for the variables in the .env file. Don't forget to change the `XXX_MFA_DEVICE_NAME`. This contains a lot of ARNs, and you can safely remove them if you don't have access to assume that role. 

## Installation
Run `pip install -r requirements.txt` to install the required packages.

## Usage
Run `python awslogin.py -h` for help and usage instructions.

## How can I use this?
The script writes to your AWS config file using the AWS CLI. A new profile is created based on your input. 

```
python awslogin.py -a web -r preprod
```

Would give you a profile called `web-preprod` with the role `preprod` and the account `web`. 

You can then use this profile with the AWS CLI like so:

```
aws sts get-caller-identity --profile web-infra
``` 

This should return the ARN of the role you assumed, in the correct account. 

The script also copies the credentials to your clipboard, so you can set them manually in your shell if you prefer. 


## How does it work?

The script uses the AWS CLI to assume a role in the account you specify. It then writes the credentials to your AWS config file. If you don't have access to assume the role, you won't be able to assume it here either. 

As mentioned in prerequisites, you need to have an access key for the account you want to assume a role in. See more about this [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html?icmpid=docs_iam_console#Using_CreateAccessKey).
