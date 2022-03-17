# Inventory Service 

## Technology Stack

- [GoLang] (https://go.dev/)
- [Gorm] (https://gorm.io/index.html)
- [Google Cloud Run] (https://cloud.google.com/run)
- [Google Cloud SQL (Postgres)] (https://cloud.google.com/sql)

## Overview

A simple Go application that can be deployed to Cloud Run that connects to a backend Cloud SQL Postgres database. 

Application includes:
- Automatic Table Migrations
- Automatic Table Seeding
- HTTP Web Paths:
    * "/": Health Check
    * "/getAvailableInventory": Get's current inventory by item


## Files

- [cloudbuild.yaml] (cloudbuild.yaml) Build file that can be used to deploy service
- [go.mod] (go.mod)
- [main.go] (main.go) Main Application file
- [README.md] (README.md) This README file.

## Environment Variables
- DB_HOST
- DB_USER
- DB_PASSWORD (Should be stored in secret manager)
- DB_NAME
- PORT

## Instructions (To be created)

### Cloud SQL

1. Create new Cloud SQL Postgres Database
