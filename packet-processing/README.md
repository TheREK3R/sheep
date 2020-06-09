# Packet Processing

To find username/password pairs in a PCAP, we are using the Zeek Network Security Monitor. The scripts used to pull creds are in this directory, and the `run.sh` script will run the scripts against a provided PCAP, and the output logs are in the `logs/` directory. `logs/creds.log` contains the JSON log of credentials, with the following schema:

```
SCHEMA TBD
```

## Protocols Parsed

We will find credentials transmitted in the following way:

* HTTP GET parameters
* HTTP POST parameters
* HTTP Basic Authentication
* HTTP Bearer Authorization
* FTP login
* SMTP login
* IMAP login
* POP3 login

## References

* https://github.com/sethhall/credit-card-exposure
* https://docs.zeek.org/en/current/index.html
* https://github.com/corelight/log-add-http-post-bodies/blob/master/scripts/main.bro#L16
