# Terraform driven Charmed MAAS deployment training

This repository is created for conducting a charmed MAAS training during Berlin Commercial Sprint 2025. Its purpose is to induct Field Engineers to new approach of MAAS Anvil where the deployment is driven by Terraform.

>**NOTE:** The contents of this repo are not yet a product and should not be treated as such. Use at your own risk and have fun responsibly.

## Contents

The full deployment consists of 3 individual Terraform modules that should be run in order:

- [juju-bootstrap](./modules/juju-bootstrap) - Bootstraps Juju at an LXD server or cluster
- [maas-setup](./modules/maas-setup) - Deploys charmed MAAS at a Juju model of the Juju controller of `juju-bootstrap`
- [maas-config](./modules/maas-config) - Configures the charmed MAAS deployed by `maas-setup`

## Instructions

### Bootstrap Juju with juju-bootstrap Terraform

```bash
# Create a trust token to your LXD server/cluster
lxc config trust add --name anvil-training

# (optional) - create an LXD project to isolate training resources
lxc project create anvil-training
# Copy at least the default profile of default project and modify accordingly, if needed
lxc profile copy default default --target-project anvil-training

# copy sample config and modify the contents as needed
cp config/juju-bootstrap/config.tfvars.sample config/juju-bootstrap/config.tfvars

cd modules/juju-bootstrap
terraform init

# Get a Terraform plan for sanity check
terraform plan -var-file ../../config/juju-bootstrap/config.tfvars
# Apply Terraform plan
terraform apply -var-file ../../config/juju-bootstrap/config.tfvars -auto-approve

# record juju_cloud from the output
terraform output -raw juju_cloud
```

### Deploy charmed MAAS with maas-setup Terraform

```bash
# copy sample config and modify the contents as needed
# NOTE: at least set the juju_cloud from the output of the previous module
cp config/maas-setup/config.tfvars.sample config/maas-setup/config.tfvars

cd modules/maas-setup
terraform init

# Get a Terraform plan for sanity check
terraform plan -var-file ../../config/maas-setup/config.tfvars
# Apply Terraform plan
terraform apply -var-file ../../config/maas-setup/config.tfvars -auto-approve

# record maas_api_url, maas_api_key, maas_machines
# maas_machines is a list of hostnames for juju machines that are hosting maas-region, maas-agent units.
# If in a need to enable DHCP to any of the machines with maas-config module later,
# if enable_rack_mode is selected, then this is needed.
terraform output -raw maas_api_url
terraform output -raw maas_api_key
terraform output -raw maas_machines
```

#### Enable HA and region+rack mode

In theory this is something that can happen with simply setting the relevant variables:

```tf
enable_maas_ha   = true
enable_rack_mode = true
charm_postgresql_config = {
  # Important since MAAS consumes way more connection than the default 100.
  # If not set, then MAAS HA cannot use the database
  experimental_max_connections = 300
}
```

However, this is not true with the current version of MAAS charms because of:

- <https://github.com/canonical/maas-charms/issues/315>
- <https://github.com/canonical/maas-charms/issues/316>
- Plans to remove maas-agent entirely from the picture are still not implemented:
  - <https://warthogs.atlassian.net/browse/MAASENG-4599>
  - <https://warthogs.atlassian.net/browse/MAASENG-4600>

Despite the issues there is a way to achieve the MAAS HA region+rack by doing the following:

1. First set the config file for HA and rack mode configuration
2. Then, apply with non-HA region and without rack mode in `-var` to override the values of the configuration files:

    ```bash
    terraform apply -var-file ../../config/maas-setup/config.tfvars -auto-approve -var enable_maas_ha=false -var enable_rack_mode=false
    ```

3. Then apply again by removing `-var enable_maas_ha=false`, to allow MAAS HA being configured. This will expand maas-region units to 3.

    ```bash
    terraform apply -var-file ../../config/maas-setup/config.tfvars -auto-approve -var enable_rack_mode=false
    ```

4. The apply again by removing `-var enable_rack_mode=false`, so that rack mode is configured. This will install a maas-agent charm unit on the same machines as maas-region units. So it will set MAAS snap in `region+rack` mode.

    ```bash
    terraform apply -var-file ../../config/maas-setup/config.tfvars -auto-approve
    ```

##### Troubleshooting HA mode

>**NOTE:** In case any of the MAAS snaps is not configure at any point, we can `juju ssh` to its machine and manually run maas init as a workaround

```bash
# check if MAAS is initialized
sudo maas status

# Get the values
sudo cat /var/snap/maas/current/regiond.conf
database_host: 10.10.0.42
database_name: maasdb
database_user: maas
database_pass: maas
database_port: 5432
maas_url: http://10.10.0.28:5240/MAAS

# Fill with values from above
sudo maas init region+rack --maas-url "$maas_url" --database-uri "postgres://$database_user:$database_pass@$database_host:$database_port/$database_name"
```

### Configure charmed MAAS with maas-config Terraform

```bash
maas_api_url
maas_api_key
maas_machines
# copy sample config and modify the contents as needed
# NOTE: at least set the maas_api_url, maas_api_key from the output of the previous module
# NOTE 2: if enable_rack_mode is true then DHCP can be enabled by providing a rack_controller
#         from the maas_machines output of the previous mode, plus set enable_dhp config,
#         plus set the pxe_subnet. Based on the LXD configuration, the CIDR to use for DHCP
#         is known to the practitioner, so it has to be manually recorded in the config.
cp config/maas-config/config.tfvars.sample config/maas-config/config.tfvars

cd modules/maas-config
terraform init

# Get a Terraform plan for sanity check
terraform plan -var-file ../../config/maas-config/config.tfvars
# Apply Terraform plan
terraform apply -var-file ../../config/maas-config/config.tfvars -auto-approve
```

## Accessing MAAS

At this point all modules have been applied. The practitioner is aware of:

- MAAS URL
- MAAS admin credentials
- MAAS admin API key

The above combination allows the practitioner to access charmed MAAS UI from their browser or configure their MAAS CLI to access MAAS.
