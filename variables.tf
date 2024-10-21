variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "notion_token" {
  description = "Notion API token"
}

variable "notion_database_id" {
  description = "Notion database ID"
}

variable "gmail_credentials" {
  description = "Gmail API credentials JSON"
}