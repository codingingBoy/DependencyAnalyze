# DependencyAnalyze
Analyze Dependency relationship of file or type in iOS/MacOS app

iOS文件依赖分析：

分析文件目录：过程的所有引用文件

针对每个文件递归查找，单个文件区分OC和swift。OC文件可以通过imort查看实际依赖的文件，swift文件通过桥接文件和当前模块的其它swift文件。针对swift文件，可以进一步缩小引用文件，通过文本查找，如果能精确匹配类型名称则认为有引用。


1、读取引用文件列表

