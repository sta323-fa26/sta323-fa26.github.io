Step-by-step guide to setting up CI on dept. servers

## Step 0

Make sure you've disabled base permission for org members in GitHub course org.

## Step 1: install dependencies (local machine)

### 1.1
#### mac
`brew install ansible`
`brew install ssh-copy-id`

### 1.2

`git clone https://github.com/rundel/ansible_gh_runner.git`

## Step 2: setup a runner online

- Go to [https://rtoolkits.web.duke.edu/projects](https://rtoolkits.web.duke.edu/projects) and setup.
- Copy ssh key to runner: `ssh-copy-id user@host`

## Step 3: ansible

```
ansible-playbook gh-runners.yml \
  -i "rapid-####.vm.duke.edu," \
  -u rapid \
  -b --ask-become-pass
```

- the pass to put in is the RUNNER pass code (for sudo permission during setup)
- follow other instructions, e.g. `sta323-fa26` etc. 
- the GH runner token is found sta323-fa26 --> Settings --> Actions --> Runners --> New runner --> New self-hosted runner; find the token under "Configure" in-line.

## Step 4: verify

Verify on Github under organization --> settings --> actions --> runners --> self-hosted