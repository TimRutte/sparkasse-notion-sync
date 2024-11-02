# Sparkasse to Notion Sync

This tool synchronizes Sparkasse account balances with a Notion database using an AWS Lambda function written in Go. It leverages Sparkasse's "Kontowecker" feature, which sends transaction updates via email. The entire setup is provisionable via Terraform.

## Features

- **AWS Lambda Function**: Written in Go, this function processes transaction updates.
- **Sparkasse Kontowecker Integration**: Utilizes the email alerts from Sparkasse's Kontowecker feature.
- **Notion Database Sync**: Updates your Notion database with the latest account balances and transactions.
- **Infrastructure as Code**: Provision all resources using Terraform.

## Requirements

- **AWS Account**: To deploy the Lambda function and related resources.
- **Sparkasse Account**: With the Kontowecker feature enabled for email notifications.
- **Notion Account**: With a database setup to receive account balance updates.
- **Terraform**: Installed on your local machine.

## Setup

### 1. Configure Sparkasse Kontowecker

1. Log in to your Sparkasse account.
2. Navigate to the Kontowecker section.
3. Set up email notifications for transaction updates to a dedicated email address.

### 2. Prepare the Notion Database

1. Create a new database in Notion to store your account balances and transactions.
2. Note down the integration token and database ID for Notion API access.

### 3. Deploy with Terraform

1. Clone this repository:

2. Initialize Terraform:

3. Update the `terraform.tfvars` file with your specific configurations:

4. Deploy the infrastructure:


### 4. Set Up Email Forwarding

1. Set up an email forwarding rule to forward Sparkasse Kontowecker emails to the AWS Lambda function's email endpoint.

## Usage

Once the setup is complete, the AWS Lambda function will automatically process incoming emails from Sparkasse Kontowecker and update your Notion database with the latest account balances and transaction amounts.

## Development

### Prerequisites

- **Go**: Installed on your local machine.
- **Terraform**: Installed on your local machine.

### Build and Deploy Locally

tbd

## Contributing

Contributions are welcome! Please fork this repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgements

- [Sparkasse](https://www.sparkasse.de/) for their banking services and Kontowecker feature.
- [Notion](https://www.notion.so/) for their powerful and flexible database platform.
- [AWS](https://aws.amazon.com/) for providing the cloud infrastructure.
- [Terraform](https://www.terraform.io/) for enabling infrastructure as code.

