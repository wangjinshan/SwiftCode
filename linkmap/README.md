#  使用说明

1, xcode配置: 

**build setting** 搜索 
**Write Link Map File** 改成**YES**

然后把 **Path to Link Map File** 路径改成你要输出路径
比如:

```
/Users/wangjinshan/Desktop/objc/first/linkmap.txt
```

cd到脚本所在的目录:
执行命令

```
python parselinkmap.py /Users/wangjinshan/Desktop/objc/first/linkmap.txt
```


