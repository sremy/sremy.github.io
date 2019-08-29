# Git useful commands

### Updates

#### pull --rebase
Make `--rebase` the default option for `pull`, by setting the `pull.rebase` config value with
```
$ git config --global pull.rebase true
```
<https://git-scm.com/docs/git-config#Documentation/git-config.txt-pullrebase>

Or to force all new branches to automatically use `rebase`
```
$ git config --global branch.autosetuprebase always
```

#### --autostash
```
$ git rebase --[no-]autostash
$ git pull --rebase --[no-]autostash
```

> --autostash
> --no-autostash
> 
>     Automatically create a temporary stash entry before the operation begins, and apply it after the operation ends. This means that you can run rebase on a dirty worktree. However, use with care: the final stash application after a successful rebase might result in non-trivial conflicts.

[Release notes v1.8.4](https://github.com/git/git/blob/master/Documentation/RelNotes/1.8.4.txt#L196)
[Release notes v2.9.0](https://github.com/git/git/blob/master/Documentation/RelNotes/2.9.0.txt#L84)

#### rebase.autoStash
Since Git [version 2.6.0](https://github.com/git/git/blob/master/Documentation/RelNotes/2.6.0.txt#L51), `git pull --rebase` pays attention to the `rebase.autoStash` option:
> rebase.autoStash
> 
>     When set to true, automatically create a temporary stash entry before the operation begins, and apply it after the operation ends. This means that you can run rebase on a dirty worktree. However, use with care: the final stash application after a successful rebase might result in non-trivial conflicts. This option can be overridden by the --no-autostash and --autostash options of git-rebase. Defaults to false.

```
$ git config --global rebase.autoStash true
```
<https://git-scm.com/docs/git-config#Documentation/git-config.txt-rebaseautoStash>

#### rerere.enabled

rerere = reuse recorded resolution

While rebasing a long-lived branch, we often face to several conflicts.
Git can remember how you’ve resolved a hunk conflict so that the next time it sees the same conflict, Git can resolve it for you automatically.
```
$ git config --global rerere.enabled true
```
<https://git-scm.com/book/en/v2/Git-Tools-Rerere>

#### push.default

With `push.default=simple`, `git push` will push only the current branch to the one that `git pull` would pull from, and also checks that their names match.
```
$ git config --global push.default simple # the default value since git 2.0
```
<https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefault>

#### Conflicts

```
git rebase --continue  # continue the rebase after having resolved a merge conflict
git rebase --abort     # abort the rebase operation and reset HEAD to the original branch
```

### Manual operations

Create a feature branch
```
git checkout -b mydev
git add file1.txt
git commit -m "file1"
git checkout master
...
git rebase mydev
```

git pull rebase with dirty worktree
```
git stash save
git pull --rebase
git stash pop
conflicts ? => resolving
git add <file1>
git rebase --continue
git stash drop
```


### Interactive staging
```
$ git add -i
The file will have its original line endings in your working directory.
           staged     unstaged path
  1:       +12/-1      nothing _layouts/default.html
  2:    unchanged       +76/-9 assets/css/style.scss

*** Commands ***
  1: status       2: update       3: revert       4: add untracked
  5: patch        6: diff         7: quit         8: help
What now> p
The file will have its original line endings in your working directory.
           staged     unstaged path
  1:       +12/-1        +2/-1 _layouts/default.html
  2:    unchanged       +76/-9 assets/css/style.scss
Patch update>> 2
```

### Interactive rebase: Reordering Commits, Squashing Commits, Splitting a Commit

```
$ git rebase -i <right-after-this-commit>
```
To rewrite the last three commits:
```
$ git rebase -i HEAD~3
```

## Git Alias
```
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.alias "! git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\ =\ /"
```
### git log

[git log](./git-log) details page

### git log graphically

Alias in ~/.gitconfig
``` ini
[alias]
	log1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%cr)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'
	log2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%cD%C(reset) %C(bold green)(%cr)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'
	p = log --pretty=format:\"%m %C(bold blue)%h%C(reset) %<(24)%cd %><(15,trunc)%C(yellow)%an%C(reset)%C(bold red)%d%C(reset) %s\" --date=local
	g = log --graph --oneline
	lg = !"git log1"
	l = !"git log1"
	lga = !"git lg --all"
	la = !"git lg --all"
	lg1 = !"git log1"
	lg2 = !"git log2"
```

Git log for release or comparing branches
``` bash
git log v2.5..master --pretty=format:"%m %C(bold blue)%h%C(reset) %<(24)%cd %><(15,trunc)%C(yellow)%an%C(reset)%C(bold red)%d%Creset %s" --date=local
git log branch...master --left-right --date=local --oneline
git log dev...master --left-right --pretty=format:"%m %C(bold blue)%h%C(reset) %<(24)%cd %><(15,trunc)%C(yellow)%an%C(reset)%C(bold red)%d%Creset %s" --date=local --
```

### git credential

Where are credentials stored?
```
$ git config credential.helper
manager
$ git credential-manager version
Git Credential Manager for Windows version 1.18.4
```

To change the credential helper:
```
git config --global credential.helper manager
git config --global credential.helper wincred
git config --global credential.helper osxkeychain	
git config --global credential.helper 'cache --timeout=300'  # 5 min in memory via socket ~/.cache/git/credential/socket
git config --global credential.helper store  # persisted in ~/.git-credentials
```

To reveal a credential:
```
$ git credential fill
url=https://github.com
⏎
```

or with the manager helper:
```
$ git credential-manager get
protocol=https
host=github.com
⏎
protocol=https
host=github.com
path=
username=PersonalAccessToken
password=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

```

or with the store helper:
```
$ git credential-store get
protocol=https
host=bitbucket.org
⏎
username=you@example.com
password=P4ss
```

To **remove** a credential saved for a specific host, use `git credential reject`:
```
$ git credential reject
protocol=https
host=github.com
⏎
# or
url=https://github.com
⏎
```

Usage:
```
git credential <fill|approve|reject>
git credential-manager <get/fill|store/approve|erase/reject>
git credential-manager clear https://github.com
git credential-wincred <get|store|erase>
```

git credential-manager doc:
<https://github.com/microsoft/Git-Credential-Manager-for-Windows/blob/master/Docs/CredentialManager.md>


_Bonus_: Communicate with the cache helper through the Unix socket to retrieve a stored password:
```
$ nc -U ~/.cache/git/credential/socket
action=get
timeout=
protocol=https
host=bitbucket.org
⏎
username=you@gmail.com
password=P@ss!
```

### git bundle

Bundle a repo to copy it to another off-line machine
```
git bundle create <file> <git-rev-list-args>
git bundle verify <file>
git bundle unbundle <file> [<refname>…​] # => Instead, use git clone or git fetch to restore the bundle
git bundle list-heads <file> [<refname>…​]
```
examples:
```
$ git bundle create mybundle --all  # Bundles all branches
$ git clone mybundle .  # Creates a remote origin based on this file
$ git remote -v
origin  /home/me/git/mybundle (fetch)
origin  /home/me/git/mybundle (push)
```
