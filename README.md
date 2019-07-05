# Commcon Workshop

This is a collection of resources for the second CommCon Workshop

## How to run...

Drop your Google credential file:
```
mv path_to_google_credentials.json credentials/google.json
```

Start the containers:
```
docker-compose up
```

Run the Drachtio mrf script:
```
cd drachtio-mrf
npm install
```

Most values in `config/default.json` will be correct/sensible for this collection of containers, but
the goole dialoglow project info will probably need editing (see workshop contents)...

```
"dialogflow": {
  "project": "my-project-id",
  "lang": "en-US",
  "event": "welcome"
},
```

Set environment veriables corresponding to your Simwood trunk details:
```
export TRUNK_ACCOUNT=XXXXXXXXXXXXX
export TRUNK_PASSWORD=YYYYYYYYYYYYY
```

Then run the sample drachtio-mrf script:
```
node index.js
```

# Development: container details

This covers details of each container directory you don't need to understand this to run the above, but it helps if you plan to modify any of it.

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
