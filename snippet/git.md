## Git useful commands

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

To rewrite the last three commits:
``` bash
$ git rebase -i HEAD~3
```

### Updates
``` bash
git checkout -b mydev
git add file1.txt
git commit -m "file1"
git checkout master
git rebase mydev
```
``` bash
git stash save
git pull --rebase
git stash pop
conflicts ?
git add
git stash drop
```

Make `--rebase` the default option for `pull`, by setting the `pull.rebase` config value with
```
git config --global pull.rebase true
```

Or to force all new branches to automatically use `rebase`
```
git config --global branch.autosetuprebase always
```

With `push.default=simple`, `git push` will push only the current branch to the one that `git pull` would pull from, and also checks that their names match.
```
git config --global push.default simple
```

### git log graphically
``` bash
[alias]
log1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
log2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
lg = !"git log1"
```