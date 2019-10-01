# git log

## git log graphically
```bash
git log --graph --oneline master branch1 branch2
git log --graph --oneline --all  # Show all refs including stash
```

## Show the history of a file or a directory
```bash
git log --oneline --name-status -- scripts/
git log --name-status -- bash.md ansible.md
```

## Show files modified in each commit
```
$ git log --name-only
snippet/git.md
$ git log --name-status
M       snippet/git.md
$ git log --stat
 snippet/git.md | 141 +++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 107 insertions(+), 34 deletions(-)
$ git log --numstat
107     34      snippet/git.md
```

## Search in git history
```bash
git log -G "regex"   # Search if this regex matches a line in code diff
git log -S "string"  # Search if this string has been added/removed in code diff
git log -S "regex" --pickaxe-regex  # Search if this regex has been added/removed in code diff
git log --grep "Message"    # Search this regex in commit messages
git log --grep "message" -i # Search this regex in commit messages ignoring case

git log --all --full-history -- **/filename*  # Search commits that added/deleted a file
```

## Options
```
 --all-match
     Limit the commits output to ones that match all given --grep, instead of ones that match at least one.

 -<number>
 -n <number>
 --max-count=<number>
     Limit the number of commits to output.

 --skip=<number>
     Skip number commits before starting to show the commit output.

 --since=<date>
 --after=<date>
     Show commits more recent than a specific date.

 --until=<date>
 --before=<date>
     Show commits older than a specific date.
```

## Double Dot range syntax ..
This asks Git to resolve a range of commits that are reachable from one commit but aren't reachable from another.
To see all commits that are reachable from refB but NOT from not reachable from refA:
```
$ git log refA..refB
$ git log refB ^refA
$ git log refB --not refA
```

To see all commits that are reachable from refA OR refB but NOT from refC, you can use either of:
```
$ git log refA refB ^refC
$ git log refA refB --not refC
```

Example:
```
$ git log --graph --all --oneline
* 3ad7f88 (HEAD -> master) Update README.txt
* 88d0f5c Update fichier.txt directly on master
| * 3397cf1 (dev) Update dev script.txt
| * 86d493c Add script.txt
|/
* 696d93d Update README.txt
* aeca616 Add fichier.txt
* 47425db Initial commit

$ git log --graph --oneline master..dev
* 3397cf1 (dev) Update dev script.txt
* 86d493c Add script.txt

$ git log --graph --oneline dev..master
* 3ad7f88 (HEAD -> master) Update README.txt
* 88d0f5c Update fichier.txt directly on master
```

## Triple Dot range syntax ...
The triple-dot syntax specifies all the commits that are reachable by either of two references but not by both of them.
```
$ git log --graph --oneline master...dev --left-right
< 3ad7f88 (HEAD -> master) Update README.txt
< 88d0f5c Update fichier.txt directly on master
> 3397cf1 (dev) Update dev script.txt
> 86d493c Add script.txt
```

List commits ready to push to remote:
```
$ git log origin/master..HEAD
$ git log origin/master..   # Git substitutes HEAD if one side is missing.
```
This command shows you any commits in your current branch that aren't in the master branch on your origin remote.
<https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection>


More complex branching example:
```
$ git log --graph --oneline --all
*   1fef897 (HEAD -> master) Merge branch 'dev' into master
|\
| *   e4c8baa (dev) Merge branch 'dev' of https://github.com/sremy/gitstudy into dev
| |\
| | * 835d0e8 (origin/dev) Add script2.txt by John
| * | d7571b9 Update fichier.txt on dev branch
| |/
| * 3397cf1 Update dev script.txt
| * 86d493c Add script.txt
* | 3ad7f88 (origin/master) Update README.txt
* | 88d0f5c Update fichier.txt directly on master
|/
* 696d93d Update README.txt
* aeca616 Add fichier.txt
* 47425db Initial commit


$ git log --graph --oneline origin/dev ^origin/master
* 835d0e8 (origin/dev) Add script2.txt by John
* 3397cf1 Update dev script.txt
* 86d493c Add script.txt

$ git log --graph --oneline dev ^origin/master
*   e4c8baa (dev) Merge branch 'dev' of https://github.com/sremy/gitstudy into dev
|\
| * 835d0e8 (origin/dev) Add script2.txt by John
* | d7571b9 Update fichier.txt on dev branch
|/
* 3397cf1 Update dev script.txt
* 86d493c Add script.txt

$ git log --graph --oneline ^dev origin/master
* 3ad7f88 (origin/master) Update README.txt
* 88d0f5c Update fichier.txt directly on master


$ git log --graph --oneline origin/master...origin/dev --left-right --cherry-pick
> 835d0e8 (origin/dev) Add script2.txt by John
> 3397cf1 Update dev script.txt
> 86d493c Add script.txt
< 3ad7f88 (origin/master) Update README.txt
< 88d0f5c Update fichier.txt directly on master

$ git log --graph --oneline origin/master...dev --left-right --cherry-pick
>   e4c8baa (dev) Merge branch 'dev' of https://github.com/sremy/gitstudy into dev
|\
| > 835d0e8 (origin/dev) Add script2.txt by John
> | d7571b9 Update fichier.txt on dev branch
|/
> 3397cf1 Update dev script.txt
> 86d493c Add script.txt
< 3ad7f88 (origin/master) Update README.txt
< 88d0f5c Update fichier.txt directly on master
```
