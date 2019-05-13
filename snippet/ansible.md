# Ansible #

## Configuration ##
https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settings

Searched in the following order:
  1. `ANSIBLE_CONFIG` (environment variable if set)
  2. `ansible.cfg` (in the current directory)
  3. `~/.ansible.cfg` (in the home directory)
  4. `/etc/ansible/ansible.cfg`

Facts cache:

```ini
[defaults]
gathering = smart  # gather facts only if they are not present in the cache or if the cache has expired.
fact_caching = jsonfile
fact_caching_connection = ~/.ansible/ansible_fact_cache
```

Callback plugins
```ini
[defaults]
stdout_callback = debug
```


## Inventory ##

```
$ ansible-inventory [options] [host|group]
```

## Modules ##
File
```yaml
- hosts: all
  tasks:
  - name: Create directory
    file:
      path: /tmp/mydirectory
      state: directory
      mode: "u=rwx,g=rx,o=x"

  - name: Change file ownership, group and mode
    file:
      path: /etc/foo.conf
      owner: foo
      group: foo
      mode: 0644   # when specifying mode using octal numbers, add a leading 0

  - name: Create a symbolic link
    file:
      src: /file/to/link/to
      dest: /path/to/symlink
      owner: foo
      group: foo
      state: link
```

Copy
```yaml
- name: Copy file with owner and permissions
  copy:
    src: myfiles/foo.conf
    dest: /etc/foo.conf
    owner: foo
    group: foo
    mode: 0644

- name: Copy list of files while preserving permissions
  copy:
    src: "files/{{ item }}"
    dest: /etc/
    mode: preserve # the file will be given the same permissions as the source file
  loop:
    - 'file1'
    - 'file2'
    - 'file3'
```
