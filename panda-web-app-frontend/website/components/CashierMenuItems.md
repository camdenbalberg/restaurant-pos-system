# CashierMenuItems

## Events

<!-- @vuese:CashierMenuItems:events:start -->
|Event Name|Description|Parameters|
|---|---|---|
|submitItem|Sends a non-meal item to CashierView|a menu item|
|submitMeal|Sends a completed meal item to CashierView|a completed meal from the popup menu|

<!-- @vuese:CashierMenuItems:events:end -->


## Methods

<!-- @vuese:CashierMenuItems:methods:start -->
|Method|Description|Parameters|
|---|---|---|
|fetchMenuItems|Fetches menu items from API|-|
|handleShowMeal|Will open a meal popup when a meal is selected|the meal as a menu_item|
|getEntreesSides|Get the among of sides and entrees a meal has|the meal as a menu_item|
|showPopup|Opens a meal popup for a given meal|the meal as a menu_item|
|closePopup|Close the meal popup|-|

<!-- @vuese:CashierMenuItems:methods:end -->


