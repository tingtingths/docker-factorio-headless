# Factorio Headless Server on Docker
Dockerfile with [fac](https://github.com/mickael9/fac) packed

## Usage

### Pull image
```bash
docker pull tingtingths/factorio
```

### Or build it yourself
```bash
docker build -t my_factorio_image .
```

### Start container with the image
```bash
# You could start with using the sample_data_directory/ to mount into /app/data
docker run -d --name factorio \
	--restart=always \
	-p 34197:34197/udp \
	-p 27015:27015 \
	-e "RCON_PASSWD=somepassword" \
	-v <path/to/factorio/data/folder>:/app/data \
	my_factorio_image
```

### List mods installed
```bash
docker exec factorio fac list
```
