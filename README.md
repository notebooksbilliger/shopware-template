# 1. Description
This project is called production template because it can be used to 
create project specific configurations. The template provides a basic setup
that is equivalent to the official distribution. If you need customization
the workflow could look like this:
* Fork template*. [How to work with forks and keep them uprodate](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork)
* Make customization (php.ini, apache config)
* Add dependencies
* Add custom or external plugins
* Update composer.json and composer.lock
* Commit changes

## *Fork warning
This template includes both project configuration and dockerfiles. It also includes composer.lock and composer.json files.
It means that at some point fork might differ quite a lot from the original project. In this case, you need to sync fork carefully and 
think about remove upstream from the project, because projects which differ a lot makes no sense to keep in sync.

## Template already contains:
* docker-compose.yml, dockerfiles ready for being used on dev/staging/prod , for tiny setup you can use ./docker-compose.override.yml and of course you will have to adjust php.ini/apache config files
* runner (./bin/run.sh) to launch on a `host machine` to start stack and manipulate it. [Launcher for host machine](./bin/README.md) (./bin/README.md)
* runtime helper for execution inside container to help with main shopware commands, e.g clean cache/build/upgrade/migrations... [Images, shopware runtime helper](./devops/README.md) (./devops/README.md)

To start with project, you need to fork it and/or copy paste this template, so that you can adjust it for your needs, then: 

## Docker images usage

Produced docker image must contain all the necessary things to be able to start an application fast.

Ideally, when during container statup, there is NO any need to mount anything from host FS or from shared FS. 
By this you unlock possibility to scale up/down very quickly without take care about potentially
slow mounted folders. 

Imagine, that the whole host might be gone in a second and within this time interval you must send last 
responses to customers and shut down application and guarantee that after same customer hit another server
again, customer data will already be there. This state is possible to achieve only when all the storages provided 
as external services, e.g S3, RDS, Redis, so on.

Thereby, you have to:
 - avoid as much as possible mounting of FS from host into container,
 - avoid as much as possible store in container memory/internal FS/ internal caches state of the application, which can affect on business logic
 - ensure that your logs are forwarded to stdout, collected on host (e.g with filebeat) and forwarded to external storages (e.g ELK).

# 2. Quick start guide

## 2.0 Initial requirements/preparations:
You need:
* docker
* docker-compose
* to be able to contribute, also needed basic knowledge about docker containers, images. And be able to differentiate docker runtime vs build environments

For development environment, see [./docker-compose.override.yml.dist](./docker-compose.override.yml.dist) file. You can copy it into ./docker-compose.override.yml and make your changes there.
But this you can make mount of local FS into running container, so on.

## 2.1 Start the stack

This commands you execute on host machine. First start takes time, so you have some time for a cup of coffee.

```bash
# start building stack
./bin/run.sh

# refer to help to see other options from runner (also help is shown on stack startup)
./bin/run.sh help

# see runtime helper (as you see, 'shopware help' executed inside running container)
docker-compose exec app shopware help
```

## 2.2 Discover shopware
* demo shop: http://localhost/
* admin area: http://localhost/admin#/ (user: admin, password:shopware)

## 2.3 Shopware during runtime / development
Basically, shopware is a symfony application, which is have quite big overhead with CMS to make it an e-commerce ready shop.

> Most of the symfony related things will work perfectly there, BUT remember, that originally vendor has removed doctrine from the core.

To be able to operate with migrations, so on and for backwards compatibility with some our extensions, I have added again doctrine, so that
standard symfony Migrations bundle can be used, so on. Doctrine also available as a service (as usual).

To make life simpler and to avoid mistakes, was added shopware runtime helper, which you can
use on dev, CI/CD and on prod, see [Images, shopware runtime helper](./devops/README.md) (./devops/README.md)


## 3. Plugins

See https://docs.shopware.com/en/shopware-platform-dev-en/internals/plugins/plugin-commands?category=shopware-platform-dev-en/internals/plugins 

### 3.1 Install

All plugins defined in `plugins.json` should be installed automatically during `shopware build` command.

Alternatively, it's possible to install each Shopware plugin individually with the following commands:
- refresh the list of plugins please launch:
    ```bash
    bin/console plugin:refresh
    ```

- install and activate plugin
    ```bash
    bin/console plugin:install --activate YourFavouritePluginName
    ```

If there are any further actions required they should be described in plugin's README.

### 3.2 Apply migrations
to be sure, that all the things are working fine, ensure that you did applied the migrations:
```bash
./bin/console database:migrate --all
```

### 3.3 Rebuild an image
And at the end, to be sure, that during next run you will get same state of the container,
trigger images rebuild:
```bash
./bin/run.sh build

#or call it without any parameters, so that stack also will be restarted:
./bin/run.sh
```

# 4. Plugins migrations

This migrations are used to prepare shop for the plugin usage.

This migrations must guarantee that after you do a plugin setup, you will always get working environment.

see for more details: https://docs.shopware.com/en/shopware-platform-dev-en/getting-started/indepth-guide-bundle/database?category=shopware-platform-dev-en/getting-started/indepth-guide-bundle

## 4.3 Apply all migrations (post deploy) 

This command can be used from CI/CD as post deploy. You also need it on the local to ensure that stack is uptodate.
This command called automatically when you start on local your stack, but if you do some changes\install or update plugins, so on, you might want to 
execute it manually as well.
```bash
docker-compose exec app shopware apply-migrations
```

# 5. Upgrade

For this purpose you have a command in shopware helper.
Before you run it, ensure that you use `./docker-compose.override.yml` file and mount project files into container, otherwise all
the changes will be gone after you kill running container.
```bash
docker-compose exec app shopware upgrade
```
This command will update local FS (see remark about docker-compose.yml). Then you need to requild container again

# 6. Template overview

This directory tree should give an overview of the template structure.

```txt
├── .env                  # build and runtime configuration for the stack. Under gitignore
├── .env.dist             # example of the .env file with default values. Ready for usage on dev env
├── .gitignore            # NEVER put here your dev env spesific files, like `.DS_Store` so on (use for it global one).
├── .dockerignore         # A list of files/folder, which will be IGNORED during ADD/COPY commands call from Dockerfile on image creation.
├── bin/                  # binaries to setup, build and run symfony console commands 
├── composer.json         # defines dependencies and setups autoloading
├── composer.lock         # pins all dependencies to allow for reproducible installs
├── config                # contains application configuration
│   ├── bundles.php       # defines static symfony bundles - use plugins for dynamic bundles
│   ├── etc/              # contains the configuration of the docker image
│   ├── jwt/              # secrets for generating jwt tokens - DO NOT COMMIT these secrets
│   ├── packages/         # configure packages - see: config/README.md
│   ├── services.xml      # service definition overrides
│   └── services_test.xml # overrides for test env
├── custom                # contains custom files
│   ├── plugins           # custom plugins
├── devops/               # containers, runtime runner. See: ./devops/README.md 
├── docker-compose.yml    # docker-compose
├── phpunit.xml.dist      # phpunit config
├── public                # should be the web root
│   ├── index.php         # main entrypoint for the web application
├── README.md             # this file
├── src
│   ├── Command/*
│   ├── Migrations/*      # NBB custom: added to store Core migrations, which are needed to prepare core of the shop or change it's data
│   ├── Kernel.php        # our kernel extension
│   └── TestBootstrap.php # required to run unit tests
├── vendor/               # this folder in actual state ONLY inside the container and supposed to be used there only. in ./bin/run.sh there available command 'vendors-sync' to sync it into host machine
└── var
    ├── log/              # log dir (only visible inside container, folder is mounted into tmpsf)
    |── cache/            # cache directory for symfony (only visible inside container, folder is mounted into tmpsf)
    |── data/             # on dev env contains data from other services, e.g ES/mysql
    └── plugins.json
```

### 6. Configuration

See [config/README.md](config/README.md)

### 7. Fixtures

To add database fixtures please launch:
```bash
bin/console framework:demodata --env=prod
bin/console dal:refresh:index --env=prod 
```

# Commonly asked questions:

> # WARNING!!!
>
> Answers relevant for dev env. `You must undestand what you are doing`, because some actions might lead to data loose.
>
> In case if you have doubts, ask your team mates or Oleksii Chernomaz

## I see DB issue after successfull startup, it worked before

* Usually it's caused because of the DB version update. If it was the case, remove db folder from ./var/data . Or take care about data migration.
* Another issue, you have changed stack or removed mounted folders (e.g no docker-override file). 
By this you change went into incinsistent state: application thinks that it's installed, but DB is not prepared and empty. Recreate db: just remove install.lock, rebuild again and start stack
