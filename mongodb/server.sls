{%- from "mongodb/map.jinja" import server with context %}

mongodb_repository:
  pkgrepo.managed:
    - humanname: MongoDB
    - name: "deb http://repo.mongodb.org/apt/debian {{grains['oscodename']}}/mongodb-org/{{ server.version }} main"
    - file: /etc/apt/sources.list.d/mongodb-org-{{ server.version }}.list
    - gpgcheck: 1
    - key_url: https://www.mongodb.org/static/pgp/server-4.2.asc

mongodb_packages:
  pkg.installed:
  - names: {{ server.pkgs }}
  - require:
      - mongodb_repository

mongodb server user and group present:
  group.present:
    - name: mongodb
    - require:
        - pkg: mongodb_packages
  user.present:
    - name: mongodb
    - fullname: mongoDB user
    - shell: /bin/bash
    - createhome: False
    - require:
        - pkg: mongodb_packages

/etc/mongod.conf:
  file.managed:
  - source: salt://mongodb/files/mongod.conf
  - template: jinja
  - require:
    - pkg: mongodb_packages

mongodb_service:
  service.running:
  - enable: true
  - name: {{ server.service }}
  - require:
      - mongodb_packages
  - watch:
    - file: /etc/mongod.conf
