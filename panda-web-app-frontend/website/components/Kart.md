# Kart

## Props

<!-- @vuese:Kart:props:start -->
|Name|Description|Type|Required|Default|
|---|---|---|---|---|
|orderedItems|-|`Array`|`true`|-|

<!-- @vuese:Kart:props:end -->


## Events

<!-- @vuese:Kart:events:start -->
|Event Name|Description|Parameters|
|---|---|---|
|close|clear the cart|-|
|empty-kart|-|-|

<!-- @vuese:Kart:events:end -->


## Methods

<!-- @vuese:Kart:methods:start -->
|Method|Description|Parameters|
|---|---|---|
|completeTransaction|Complete the transaction.|-|
|getAddedPoints|Calculate the total points that should be added to the Customer account. 1 Point for 1 dollar spent|-|
|loyaltyAddCustomer|Add a Customer to the Customer table. Adds a Customer based on their phone number, birthday, and starting points. Also loads the Customer for checkout or loyalty implementation, will be in the same state as after calling loyaltyCheckCustomer().|-|
|loyaltyCheckCustomer|Check if a Customer exists in the table given a phone number. Loads the given Customer for checkout or loyalty implementation.|-|
|checkDiscounts|Check if more discounts can be applied for the loaded Customer. If more discounts can be applied, the discount buttons in the modal will be enabled.|-|
|applyBirthdayDiscount|Add a birthday discount of $10 off.|-|
|applyDiscount|Add a normnal discount of $1 off.|-|

<!-- @vuese:Kart:methods:end -->


