# Factorio Headless Server on Docker
Dockerfile with [fac](https://github.com/sparr/fac) packed, and ability to switch the savegame served.

## Usage

### Pull image
```bash
docker pull tingtingths/factorio
```

### Or build it yourself
```bash
docker build -t my_factorio_image .
```

### Data dir
Mods, saves, logs, caches etc. are saved into `/data` inside the container. You should bind- or volume-mount this directory when running the container, but it needs certain files and folders for the container to work.
`sample_data_directory/` in this repo is a good start.

### Token first run
Unless you provide a `player-data.json` with a `token` in the data mount, `fac` will ask for your factorio username/password, so do this on first run:

```bash
docker run --it --rm \
  -v <path/to/factorio/data/folder>:/data \
  my_factorio_image \
  fac install dummyplaceholder
```
and `player-data.json` will be saved with your token.

### Start container with the image
```bash
docker run -d --name factorio \
	--restart=unless-stopped \
	-p 34197:34197/udp \
	-v <path-to-factorio-data-dir>:/data \
	my_factorio_image \
  start-server my-save-game
```
This will start serving `<path-to-factorio-data-dir>/saves/my-save-game.zip`, after automatically downloading and enabling the mods listed *within the savegame*. Any other mods (e.g. from previously served savegames) will be disabled.

Use `docker logs factorio` or `docker exec factorio fac list` to see which mods are enabled for the current savegame.

### Don't care about switching between multiple savegames
If you run the container with just `start-server` (without a savegame name), or with no command at all, it'll default to `<path-to-factorio-data-dir>/saves/save.zip`, which you can overwrite with your savegame then forget about.

### Want to manage mods manually on the server ignoring what's in the savegame(s)
Create a file `<path-to-factorio-data-dir>/mods.txt` listing the mods you want, one per line. Restart the container after changing the mod list.

**OR** pass `-e SKIP_AUTOMODS=1` when running the container, and use `docker exec factorio fac [install|remove|enable|disable|list|etc.]` to manage mods - the container needs to be restarted afterwards.

### Add/remove mods from current savegame
It's easier and less error-prone to use *different saves for different modsets*.

The easiest way is via your local Factorio client: connect to the server, save the game (locally), quit the multiplayer session, install/enable/disable the mods you want, load the local savegame, save it again. Then `scp` or otherwise copy the local savegame to the server's `<path-to-factorio-data-dir>/saves` folder, and restart the container with the modified savegame.

Alternatively (this will alter the mods in the *current* served savegame, use caution):
1. `docker exec factorio fac [install|disable] <modname> && docker stop factorio && docker rm factorio`
2. restart the container, passing as well `-e SKIP_AUTOMODS=1`
3. `docker stop factorio && docker rm factorio` (savefile should now have the new mods configuration)
4. restart the container normally

### Rcon
To enable rcon, pass `-p 27015:27015` and `-e "RCON_PASSWD=somepassword"` when running the container.

