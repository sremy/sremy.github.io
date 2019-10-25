# Ansible

## Configuration
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

## Variables

Variable precedence:
Here is the order of precedence from least to greatest (the last listed variables winning prioritization):

  1. command line values (eg “-u user”)
  1. role defaults [1]
  1. inventory file or script group vars [2]
  1. inventory group_vars/all [3]
  1. playbook group_vars/all [3]
  1. inventory group_vars/* [3]
  1. playbook group_vars/* [3]
  1. inventory file or script host vars [2]
  1. inventory host_vars/* [3]
  1. playbook host_vars/* [3]
  1. host facts / cached set_facts [4]
  1. play vars
  1. play vars_prompt
  1. play vars_files
  1. role vars (defined in role/vars/main.yml)
  1. block vars (only for tasks in block)
  1. task vars (only for the task)
  1. include_vars
  1. set_facts / registered vars
  1. role (and include_role) params
  1. include params
  1. extra vars (always win precedence)



https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable


## Inventory

```
$ ansible-inventory [options] <action> [host|group]
$ ansible-inventory --list     # print all hosts
$ ansible-inventory --graph [HOST]
$ ansible-inventory --host <HOST>
$ ansible-playbook the_playbook.yml -i inventory.ini
```

## Modules
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

  - name: Delete a directory recursively (including subfolders and files)
    file:
      state: absent
      path: "/home/pi/directoy_to_delete"
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


## Vault

Creation of an encrypted file:
```
ansible-vault create secret.yml
ansible-vault encrypt secret.yml
```
Edit, change password, decrypt or view a vault content:
```
ansible-vault edit foo.yml
ansible-vault rekey foo.yml bar.yml     # change password
ansible-vault decrypt foo.yml bar.yml
ansible-vault view foo.yml bar.yml
```

Usage in vars_files or include_vars section of playbook:
```yaml
---
- name: Show secret variables
  hosts: all
  vars_files: secret.yml
  tasks:
    - debug: var=password

- name: Include vars of stuff.yaml into the 'stuff' variable (2.2).
  include_vars:
    file: stuff.yaml
    name: stuff
```

Ansible Vault can also encrypt arbitrary files, even binary files. If a vault-encrypted file is given as the src argument to the copy, template, unarchive, script or assemble modules, the file will be placed at the destination on the target host decrypted

Ansible also supports encrypting single values inside a YAML file, using the !vault tag to let YAML and Ansible know it uses special processing.
To encrypt a string provided as a cli arg (can then be paste in a playbook):
```
$ ansible-vault encrypt_string --vault-password-file password_file 'clear string' --name 'the_secret_var'
$ ansible-vault encrypt_string --ask-vault-pass 'clear string' --name 'the_secret_var'
New Vault password:
Confirm New Vault password:
the_secret_var: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          30396464646538353434333037313534336136643831336130623436666135313337313162386530
          3264323465626539353631336439343465326566323936390a616264306138346662333662663634
          36336639616535356434336635376631313630613833303739383566656638633232636338336338
          6161346639623535360a653561623963646637386636396339613830666564313363373631383039
          3339
Encryption successful
```

Run with `--ask-vault-pass` or `--vault-password-file`
```
$ ansible-playbook --ask-vault-pass site.yml
Vault password:
...
$ ansible-playbook --vault-password-file /path/to/my/vault-password-file site.yml
```

<https://docs.ansible.com/ansible/latest/user_guide/vault.html>
