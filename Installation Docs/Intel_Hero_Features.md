# Demonstrating System Metrics and Analysing Time taken for ML Algorithms

> The panel comprises of Grafana, Metabase and Webssh2. Algorithms can be executed against workloads live from the terminal and Performance can be analysed through Grafana and Metabase.

## Prerequisites
- Install Prometheus, Grafana on Monitoring VM, refer [Link](https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/Node%20Exporter%2C%20Prometheus%2C%20Grafana%20.md)
- Installing Metabase & Postgres on Metabase VM, refer [Link](https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/Metabase.md)

## Setting up Webssh2 

> Web SSH Client using ssh2, socket.io, xterm.js, and express. webssh webssh2

### Installing NodeJS

Make sure you have NodeJS Installed, if not Install it using [NVM](https://github.com/nvm-sh/nvm):

```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash


export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

Running the above command downloads a script and runs it. The script clones the nvm repository to` ~/.nvm`, and attempts to add the source lines from the snippet below to the correct profile file (`~/.bash_profile`, `~/.zshrc`, `~/.profile`, or `~/.bashrc`).

Installing NodeJS LTS

```shell
nvm install --lts
```

### Setting up sshd_config 

We need to set `PermitRootLogin yes` and `PasswordAuthentication yes` in sshd_config under `/etc/ssh/sshd_config`

Then restart the sshd system service by:

```shell
sudo systemctl restart sshd.service
```

### Set the password for the root user
```shell
# switch to root user
$ sudo su

# set password for root user
$ passwd

New password: 
Retype new password: 
passwd: password updated successfully
```

### Cloning the WebSSH2 repository

```shell
git clone https://github.com/billchurch/webssh2.git

# cd into the app directory
cd webssh2/app
```

Checkout to the latest release, At point of writting the Documentation the latest release version was `0.4.6`

```shell
git checkout 0.4.6
```

Install libraries & Start the service

```shell
npm install

npm start
```

Then access the terminal in Webbsite at the link `http://<serveri-ip>:2222/ssh/host/<server-ip>`

Enter username `root` and the password that you set earlier for root user. You should now be able to see Terminal in Website.

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/Authentication.png"/>

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/webssh2.png"/>


## References

- [WebSSH2](https://github.com/billchurch/webssh2)