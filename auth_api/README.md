# Auth API

## Getting Started

### Requirements

- [**git**](https://git-scm.com)
- [**bun**](https://bun.com)

### Installation

1. Clone the repository or use the template option.
2. Go to the `root` folder within a terminal of your choice and type `bun i`.

### Env File

This are the default values, even if you don't specify them in the `.env` file, the api will execute, with the default values.

```bash
API_PORT="3000"
MICROSOFT_CLIENT_ID="your_client_id"
MICROSOFT_CLIENT_SECRET="your_client_secret"
MYSQL_HOSTNAME="your_hostname"
MYSQL_USERNAME="your_username"
MYSQL_DATABASE="your_database"
MYSQL_PASSWORD="your_password"
```

## Scripts

### Develop

```bash
bun run dev
```

### Deploy

If you want you can deploy for a specific target.
For more info: [**bun docs**](https://bun.com/docs/bundler/executables#cross-compile-to-other-platforms).

```bash
bun run build
```

### Migrate Better Auth Schema

For more info: [**Better Auth docs**](https://www.better-auth.com/docs/basic-usage#migrate-database).

```bash
bun run migrate
```

## Better Auth Docs Endpoint

```bash
localhost:3000/api/auth/reference
```
