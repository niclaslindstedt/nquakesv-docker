# nQuake Server

This is the Docker version of nQuake Server.

## Build image

If you have the original `pak0.pak` and `pak1.pak` copy them to the `files\id1\` folder now.

```
docker build . -t niclaslindstedt/nquakesv
```

To prevent collisions in the images names you may want to change `niclaslindstedt` to something else.
