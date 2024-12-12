# StackGen Generative IAC

This repository contains the reusable action for the StackGen Generative IAC.

## Setup

Please follow the steps below to setup the action:

1. Signup for an account on [StackGen](https://cloud.stackgen.com/)
2. Setup a Personal Access Token on [StackGen](https://cloud.stackgen.com/account-settings/pat/)
3. Add the Personal Access Token as a secret in your repository with the name `STACKGEN_TOKEN`

## Inputs

| Name  | Description    | Required |
| ----- | -------------- | -------- |
| `cmd` | Command to run | Yes      |

## Usage

```yaml
- name: Download IAC
  uses: stackgenhq/stackgen-cli@v0
  env:
    STACKGEN_TOKEN: ${{ secrets.STACKGEN_TOKEN }}
  with:
    cmd: 'appstack download-iac --uuid <appstack_id>'
```

## License

The scripts and documentation in this project are released under the [MIT License](./LICENSE)
