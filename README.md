[![Build Status](https://travis-ci.org/NINEJKH/ansible-role-wildfly.svg?branch=master)](https://travis-ci.org/NINEJKH/ansible-role-wildfly)

# NINEJKH.wildfly

An Ansible role that installs WildFly on Debian-like systems.

## Requirements

none

## Role Variables

```yaml
wildfly_version: 10.1.0.Final
```

## Dependencies

* [lifeofguenter.oracle-java](https://galaxy.ansible.com/lifeofguenter/oracle-java/)

## Example Playbook

```yaml

- hosts: wildflies
  roles:
    - { role: NINEJKH.wildfly }
```

## License

Licensed under the MIT License. See the [LICENSE file](LICENSE) for details.

## Author Information

[9JKH (Pty) Ltd.](https://9jkh.co.za)
