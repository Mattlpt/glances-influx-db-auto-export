# glances-influx-db-auto-export

- auto-detects the invoking user (`SUDO_USER`) and the `glances` binary;
- generates the `glances.service` unit (starts after `network-online.target`, with `Restart=always`);
- stops the manual instance to prevent a **duplicate export** to InfluxDB;
- enables and starts the service, then prints its status.
