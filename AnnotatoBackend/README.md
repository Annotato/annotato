# AnnotatoBackend

This package contains the source code for the Annotato app backend.

## Setting up

Before starting, make sure that you have postgresql installed and running.

1. Create the `.env.development` environment configuration file from the template.

```
cp .env.template .env.development
```

2. Fill in the `env.development` file with your psql username. Your `.env.development` file should look something like this.
```
DB_PORT=5432
DB_HOSTNAME=localhost
DB_USERNAME=hongyao
DB_PASSWORD=
DB_NAME=annotato
```
3. Edit the "Run" scheme and under the "Options" tab, change the "Working Directory" to "Use custom working directory" and set
the custom directory to be the directory rooted at `annotato/AnnotatoBackend`. This tells the Vapor server to search for the
`.env` file in that directory.

4. Build and run.

5. Execute `curl http://localhost:8080/` in the terminal and you should see the message "AnnotatoBackend up and running!". 

