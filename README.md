# Odoo 19 - Docker Configuration

This is the Docker configuration to run Odoo 19 connected to an external PostgreSQL database.

## Project Structure

```
odoo19/
├── Dockerfile              # Custom Odoo 19 image
├── docker-compose.yml      # Docker services configuration
├── docker-compose.test.yml # Testing configuration
├── odoo.conf              # Odoo configuration (persistent volume)
├── extra-addons/          # Custom addons (persistent volume)
├── enterprise-addons/     # Enterprise addons (persistent volume)
├── test.sh                # Test runner script
├── TESTING.md             # Testing documentation
└── README.md              # This file
```

## Database Configuration

The application connects to an external PostgreSQL database with the following credentials:

- **Host**: host.docker.internal
- **Port**: 5432
- **User**: admin
- **Password**: admin
- **Database**: odoo19

## Persistent Volumes

The following directories are persistent volumes:

1. **extra-addons**: Place your custom Odoo modules here
2. **enterprise-addons**: Place Odoo enterprise modules here
3. **odoo.conf**: Odoo configuration file
4. **odoo-data**: Internal Odoo data (filestore, sessions, etc.)

## Usage Instructions

### 1. Build and Start Containers

```bash
docker-compose up -d --build
```

### 2. View Logs

```bash
docker-compose logs -f odoo
```

### 3. Stop Containers

```bash
docker-compose down
```

### 4. Restart Odoo

```bash
docker-compose restart odoo
```

### 5. Access Odoo

Once started, access Odoo at:

- **URL**: http://localhost:8069
- **User**: admin (configure on first start)
- **Password**: (configure on first start)

## Exposed Ports

- **8069**: Main Odoo port (HTTP)
- **8071**: Video/audio streaming port
- **8072**: Longpolling port (real-time chat)

## Adding Custom Modules

1. Place your modules in the `extra-addons/` or `enterprise-addons/` folder
2. Restart Odoo: `docker-compose restart odoo`
3. Go to Odoo -> Apps -> Update Apps List
4. Search and install your module

## Running Tests

See [TESTING.md](TESTING.md) for complete testing documentation.

Quick usage:

```bash
./test.sh web_m2x_options
```

## Advanced Configuration

You can modify the `odoo.conf` file to adjust:

- Number of workers
- Memory limits
- Logging level
- Master password
- And more...

After modifying `odoo.conf`, restart the container:

```bash
docker-compose restart odoo
```

## Troubleshooting

### Cannot connect to database

Verify that:
1. PostgreSQL is running on your host machine
2. The `odoo19` database exists
3. The `admin` user has the correct permissions
4. `host.docker.internal` is available (this works on Docker Desktop)

### Modules don't appear

1. Verify that modules are correctly placed in `extra-addons/` or `enterprise-addons/`
2. Restart Odoo: `docker-compose restart odoo`
3. Update the applications list in Odoo

### Permission issues

If you have permission issues with volumes:

```bash
sudo chown -R $USER:$USER extra-addons enterprise-addons odoo.conf
```

## Useful Commands

### Execute Odoo commands

```bash
docker-compose exec odoo odoo --help
```

### Update modules

```bash
docker-compose exec odoo odoo -u <module_name> -d odoo19
```

### Python Shell in Odoo

```bash
docker-compose exec odoo odoo shell -d odoo19
```

### Access container

```bash
docker-compose exec odoo bash
```

## Data Backup

Important data is located in:
- `extra-addons/`: Your custom modules
- `enterprise-addons/`: Enterprise modules
- `odoo.conf`: Configuration
- PostgreSQL database (external)
- Docker volume `odoo-data`

To backup the data volume:

```bash
docker run --rm -v odoo19_odoo-data:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/odoo-data-backup.tar.gz -C /data .
```

## Important Notes

- **Master password**: The master password is set to "admin" in `odoo.conf`. Change it in production.
- **Security**: This configuration is for development. For production, consider using a reverse proxy (nginx), HTTPS, and security best practices.
- **Performance**: Adjust the number of workers in `odoo.conf` according to your server resources.
