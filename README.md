# Commcon Workshop

This is a collection of resources for CommCon Workshop

## TL;DR

Drop your Google credential file:
```
mv path_to_google_credentials.json credentials/google.json
```

Start the containers:
```
docker-compose up
```

In another shell:
```
cd drachtio-mrf
npm install

export TRUNK_ACCOUNT=XXXXXXXXXXXXX
export TRUNK_PASSWORD=YYYYYYYYYYYYY

node index.js
```

At the moment there is a bug/feature/usage-misunderstanding which means that drachtio responds to the TLS SIP register 401 challenge with a UDP authed response which means it will never register. I'm looking at this, but in the meantime, comment out the register code and use an ACL trunk instead.


## Freeswitch

A freeswitch instance connecting to Google cloud services for use by drachtio-fsmrf. The runnable container specification with config file substitution is contained in the **freeswitch** directory:

```
cd freeswitch
```

### Credentials

You will need a Google JSON credentials file to access Dialogflow, see [how to obtain GOOGLE_APPLICATION_CREDENTIALS file][84c90207].

Save your application file
in credentials/google.json:

```
mv path_to_google_credentials.json credentials/google.json
```

  [84c90207]: https://cloud.google.com/docs/authentication/getting-started "GOOGLE_APPLICATION_CREDENTIALS file"

### Starting

If you have docker compose then a single container docker-compose file is provided here for convenience:

```
docker-compose up
```

Otherwise build and start by hand, something like:
```
docker build -t freeswitch-google .
docker run -v `pwd`/credentials:/credentials FREESWITCH_PASSWORD -p 8021:8021 -p 5080:5080 -p 5081:5081 freeswitch-google
```

### Extending and configuring

A root prompt on the container can be obtained via:
```
docker-compose exec freeswitch-google /bin/bash
```
This allows minor config tweaks to be made in the running container.

As the container storage is not persistent, the pattern is that configuration changes are persisted through restarts by environment variable substitution into a set of templates which are incorporated into the container image.

On container start, the contents of the `templates` directory is recursively copied into the root filesystem with text substitution of all strings `___$ENVIRONMENT_VARIABLE____` for the contents of the `ENVIRONMENT_VARIABLE`.

The `templates` directory is baked into the container image when it is built, so ordinarily it isn't possible to add new file changes, only customise those already captured in this source by changing environment variables.

For development, mount the `templates` directory in the current working directory of the container at start time. This allows full modification of any system config files by placing the new contents at their root pathname under `templates`. These will have environment variables substitued and be copied over at container start time.

The `docker-compose-dev.yml` file usefully includes this volume mount:

```
docker-compose -f docker-compose-devel.yml up
```

If you build useful modifications, please parameterise them using environment variables so that they are useful for anyone, and submit a [pull request](https://github.com/rjp44/commcon-workshop/pulls).
