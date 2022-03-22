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

## Deploying the server

Before starting, make sure that you have a public ssh key added to the droplet's `authorized_keys`.

1. `ssh` into the droplet by executing the command

```
ssh vapor@178.128.111.22
```

2. Navigate to the `AnnotatoBackend` directory.

3. Pull the latest changes from the `master` branch and rebase onto `master`.

4. Build the package by executing the command

```
swift build -c "release"
```

5. If the above command fails because of `/usr/bin/ld.gold: fatal error: out of file descriptors and couldn't close any`, execute

```
ulimit -n 65536
```

and try again. (Reference: https://forums.swift.org/t/linker-error-on-ubuntu-18-04-swift-5-1-2/31168/3)

6. Once the package has been built, it's time to run the server. Reattach/create if not exists to the screen named `server` by
executing

```
screen -DR server
```

7. Kill any running processes (may not be the best practice).

8. Navigate to the `AnnotatoBackend` directory.

9. Check that `.env.production` is correctly configured.

10. Start the server by running

```
sudo .build/release/Run serve -b 178.128.111.22:80 --env production
```

11. Detach from the screen by doing Ctrl+A then Ctrl+D. You should see the message `detached from XXXX.server`.

