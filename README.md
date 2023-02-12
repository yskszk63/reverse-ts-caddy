# reverse-ts-caddy

Https reverse proxy for docker uses tailscale and caddy.

## Getting Ready

### 1. Add ACL Tag [tailscale]

1. Open [Access Controls - Tailscale](https://login.tailscale.com/admin/acls).
2. Add the following fragments. This tag is tagged to the device being added by the software.
    - ```json
      {
        ...
        "tagOwners": {
          "tag:reverse-ts-caddy": [],
        },
        ...
      }
      ```

### 2. Add OAuth clients [tailscale]

1. Open [OAuth clients - Tailscale](https://login.tailscale.com/admin/settings/oauth)
2. Click `Generate OAuth client...`.
3. Check `Devices - Write`. And add ACL Tag.
4. Click `Generate Client`.
5. Memo `Client ID` and `Client secret`.

## Usage

1. Write `.env`
    - ```bash
      TS_API_CLIENT_ID=xxxxxx
      TS_API_CLIENT_SECRET=tskey-client-xxxx
      AUTHKEY_TAG=tag:reverse-ts-caddy
      TS_HOSTNAME=some-container
      ```
2. Write `docker-compose.yml` referring to the following.
    - [examples/simple/docker-compose.yml](examples/simple/docker-compose.yml)
3. Run `docker compose up`.
4. Check
    - ```bash
      $ curl https://some-container.your-ts-net-name.ts.net -I
      HTTP/2 200 
      accept-ranges: bytes
      alt-svc: h3=":443"; ma=2592000
      content-type: text/html
      date: Sun, 12 Feb 2023 11:24:01 GMT
      etag: "6398a011-267"
      last-modified: Tue, 13 Dec 2022 15:53:53 GMT
      server: Caddy
      server: nginx/1.23.3
      content-length: 615

      $ 
      ```

## License

[MIT](License)

## Author

[yskszk63](https://github.com/yskszk63)
