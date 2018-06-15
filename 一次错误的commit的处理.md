#### 问题
    一次提交中，你提交了错误的代码。
#### 修复如下
> 你只是想修改上次提交的代码，做一次更完美的commit，可以这样

1. git reset commitId，(注：不要带--hard)到上个版本
2. git stash，暂存修改
3. git push --force, 强制push,远程的最新的一次commit被删除
4. git stash pop，释放暂存的修改，开始修改代码
5. 修复问题，重新提交，没有之前的任何提交记录
