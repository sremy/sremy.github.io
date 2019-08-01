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

### git log graphically

In ~/.gitconfig
``` ini
[alias]
	log1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
	log2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
	lg = !"git log1"
```