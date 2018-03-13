
# CITreeView

CITreeView created to implement and maintain that wanted TreeView structures for IOS platforms easy way.

[![Twitter: @cekjacks](https://img.shields.io/badge/contact-%40cekjacks-blue.svg)](https://twitter.com/cekjacks)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](http://cocoadocs.org/docsets/CITreeView)
[![Build Status](https://travis-ci.org/cenksk/CITreeView.svg?branch=master)](https://travis-ci.org/cenksk/CITreeView)



![](https://github.com/cenksk/CITreeView/blob/master/CITreeView_01.gif) | ![](https://github.com/cenksk/CITreeView/blob/master/CITreeView_02.gif)


## Installation

1. Download .zip file
2. Just drag and drop CITreeViewClasses folder to your project

## Usage

### Initialization
1. Firstly, import CITreeView

```
import CITreeView
```

2. Add CITreeViewDelegate and CITreeViewDataSource to your view controller

```
class ViewController:UIViewController,CITreeViewDelegate,CITreeViewDataSource
```

3. Initialize and configure CITreeView

```
let ciTreeView = CITreeView.init(frame: self.view.bounds, style: UITableViewStyle.plain)
ciTreeView.treeViewDelegate = self
ciTreeView.treeViewDataSource = self
self.view.addSubview(ciTreeView)
```

3. Implement required methods of the CITreeView's delegates

```
func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> UITableViewCell {

return cell;
}
```

```
func treeViewItemChild(andItem item: AnyObject) -> [AnyObject] {
if let dataObj = item as? YourDataType {
return dataObj.children
}
return []
}
```
```
func treeViewDataArray() -> [AnyObject] {
return yourDataArray
}
```
```
func treeView(_ tableView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> CGFloat {
return UITableViewAutomaticDimension;
}
```

```
func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode:CITreeViewNode) {}

func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}

func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}

func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}

func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}
```
### Features

1. You can only open one node at a time if you wish. If another parent node is selected while a node is opened, the open nodes will closed automatically.

```
ciTreeView.collapseNoneSelectedRows = true
```

License
-----------------

MIT licensed, Copyright (c) 2018 Cenk Işık, [@cekjacks](https://twitter.com/cekjacks)
