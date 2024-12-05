# CashierPopup

## Props

<!-- @vuese:CashierPopup:props:start -->
|Name|Description|Type|Required|Default|
|---|---|---|---|---|
|menu_item|The meal item this popup is building|`Object`|`true`|-|
|cat|The menu item categories that will be displayed|`Array`|`true`|-|
|maxSelections|The max selections of each category you can select for this popup Validate maxSelections to ensure it matches categories in `cat`|`Object`|`true`|-|

<!-- @vuese:CashierPopup:props:end -->


## Events

<!-- @vuese:CashierPopup:events:start -->
|Event Name|Description|Parameters|
|---|---|---|
|submitMeal|Once finished, sends the completed meal to CashierView|the completed meal|
|cancel|-|-|

<!-- @vuese:CashierPopup:events:end -->


## Methods

<!-- @vuese:CashierPopup:methods:start -->
|Method|Description|Parameters|
|---|---|---|
|initializePopup|Dynamically configure categories and initialize selectedItems|-|
|selectItem|Select a menu item from a category|the menu category the selected item|

<!-- @vuese:CashierPopup:methods:end -->


