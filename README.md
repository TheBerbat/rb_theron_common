# Docker Image

The docker image should be named following next format: `rb-theron-description:distro-0.0.0` like `rb-theron-description:foxy-0.9.0`.

## How to build
Run the following command to build de image:
```console
foo@bar:/repo/path$ docker build -t rb-theron-description:distro-0.0.0 .
```
## How to upload

1. Add credential file with permisions:
```console
foo@bar:~$ cat <credential_file>.json | docker login -u _json_key --password-stdin https://europe-southwest1-docker.pkg.dev/robotnik-5830-dev
```

2. Retag docker image:
```console
foo@bar:~$ docker tag XXXX:YYYY europe-southwest1-docker.pkg.dev/robotnik-5830-dev/robast/XXXX:YYYY
```

3. Upload the image
```console
foo@bar:~$ docker push europe-southwest1-docker.pkg.dev/robotnik-5830-dev/robast/XXXX:YYYY
```
4. Download the image
```console
foo@bar:~$ docker pull europe-southwest1-docker.pkg.dev/robotnik-5830-dev/robast/XXXX:YYYY
```
